#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

# TODO: Set Atari800 to Atari5200 when neeeded / done?
# TODO: retroachivements / done?
# I use ${} for easier reading

# IMPORTANT: This script should not return (echo) anything other than the shader if its set

RETROARCHIVEMENTS=(snes nes gba gb gbc megadrive mastersystem pcengine lynx ngp atari2600 virtualboy neogeo neogeocd psx)
NOREWIND=(sega32x psx zxspectrum odyssey2 mame n64 dreamcast atomiswave naomi neogeocd saturn)
NORUNAHEAD=(psp sega32x n64 dreamcast atomiswave naomi neogeocd saturn)

INDEXRATIOS=(4/3 16/9 16/10 16/15 21/9 1/1 2/1 3/2 3/4 4/1 9/16 5/4 6/5 7/9 8/3 8/7 19/12 19/14 30/17 32/9 config squarepixel core custom)
CONF="/storage/.config/emuelec/configs/emuelec.conf"
EMUCONF="/storage/.config/emuelec/configs/emuoptions.conf"
RACONF="/storage/.config/retroarch/retroarch.cfg"
RACORECONF="/storage/.config/retroarch/retroarch-core-options.cfg"
PLATFORM=${1,,}
CORE=${3,,}
ROM="${2##*/}"
#ROM="${ROM%.*}"
SETF=0
SHADERSET=0

function clean_settings() {
# IMPORTANT: Every setting we change should be removed from retroarch.cfg before we do any changes.
	sed -i '/video_scale_integer =/d' ${RACONF}
	sed -i '/video_shader =/d' ${RACONF}
	sed -i '/video_shader_enable =/d' ${RACONF}
	sed -i '/video_smooth =/d' ${RACONF}
	sed -i '/aspect_ratio_index =/d' ${RACONF}
	sed -i '/rewind_enable =/d' ${RACONF}
	sed -i '/run_ahead_enabled =/d' ${RACONF}
	sed -i '/run_ahead_frames =/d' ${RACONF}
	sed -i '/run_ahead_secondary_instance =/d' ${RACONF}
	sed -i '/savestate_auto_save =/d' ${RACONF}
	sed -i '/savestate_auto_load =/d' ${RACONF}
	sed -i '/cheevos_enable =/d' ${RACONF}
	sed -i '/cheevos_username =/d' ${RACONF}
	sed -i '/cheevos_password =/d' ${RACONF}
	sed -i '/cheevos_hardcore_mode_enable =/d' ${RACONF}
	sed -i '/cheevos_leaderboards_enable =/d' ${RACONF}
	sed -i '/cheevos_verbose_enable =/d' ${RACONF}
	sed -i '/cheevos_auto_screenshot =/d' ${RACONF}
	sed -i '/ai_service_mode =/d' ${RACONF}
	sed -i '/ai_service_enable =/d' ${RACONF}
	sed -i '/ai_service_source_lang =/d' ${RACONF}
	sed -i '/ai_service_url =/d' ${RACONF}
	sed -i "/input_libretro_device_p1/d" ${RACONF}
}

function default_settings() {
# IMPORTANT: Every setting we change should have a default value here
	clean_settings
	echo 'video_scale_integer = "false"' >> ${RACONF}
	echo 'video_shader = ""' >> ${RACONF}
	echo 'video_shader_enable = "false"' >> ${RACONF}
	echo 'video_smooth = "false"' >> ${RACONF} 
	echo 'aspect_ratio_index = "22"' >> ${RACONF}
	echo 'rewind_enable = "false"' >> ${RACONF} 
	echo 'run_ahead_enabled = "false"' >> ${RACONF}
	echo 'run_ahead_frames = "1"' >> ${RACONF}
	echo 'run_ahead_secondary_instance = "false"' >> ${RACONF}
	echo 'savestate_auto_save = "false"' >> ${RACONF}
	echo 'savestate_auto_load = "false"' >> ${RACONF}
	echo 'cheevos_enable = "false"' >> ${RACONF}
	echo 'cheevos_username = ""' >> ${RACONF}
	echo 'cheevos_password = ""' >> ${RACONF}
	echo 'cheevos_hardcore_mode_enable = "false"' >> ${RACONF}
	echo 'cheevos_leaderboards_enable = "false"' >> ${RACONF}
	echo 'cheevos_verbose_enable = "false"' >> ${RACONF}
	echo 'cheevos_auto_screenshot = "false"' >> ${RACONF}
	echo 'ai_service_mode = "0"' >> ${RACONF}
	echo 'ai_service_enable = "false"' >> ${RACONF}
	echo 'ai_service_source_lang = "0"' >> ${RACONF}
	echo 'ai_service_url = ""' >> ${RACONF}
	echo "input_libretro_device_p1 = \"1\"" >> ${RACONF}
}

