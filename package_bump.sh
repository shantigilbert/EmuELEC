#!/bin/bash

# This file is part of the Lakka project and was created by ToKe79. It is originally from https://github.com/libretro/Lakka-LibreELEC/blob/master/libretro_update.sh
# It has been modified by Shanti Gilbert to work with EmuELEC

[ -z "$BUMPS" ] && BUMPS="yes"
[ -z "$LR_PKG_PATH" ] && LR_PKG_PATH="./packages"
[ -z "$PROJECT" ] && PROJECT="Amlogic-ce"
[ -z "$DEVICE" ] && DEVICE="Amlogic-ng"
[ -z "$DISTRO" ] && DISTRO="EmuELEC"

usage()
{
  echo ""
  echo "$0 <--all [--exclude list] | --used [--exclude list] | --packages list>"
  echo ""
  echo "Updates PKG_VERSION in package.mk of libretro packages to latest."
  echo ""
  echo "Parameters:"
  echo " -a --all                 Update all libretro packages"
  echo " -u --used                Update only libretro packages used by Lakka"
  echo " -p list --packages list  Update listed libretro packages"
  echo " -e list --exclude list   Update all/used packages except listed ones"
  echo ""
}

[ "$1" == "" ] && { usage ; exit ; }

case $1 in
  -a | --all )
    s=$1
    shift
    if [ "$1" != "" ] ; then
      case $1 in
        -e | --exclude )
          PACKAGES_EX=""
          x="$1"
          shift
          v="$@"
          [ "$v" == "" ] && { echo "Error: You must provide name(s) of package(s) to exclude after $x" ; exit 1 ; }
          for a in $v ; do
            if [ -f $(find $LR_PKG_PATH -wholename */$a/package.mk) ] ; then
              PACKAGES_EX="$PACKAGES_EX $a"
            else
              echo "Warning: $a is not a libretro package."
            fi
          done
          [ "$PACKAGES_EX" == "" ] && { echo "No valid packages to exclude given! Aborting." ; exit 1 ; }
          ;;
        * )
          echo "Error: After $s use only --exclude (-e) to exclude some packages."
          exit 1
          ;;
      esac
    fi
    # Get list of all libretro packages
    PACKAGES_ALL=`ls $LR_PKG_PATH`
    ;;
  -u | --used )
    s=$1
    shift
    if [ "$1" != "" ] ; then
      case $1 in
        -e | --exclude )
          PACKAGES_EX=""
          x="$1"
          shift
          v="$@"
          [ "$v" == "" ] && { echo "Error: You must provide name(s) of package(s) to exclude after $x" ; exit 1 ; }
          for a in $v ; do
            if [ -f $(find $LR_PKG_PATH -wholename */$a/package.mk) ] ; then
              PACKAGES_EX="$PACKAGES_EX $a"
            else
              echo "Warning: $a is not a libretro package."
            fi
          done
          [ "$PACKAGES_EX" == "" ] && { echo "No valid packages to exclude given! Aborting." ; exit 1 ; }
          ;;
        * )
          echo "Error: After $s use only --exclude (-e) to exclude some packages."
          exit 1
          ;;
      esac
    fi
    # Get list of cores, which are used with Lakka:
    OPTIONS_FILE="distributions/Sx05RE/options"
    [ -f "$OPTIONS_FILE" ] && source "$OPTIONS_FILE" || { echo "$OPTIONS_FILE: not found! Aborting." ; exit 1 ; }
    [ -z "$LIBRETRO_CORES" ] && { echo "LIBRETRO_CORES: empty. Aborting!" ; exit 1 ; }
    # List of core retroarch packages
    RA_PACKAGES="retroarch retroarch-assets retroarch-joypad-autoconfig retroarch-overlays libretro-database core-info glsl-shaders"
    # List of all libretro packages to update:
    PACKAGES_ALL=" $RA_PACKAGES $LIBRETRO_CORES "
    ;;
  -p | --packages )
    PACKAGES_ALL=""
    x="$1"
    shift
    v="$@"
    [ "$v" == "" ] && { echo "Error: You must provide name(s) of package(s) after $x" ; exit 1 ; }
    for a in $v ; do
      if [ -f $(find $LR_PKG_PATH -wholename */$a/package.mk) ] ; then
        PACKAGES_ALL="$PACKAGES_ALL $a "
      else
        echo "Warning: $a is not a libretro package - skipping."
      fi
    done
    [ "$PACKAGES_ALL" == "" ] && { echo "No valid packages given! Aborting." ; exit 1 ; }
    ;;
  * )
    usage
    echo "Unknown parameter: $1"
    exit 1
    ;;
