# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2018-present Team CoreELEC (https://coreelec.org)

import subprocess
import xbmc
import xbmcaddon


class Monitor(xbmc.Monitor):

   def __init__(self, *args, **kwargs):
      xbmc.Monitor.__init__(self)
      self.id = xbmcaddon.Addon().getAddonInfo('id')

   def onSettingsChanged(self):
      subprocess.call(['systemctl', 'restart', self.id])


if __name__ == "__main__":
   Monitor().waitForAbort()