function set_setting() {
# we set the setting on the configuration file
case ${1} in
	"ratio")
	if [[ "${2}" == "false" ]]; then
		# 22 is the "Core Provided" aspect ratio and its set by default if no other is selected
		echo 'aspect_ratio_index = "22"' >> ${RACONF}
	else	
	for i in "${!INDEXRATIOS[@]}"; do
		if [[ "${INDEXRATIOS[$i]}" = "${2}" ]]; then
			break
		fi
	done
		echo "aspect_ratio_index = \"${i}\""  >> ${RACONF}
	fi
	;;
	"smooth")
		[ "${2}" == "1" ] && echo 'video_smooth = "true"' >> ${RACONF} || echo 'video_smooth = "false"' >> ${RACONF} 
	;;
	"rewind")
		(for e in "${NOREWIND[@]}"; do [[ "${e}" == "${PLATFORM}" ]] && exit 0; done) && RE=0 || RE=1
			if [ $RE == 1 ] && [ "${2}" == "1" ]; then
				echo 'rewind_enable = "true"' >> ${RACONF}
			else
				echo 'rewind_enable = "false"' >> ${RACONF} 
			fi
	;;
	"autosave")
		if [ "${2}" == "false" ] || [ "${2}" == "none" ] || [ "${2}" == "0" ]; then 
			echo 'savestate_auto_save = "false"' >> ${RACONF}
			echo 'savestate_auto_load = "false"' >> ${RACONF}
		else
			echo 'savestate_auto_save = "true"' >> ${RACONF}
			echo 'savestate_auto_load = "true"' >> ${RACONF}
		fi
	;;
	"integerscale")
		[ "${2}" == "1" ] && echo 'video_scale_integer = "true"' >> ${RACONF} || echo 'video_scale_integer = "false"' >> ${RACONF} 
	;;
	"shaderset")
		if [ "${2}" == "false" ] || [ "${2}" == "none" ] || [ "${2}" == "0" ]; then 
			echo 'video_shader_enable = "false"' >> ${RACONF}
			echo 'video_shader = ""' >> ${RACONF}
		else
			echo "video_shader = \"${2}\"" >> ${RACONF}
			echo 'video_shader_enable = "true"' >> ${RACONF}
			echo "--set-shader /tmp/shaders/${2}"
		fi
	;;
	"runahead")
	(for e in "${NORUNAHEAD[@]}"; do [[ "${e}" == "${PLATFORM}" ]] && exit 0; done) && RA=0 || RA=1	
    if [ $RA == 1 ]; then
		if [ "${2}" == "false" ] || [ "${2}" == "none" ] || [ "${2}" == "0" ]; then 
			echo 'run_ahead_enabled = "false"' >> ${RACONF}
			echo 'run_ahead_frames = "1"' >> ${RACONF}
		else
			echo 'run_ahead_enabled = "true"' >> ${RACONF}
			echo "run_ahead_frames = \"${2}\"" >> ${RACONF}
		fi
	fi
	;;
	"secondinstance")
	(for e in "${NORUNAHEAD[@]}"; do [[ "${e}" == "${PLATFORM}" ]] && exit 0; done) && RA=0 || RA=1	
    if [ $RA == 1 ]; then
		[ "${2}" == "1" ] && echo 'run_ahead_secondary_instance = "true"' >> ${RACONF} || echo 'run_ahead_secondary_instance = "false"' >> ${RACONF} 
	fi
	;;
	"ai_service_enabled")
		if [ "${2}" == "false" ] || [ "${2}" == "none" ] || [ "${2}" == "0" ]; then
			echo 'ai_service_enable = "false"' >> ${RACONF}
		else
			echo 'ai_service_enable = "true"' >> ${RACONF}
			get_setting "ai_target_lang"
			AI_LANG=${EES}
			[[ "$AI_LANG" == "false" ]] && $AI_LANG="0"
			get_setting "ai_service_url"
			AI_URL=${EES}
			echo "ai_service_source_lang = \"${AI_LANG}\"" >> ${RACONF}
			if [ "${AI_URL}" == "false" ] || [ "${AI_URL}" == "auto" ] || [ "${AI_URL}" == "none" ]; then
				echo "ai_service_url = \"http://ztranslate.net/service?api_key=BATOCERA&mode=Fast&output=png&target_lang=\"${AI_LANG}\"" >> ${RACONF}
			else
				echo "ai_service_url = \"${AI_URL}&mode=Fast&output=png&target_lang=\"${AI_LANG}\"" >> ${RACONF}
			fi
		fi
	;;
	"retroachievements")
		for i in "${!RETROARCHIVEMENTS[@]}"; do
			if [[ "${RETROARCHIVEMENTS[$i]}" = "${PLATFORM}" ]]; then
				if [ "${2}" == "1" ]; then
					echo 'cheevos_enable = "true"' >> ${RACONF}
					get_setting "retroachievements.username"
					echo "cheevos_username = \"${EES}\""  >> ${RACONF}
					get_setting "retroachievements.password"
					echo "cheevos_password = \"${EES}\""  >> ${RACONF}

					# retroachievements_hardcore_mode
					get_setting "retroachievements.hardcore"
					[ "${EES}" == "1" ] && echo 'cheevos_hardcore_mode_enable = "true"' >> ${RACONF} || echo 'cheevos_hardcore_mode_enable = "false"' >> ${RACONF}
                        
					# retroachievements_leaderboards
					get_setting "retroachievements.leaderboards"
					[ "${EES}" == "1" ] && echo 'cheevos_leaderboards_enable = "true"' >> ${RACONF} || echo 'cheevos_leaderboards_enable = "false"' >> ${RACONF}
           
					# retroachievements_verbose_mode
					get_setting "retroachievements.verbose"
					[ "${EES}" == "1" ] && echo 'cheevos_verbose_enable = "true"' >> ${RACONF} || echo 'cheevos_verbose_enable = "false"' >> ${RACONF}
            
					# retroachievements_automatic_screenshot
					get_setting "retroachievements.screenshot"
					[ "${EES}" == "1" ] && echo 'cheevos_auto_screenshot = "true"' >> ${RACONF} || echo 'cheevos_auto_screenshot = "false"' >> ${RACONF}
				else
					echo 'cheevos_enable = "false"' >> ${RACONF}
					echo 'cheevos_username = ""' >> ${RACONF}
					echo 'cheevos_password = ""' >> ${RACONF}
					echo 'cheevos_hardcore_mode_enable = "false"' >> ${RACONF}
					echo 'cheevos_leaderboards_enable = "false"' >> ${RACONF}
					echo 'cheevos_verbose_enable = "false"' >> ${RACONF}
					echo 'cheevos_auto_screenshot = "false"' >> ${RACONF}
				fi
			fi
		done
	;; 
