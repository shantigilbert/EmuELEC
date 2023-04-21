#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)

import sys, os, codecs, json, argparse, re

ROOT_PKG = "__root__"

class LibreELEC_Package:
    def __init__(self, name, section):
        self.name = name
        self.section = section
        self.deps = {"bootstrap": [],
                     "init":      [],
                     "host":      [],
                     "target":    []}
        self.wants = []
        self.wantedby = []

        self.unpacks = []

    def __repr__(self):
        s = f"{name:<9}: {self.name}"
        s = f"{s}\n{section:<9}: {self.section}"

        for t in self.deps:
            s = f"{s}\n{t:<9}: {self.deps[t]}"

        s = f"{s}\n{'UNPACKS':<9}: {self.unpacks}"

        s = f"{s}\n{'NEEDS':<9}: {self.wants}"
        s = f"{s}\n{'WANTED BY':<9}: {self.wantedby}"

        return s

    def addDependencies(self, target, packages):
        for d in " ".join(packages.split()).split():
            self.deps[target].append(d)
            name = d.split(":")[0]
            if name not in self.wants and name != self.name:
                self.wants.append(name)

    def delDependency(self, target, package):
        if package in self.deps[target]:
            self.deps[target].remove(package)
            name = package.split(":")[0]
            if name in self.wants:
                self.wants.remove(name)

    def addReference(self, package):
        name = package.split(":")[0]
        if name not in self.wantedby:
            self.wantedby.append(name)

    def delReference(self, package):
        name = package.split(":")[0]
        if name in self.wantedby:
            self.wantedby.remove(name)

    def addUnpack(self, packages):
        if packages.strip():
            self.unpacks = packages.strip().split()

    def isReferenced(self):
        return False if self.wants == [] else True

    def isWanted(self):
        return False if self.wantedby == [] else True

    def references(self, package):
        return package in self.wants

# Reference material:
# https://www.electricmonk.nl/docs/dependency_resolving_algorithm/dependency_resolving_algorithm.html
class Node:
    def __init__(self, name, target, section):
        self.name = name
        self.target = target
        self.section = section
        self.fqname = f"{name}:{target}"
        self.edges = []

    def appendEdges(self, node):
        # Add the node itself...
        if node not in self.edges:
            self.edges.append(node)
        # as well as its edges
        for e in node.edges:
            if e not in self.edges:
                self.edges.append(e)

    # Return True if the dependencies of the specified node are met by this node
    def satisfies(self, node):
        for e in node.edges:
            if e not in self.edges:
                return False
        return True

    def __repr__(self):
        s = f"{'name':<9}: {self.name}"
        s = f"{s}\n{'target':<9}: {self.target}"
        s = f"{s}\n{'fqname':<9}: {self.fqname}"
        s = f"{s}\n{'common':<9}: {self.commonName()}"
        s = f"{s}\n{'section':<9}: {self.section}"

        for e in self.edges:
            s = f"{s}\nEDGE: {e.fqname}"

        return s

    def commonName(self):
        return self.name if self.target == "target" else f"{self.name}:{self.target}"

    def addEdge(self, node):
        if node not in self.edges:
            self.edges.append(node)

def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

# Read a JSON list of all possible packages from stdin, removing newlines
def loadPackages():
    jdata = json.loads(f"[{sys.stdin.read().replace(chr(10),'')[:-1]}]")

    map = {}

    # Load "global" packages first
    for pkg in jdata:
        if pkg["hierarchy"] == "global":
            map[pkg["name"]] = initPackage(pkg)

    # Then the "project" packages, as these will replace any matching "global" packages
    for pkg in jdata:
        if pkg["hierarchy"] == "project":
            map[pkg["name"]] = initPackage(pkg)

    # Then the "device" packages, as these will replace any matching "project" or "global" packages
    for pkg in jdata:
        if pkg["hierarchy"] == "device":
            map[pkg["name"]] = initPackage(pkg)

    return map

# Create a fully formed LibreELEC_Package object
def initPackage(package):
    pkg = LibreELEC_Package(package["name"], package["section"])

    for target in ["bootstrap", "init", "host", "target"]:
        pkg.addDependencies(target, package[target])

    pkg.addUnpack(package["unpack"])

    return pkg

# Split name:target into components
def split_package(name):
    parts = name.split(":")
    pn = parts[0]
    pt = parts[1] if len(parts) != 1 else "target"
    return (pn, pt)