esac
if [ "$PACKAGES_EX" != "" ] ; then
  for a in $PACKAGES_EX ; do
    PACKAGES_ALL=$(echo " "$PACKAGES_ALL" " | sed "s/\ $a\ /\ /g")
  done
fi
echo "Checking following packages: "$PACKAGES_ALL
declare -i i=0
declare -i ii=0
for p in $PACKAGES_ALL
do
  f=$(find $LR_PKG_PATH -wholename */$p/package.mk)
  if [ ! -f "$f" ] ; then
    echo "$f: not found! Skipping."
    continue
    else
    echo "working on : $f"
    source config/options "$p"
    source "$f"
  fi
 
  if [ -z "$PKG_VERSION" ] || [ -z "$PKG_SITE" ] ; then
    echo "$f: does not have PKG_VERSION or PKG_SITE"
    echo "PKG_VERSION: $PKG_VERSION"
    echo "PKG_SITE: $PKG_SITE"
    echo "Skipping update."
    continue
  fi
     
if [ $BUMPS != "no" ]; then

  if [ "$p" != "linux" ]; then
    PKG_SITE=$PKG_SITE
    PKG_SITE_EXT="${PKG_URL: -4}"
 
	if [[ $PKG_SITE != *"github.com"* ]]; then
		echo "Package is not hosted in github, skipping"
	continue
	fi
 
 if [[ $PKG_EE_UPDATE == "no" ]]; then
		echo "Package is protected, skipping"
	continue
	fi
 
  else
    PKG_SITE=$(echo $PKG_URL | sed 's/\/archive.*//g')
  fi
  echo "URL $PKG_SITE"

	[ -n "$PKG_GIT_BRANCH" ] && PKG_GIT_CLONE_BRANCH="$PKG_GIT_BRANCH"
	[ -n "$PKG_GIT_CLONE_BRANCH" ] && GIT_HEAD="heads/$PKG_GIT_CLONE_BRANCH" || GIT_HEAD="HEAD"
   UPS_VERSION=`git ls-remote $PKG_SITE | grep ${GIT_HEAD}$`
   UPS_VERSION=${UPS_VERSION:0:40}
   if [ "$UPS_VERSION" == "$PKG_VERSION" ]; then
    echo "$PKG_NAME is up to date ($UPS_VERSION)"
   else
    i+=1
     echo "$PKG_NAME updated from $PKG_VERSION to $UPS_VERSION"
     sed -i "s|PKG_VERSION=\"$PKG_VERSION|PKG_VERSION=\"$UPS_VERSION|" $f
   fi
else
  UPS_VERSION=$PKG_VERSION
fi 

  if [ "$GET_HANDLER_SUPPORT" != "git" ] && [ "${PKG_SITE_EXT}" != ".git" ]; then 
 
   if grep -q PKG_SHA256 "$f"; then
    echo "PKG_SHA256 exists on $f, clearing"
    sed -i "s/PKG_SHA256=\"$PKG_SHA256\"/PKG_SHA256=\"\"/" $f
    else
    echo "PKG_SHA256 does not exists on $f, creating"
    sed -i -e "s/PKG_VERSION=\"$UPS_VERSION\(.*\)\"/PKG_VERSION=\"$UPS_VERSION\1\"\nPKG_SHA256=\"\"/g" $f
   fi

     source "$f"
    ./scripts/get "$PKG_NAME"
    
    if [ "$p" != "linux" ]; then
    CALCSHA=$(cat ${SOURCES_DIR}/$PKG_NAME/$PKG_NAME-$UPS_VERSION.*.sha256)
    else
    CALCSHA=$(cat ${SOURCES_DIR}/$PKG_NAME/linux-$LINUX-$UPS_VERSION.tar.gz.sha256)
    fi
    
    echo "NEW SHA256 $CALCSHA"
    #sed -i -e "s/PKG_VERSION=\"$UPS_VERSION\(.*\)\"\n\(.*\)\PKG_SHA256=\"\"/PKG_VERSION=\"$UPS_VERSION\1\"\nPKG_SHA256=\"$CALCSHA\"/g" $f
    sed -e "/PKG_VERSION=\"$UPS_VERSION\"/{ N; s/PKG_VERSION=\"$UPS_VERSION\".*PKG_SHA256=\"\"/PKG_VERSION=\"$UPS_VERSION\"\nPKG_SHA256=\"$CALCSHA\"/;}" -i $f
    # sed -i "s/PKG_SHA256=\"$PKG_SHA256/PKG_SHA256=\"$CALCSHA/" $f
    ii+=1
 fi
    
 done
echo "$i package(s) bumped. $ii sha256 updated packages"