esac
}

function get_setting() {
#We look for the setting on the ROM first, if not found we search for platform and lastly we search globally
	PAT="s|^${PLATFORM}\[\"${ROM}\"\].*${1}=\(.*\)|\1|p"
	EES=$(sed -n "${PAT}" "${EMUCONF}")

if [ -z "${EES}" ]; then
	PAT="s|^${PLATFORM}[\.-]${1}=\(.*\)|\1|p"
	EES=$(sed -n "${PAT}" "${EMUCONF}")
fi

if [ -z "${EES}" ]; then
	PAT="s|^global[\.-].*${1}=\(.*\)|\1|p"
	EES=$(sed -n "${PAT}" "${CONF}")
fi

# Sanity check in case there there are 2 variables set, only use the first line
EES=$(echo $EES | head -1)

[ -z "${EES}" ] && EES="false"
set_setting ${1} ${EES}
}

clean_settings

for s in ratio smooth shaderset rewind autosave integerscale runahead secondinstance retroachievements ai_service_enabled; do
get_setting $s
[ -z "${EES}" ] || SETF=1
done

if [ $SETF == 0 ]; then
# If no setting was changed, set all options to default on the configuration files
default_settings
fi

if [ "${CORE}" == "atari800" ]; then
ATARICONF="/storage/.config/emuelec/configs/atari800.cfg"
sed -i "/atari800_system =/d" ${RACORECONF}
sed -i "/RAM_SIZE=/d" ${ATARICONF}
sed -i "/STEREO_POKEY=/d" ${ATARICONF}
sed -i "/BUILTIN_BASIC=/d" ${ATARICONF}

	if [ "${PLATFORM}" == "atari5200" ]; then
			echo "atari800_system = \"5200\"" >> ${RACORECONF}
            echo "RAM_SIZE=16" >> ${ATARICONF}
            echo "STEREO_POKEY=0" >> ${ATARICONF}
            echo "BUILTIN_BASIC=0" >> ${ATARICONF}
	else
			echo "atari800_system = \"800XL (64K)\"" >> ${RACORECONF}
            echo "RAM_SIZE=64" >> ${ATARICONF}
            echo "STEREO_POKEY=1" >> ${ATARICONF}
            echo "BUILTIN_BASIC=1" >> ${ATARICONF}
 	fi