# Return a list of packages of the specified type
def get_packages_by_target(target, list):
    newlist = []

    for p in list:
        (pn, pt) = split_package(p)
        if target in ["target", "init"] and pt in ["target", "init"]:
            newlist.append(p)
        elif target in ["bootstrap", "host"] and pt in ["bootstrap", "host"]:
            newlist.append(p)

    return newlist

# For the specified node iterate over the list of scheduled nodes and return the first
# position where we could possibly build this node (ie. all dependencies satisfied).
def findbuildpos(node, list):

    # Keep a running total of all dependencies as we progress through the list
    alldeps = Node("", "", "")

    candidate = None
    for n in list:
        alldeps.appendEdges(n)
        if alldeps.satisfies(node):
            if len(n.edges) > len(node.edges):
                if candidate == None:
                    candidate = n
                break
            candidate = n

    return list.index(candidate) + 1 if candidate else -1

# Resolve dependencies for a node
def dep_resolve(node, resolved, unresolved):
    unresolved.append(node)

    for edge in node.edges:
        if edge not in resolved:
            if edge in unresolved:
                raise Exception((
                    f"Circular reference detected: {node.fqname} -> {edge.commonName()}\n"
                    f"Remove {edge.commonName()} from {node.name} package.mk::PKG_DEPENDS_{node.target.upper()}"
                    ))
            dep_resolve(edge, resolved, unresolved)

    if node not in resolved:
        resolved.append(node)

    unresolved.remove(node)

# Return a list of build steps for the trigger packages
def get_build_steps(args, nodes):
    resolved = []
    unresolved = []

    # When building the image the :target packages must be installed.
    #
    # However, if we are not building the image then only build the packages
    # and don't install them as it's likely we will be building discrete add-ons
    # which are installed outside of the image.
    #
    install = True if "image" in args.build else False

    for pkgname in [x for x in args.build if x]:
        if pkgname.find(":") == -1:
            pkgname = f"{pkgname}:target"

        if pkgname in nodes:
            dep_resolve(nodes[pkgname], resolved, unresolved)

    # Abort if any references remain unresolved
    if unresolved != []:
        eprint("The following dependencies have not been resolved:")
        for dep in unresolved:
            eprint(f"  {dep}")
        raise("Unresolved references")

    # Output list of resolved dependencies
    for pkg in resolved:
        task = "build" if pkg.fqname.endswith(":host") or pkg.fqname.endswith(":init") or not install else "install"
        yield(task, pkg.fqname)

# Reduce the complete list of packages to a map of those packages that will
# be needed for the build.
def processPackages(args, packages):
    # Add dummy package to ensure build/install dependencies are not culled
    pkg = {
            "name": ROOT_PKG,
            "section": "virtual",
            "hierarchy": "global",
            "bootstrap": "",
            "init": "",
            "host": " ".join(get_packages_by_target("host", args.build)),
            "target": " ".join(get_packages_by_target("target", args.build)),
            "unpack": ""
          }

    packages[pkg["name"]] = initPackage(pkg)

    # Resolve reverse references that we can use to ignore unreferenced packages
    for pkgname in packages:
        for opkgname in packages:
            opkg = packages[opkgname]
            if opkg.references(pkgname):
                if pkgname in packages:
                    packages[pkgname].addReference(opkgname)

    # Identify unused packages
    while True:
        changed = False
        for pkgname in packages:
            pkg = packages[pkgname]
            if pkg.isWanted():
                for opkgname in pkg.wantedby:
                    if opkgname != ROOT_PKG:
                        if not packages[opkgname].isWanted():
                            pkg.delReference(opkgname)
                            changed = True
        if not changed:
            break

    # Create a new map of "needed" packages
    needed_map = {}
    for pkgname in packages:
        pkg = packages[pkgname]
        if pkg.isWanted() or pkgname == ROOT_PKG:
            needed_map[pkgname] = pkg

    # Validate package dependency references
    if not args.ignore_invalid:
        for pkgname in needed_map:
            pkg = needed_map[pkgname]
            for t in pkg.deps:
                for d in pkg.deps[t]:
                    if split_package(d)[0] not in needed_map:
                        msg = f'Invalid package reference: dependency {d} in package {pkgname}::PKG_DEPENDS_{t.upper()} is not valid'
                        if args.warn_invalid:
                            eprint(f"WARNING: {msg}")
                        else:
                            raise Exception(msg)

    node_map = {}

    # Convert all packages to target-specific nodes
    for pkgname in needed_map:
        pkg = needed_map[pkgname]
        for target in pkg.deps:
            if pkg.deps[target]:
                node = Node(pkgname, target, pkg.section)
                node_map[node.fqname] = node

    # Ensure all referenced dependencies exist as a basic node
    for pkgname in needed_map:
        pkg = needed_map[pkgname]
        for target in pkg.deps:
            for dep in pkg.deps[target]:
                dfq = dep if dep.find(":") != -1 else f"{dep}:target"
                if dfq not in node_map:
                    (dfq_p, dfq_t) = split_package(dfq)
                    if dfq_p in packages:
                        dpkg = packages[dfq_p]
                        node_map[dfq] = Node(dfq_p, dfq_t, dpkg.section)
                    elif not args.ignore_invalid:
                        raise Exception(f"Invalid package! Package {dfq_p} cannot be found for this PROJECT/DEVICE/ARCH")

    # To each target-specific node, add the corresponding
    # target-specific dependency nodes ("edges")
    for name in node_map:
        node = node_map[name]
        if node.name not in needed_map:
            if args.warn_invalid:
                continue
            else:
                raise Exception(f"Invalid package! Package {node.name} cannot be found for this PROJECT/DEVICE/ARCH")
        for dep in needed_map[node.name].deps[node.target]:
            dfq = dep if dep.find(":") != -1 else f"{dep}:target"
            if dfq in node_map:
                node.addEdge(node_map[dfq])

    return node_map

