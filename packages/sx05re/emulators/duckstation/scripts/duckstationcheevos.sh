#! /bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present Hector Calvarro (https://github.com/kelvfimer)
#Script for setting up cheevos on duckstation emuelec. it extracts the data from emuelec.conf and it constructs the entries in seetings.ini if [Cheevos] or Enabled = True or Enable = False are not presented

#Extract username and password from emuelec.conf
username=$(grep "global.retroachievements.username" /storage/.config/emuelec/configs/emuelec.conf|sed s/"global.retroachievements.username="//)
password=$(grep "global.retroachievements.password" /storage/.config/emuelec/configs/emuelec.conf|sed s/"global.retroachievements.password="//)

#Parse token from reply retroachievements
token=$(curl -s "http://retroachievements.org/dorequest.php?r=login&u=${username}&p=${password}"|sed -E 's/.*"Token":"?([^,"]*)"?.*/\1/')

#Test the token if empty exit 1.
if [ -z "${token}" ]
then
      echo "Token is empty you must log in retroachievement first in retroarch achievements"
      exit 1
fi

#Variables for checking if [Cheevos] or enabled true or false are presente.
zcheevos=$(grep -Fx "[Cheevos]" /storage/.config/emuelec/configs/duckstation/settings.ini)
zenabledtrue=$(grep -Fx "Enabled = true" /storage/.config/emuelec/configs/duckstation/settings.ini)
zenabledfalse=$(grep -Fx "Enabled = false" /storage/.config/emuelec/configs/duckstation/settings.ini)
datets=$(date +%s%N | cut -b1-13)

#Variables for do not duplicate the entries
zusername=$(grep "Username =" /storage/.config/emuelec/configs/duckstation/settings.ini)
ztoken=$(grep "Token =" /storage/.config/emuelec/configs/duckstation/settings.ini)
zdts=$(grep "LoginTimestamp =" /storage/.config/emuelec/configs/duckstation/settings.ini)


if ([ -z "${zcheevos}" ] && [ -z "${zenabledtrue}" ] && [ -z "${zenabledfalse}" ])
then
     sed -i "${ a} [Cheevos]\nEnabled = true\nUsername = ${username}\nToken = ${token}\nLoginTimestamp = ${datets}" /storage/.config/emuelec/configs/duckstation/settings.ini
elif ([ -z "${zenabledtrue}" ] && [ -z "${zenabledfalse}" ])
then
     sed -i "/^\[Cheevos\].*/a Enabled = true\nUsername = ${username}\nToken = ${token}\nLoginTimestamp = ${datets}" /storage/.config/emuelec/configs/duckstation/settings.ini
elif [ -n "${zenabledtrue}" ]
then 
     if ([ -z "${zusername}" ] && [ -z "${ztoken}" ] && [ -z "${zdts}" ])
     then
          sed -i "/^Enabled = true.*/a Username = ${username}\nToken = ${token}\nLoginTimestamp = ${datets}" /storage/.config/emuelec/configs/duckstation/settings.ini
     fi
elif [ -n "${zenabledfalse}" ]
then
     if ([ -z "${zusername}" ] && [ -z "${ztoken}" ] && [ -z "${zdts}" ])
     then
          sed -i "/^Enabled = false.*/a Username = ${username}\nToken = ${token}\nLoginTimestamp = ${datets}" /storage/.config/emuelec/configs/duckstation/settings.ini
     fi
fi