fi

if [ "${CORE}" == "gambatte" ]; then
sed -i "/gambatte_gb_colorization =/d" ${RACORECONF}
sed -i "/gambatte_gb_internal_palette =/d" ${RACORECONF}

		get_setting "renderer.colorization"
		if [ "${EES}" == "false" ] || [ "${EES}" == "auto" ] || [ "${EES}" == "none" ]; then
			echo "gambatte_gb_colorization = \"disabled\"" >> ${RACORECONF}
			echo "gambatte_gb_internal_palette = \"\"" >> ${RACORECONF}
		else
			echo "gambatte_gb_colorization = \"internal\"" >> ${RACORECONF}
			echo "gambatte_gb_internal_palette = \"${EES}\"" >> ${RACORECONF}
		fi
	fi

# We set up the controller index
CONTROLLERS="$@"
CONTROLLERS="${CONTROLLERS#*--controllers=*}"

for i in 1 2 3 4 5; do 
if [[ "$CONTROLLERS" == *p${i}* ]]; then
PINDEX="${CONTROLLERS#*-p${i}index }"
PINDEX="${PINDEX%% -p${i}guid*}"
sed -i "/input_player${i}_joypad_index =/d" ${RACONF}
echo "input_player${i}_joypad_index = \"${PINDEX}\"" >> ${RACONF}

# Setting controller type for different cores
if [ "${PLATFORM}" == "atari5200" ]; then
	sed -i "/input_libretro_device_p${i}/d" ${RACONF}
	echo "input_libretro_device_p${i} = \"513\"" >> ${RACONF}
fi

fi
done
EE_DEVICE=$(cat /ee_arch)
get_setting "retroarch.menu_driver"

if [ "$EE_DEVICE" == "OdroidGoAdvance" ]; then
[ "${EES}" == "false" ] || [ "${EES}" == "none" ] || [ "${EES}" == "0" ] && EES="xmb"
else
[ "${EES}" == "false" ] || [ "${EES}" == "none" ] || [ "${EES}" == "0" ] && EES="ozone"
fi

sed -i "/menu_driver =/d" ${RACONF}
echo "menu_driver = ${EES}" >> ${RACONF}

# Show bezel if enabled
get_setting "bezel"
[ "${EES}" == "false" ] || [ "${EES}" == "none" ] || [ "${EES}" == "0" ] && ${TBASH} /emuelec/scripts/bezels.sh "default" || ${TBASH} /emuelec/scripts/bezels.sh "$PLATFORM" "${ROM}"