#---------------------------------------------
parser = argparse.ArgumentParser(description="Generate package dependency list for the requested build/install packages.    \
                                              Package data will be read from stdin in JSON format.", \
                                 formatter_class=lambda prog: argparse.HelpFormatter(prog,max_help_position=25,width=90))

parser.add_argument("-b", "--build", nargs="+", metavar="PACKAGE", required=True, \
                    help="Space-separated list of build trigger packages, either for host or target. Required property - specify at least one package.")

parser.add_argument("--warn-invalid", action="store_true", default=False, \
                    help="Warn about invalid/missing dependency packages, perhaps excluded by a PKG_ARCH incompatability. Default is to abort.")

parser.add_argument("--ignore-invalid", action="store_true", default=False, \
                    help="Ignore invalid packages.")

group =  parser.add_mutually_exclusive_group()
group.add_argument("--show-wants", action="store_true", \
                    help="Output \"wants\" dependencies for each step.")
group.add_argument("--hide-wants", action="store_false", dest="show_wants", default=True, \
                    help="Disable --show-wants.  This is the default.")

parser.add_argument("--with-json", metavar="FILE", \
                    help="File into which JSON formatted plan will be written.")

args = parser.parse_args()

ALL_PACKAGES = loadPackages()

loaded = len(ALL_PACKAGES)

REQUIRED_PKGS = processPackages(args, ALL_PACKAGES)

# Identify list of packages to build/install
steps = [step for step in get_build_steps(args, REQUIRED_PKGS)]

eprint(f"Packages loaded : {loaded}")
eprint(f"Build trigger(s): {len(args.build)} [{' '.join(args.build)}]")
eprint(f"Package steps   : {len(steps)}")
eprint("")

# Write the JSON build plan (with dependencies)
if args.with_json:
    plan = []
    for step in steps:
        (pkg_name, target) = split_package(step[1])
        plan.append({"task": step[0],
                     "name": step[1],
                     "section": ALL_PACKAGES[pkg_name].section,
                     "wants": [d.fqname for d in REQUIRED_PKGS[step[1]].edges],
                     "unpacks": ALL_PACKAGES[pkg_name].unpacks if pkg_name in ALL_PACKAGES else []})

    with open(args.with_json, "w") as out:
        print(json.dumps(plan, indent=2, sort_keys=False), file=out)

# Output build/install steps
if args.show_wants:
    for step in steps:
        node = (REQUIRED_PKGS[step[1]])
        wants = [edge.fqname for edge in node.edges]
        print(f"{step[0]:<7} {step[1].replace(':target',''):<25} (wants: {', '.join(wants).replace(':target','')})")
else:
    for step in steps:
        print(f"{step[0]:<7} {step[1].replace(':target','')}")
