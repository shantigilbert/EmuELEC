#!/bin/bash

. /etc/profile

install_succesful=false
version=10  #increment this as the script is updated
INSTALLPATH="/storage/roms/"

cat > /tmp/pixelcade.txt << "EOF"
       _          _               _
 _ __ (_)_  _____| | ___ __ _  __| | ___
| '_ \| \ \/ / _ \ |/ __/ _` |/ _` |/ _ \
| |_) | |>  <  __/ | (_| (_| | (_| |  __/
| .__/|_/_/\_\___|_|\___\__,_|\__,_|\___|
|_|
EOF

cat >> /tmp/pixelcade.txt <<EOF

       Pixelcade LED Installer for EmuELEC : Installer Version ${version}

This script will install/update Pixelcade in your /storage/roms folder
Plese ensure you have at least 800 MB of free disk space in /storage/roms
Now connect Pixelcade to a free USB port on your device (Odroid, Android Box, etc)
Ensure the toggle switch on the Pixelcade board is pointing towards USB and not BT
The installer will not run unless the Pixelcade hardware is connected
Grab a coffee or tea as this installer will take around 15 minutes

You may also re-run this installer later to update marquee artwork

Would you like to continue?
EOF

text_viewer -w -y -t "Pixelcade LED Marquee Installer" -f 24 /tmp/pixelcade.txt
    if [[ $? != 21 ]]; then
        text_viewer -w -t "Installation canceled!" -f 24 -m "Pixelcade installation canceled! press start or A to exit!"
        exit 0
    fi

# let's detect if Pixelcade is USB connected, could be 0 or 1 so we need to check both
if ls /dev/ttyACM0 | grep -q '/dev/ttyACM0'; then
   echo "Pixelcade LED Marquee Detected on ttyACM0"
else
    if ls /dev/ttyACM1 | grep -q '/dev/ttyACM1'; then
        echo "Pixelcade LED Marquee Detected on ttyACM1"
    else
       text_viewer -e -w -t "ERROR: PixelCade Not Detected!" -f 24 -m "Sorry, Pixelcade LED Marquee was not detected, pleasse ensure Pixelcade is USB connected to your EmuELEC device and the toggle switch on the Pixelcade board is pointing towards USB, exiting..."
       exit 1
    fi
fi

cat > /tmp/pixelcade_install.rc <<EOF
#!/bin/bash

. /etc/profile

machine_arch=arm64
INSTALLPATH="${INSTALLPATH}"

EOF

cat >> /tmp/pixelcade_install.rc << "EOF"

if [[ -f "${INSTALLPATH}master.zip" ]]; then #if the user killed the installer mid-stream,it's possible this file is still there so let's remove it to be sure before downloading, otherwise wget will download and rename to .1
   rm "${INSTALLPATH}master.zip"
fi

echo "Stopping Pixelcade (if running...)"
# let's make sure pixelweb is not already running
killall java >/dev/null 2>&1 #in the case user has java pixelweb running
curl localhost:8080/quit >/dev/null 2>&1

mkdir -p ${INSTALLPATH}pixelcade
cd ${INSTALLPATH}pixelcade

wget -O ${INSTALLPATH}pixelcade/pixelweb https://github.com/alinke/pixelcade-linux-builds/raw/main/linux_${machine_arch}/pixelweb
chmod +x pixelweb

#install the artwork
 echo "Installing artwork, this can take a few minutes, please be patient even if it looks like it's stuck!"
./pixelweb -install-artwork

if [[ $? == 2 ]]; then #this means artwork is already installed so let's check for updates and get if so
  echo "Checking for new Pixelcade artwork..."
  cd ${INSTALLPATH}pixelcade && ./pixelweb -update-artwork
fi

echo "Artwork installation done!"

if [[ -d ${INSTALLPATH}ptemp ]]; then
    rm -r ${INSTALLPATH}ptemp
fi

#creating a temp dir for the Pixelcade common system files & scripts
mkdir -p ${INSTALLPATH}ptemp
cd ${INSTALLPATH}ptemp

#get the Pixelcade system files
wget -O ${INSTALLPATH}ptemp/main.zip https://github.com/alinke/pixelcade-linux/archive/refs/heads/main.zip
unzip main.zip
mkdir -p /storage/.emulationstation/scripts

#copy over the custom scripts
echo "${yellow}Installing Pixelcade EmulationStation Scripts...${white}"
cp -r -f ${INSTALLPATH}ptemp/pixelcade-linux-main/emuelec/scripts /storage/.emulationstation #note this will overwrite existing scripts
find /storage/.emulationstation/scripts -type f -iname "*.sh" -exec chmod +x {} \; #make all the scripts executble

#hi2txt for high score scrolling
echo "${yellow}Installing hi2txt for High Scores...${white}"
cp -r -f ${INSTALLPATH}ptemp/pixelcade-linux-main/hi2txt ${INSTALLPATH} #for high scores

sed -i '/all,mame/d' ${INSTALLPATH}pixelcade/console.csv
sed -i '/favorites,mame/d' ${INSTALLPATH}pixelcade/console.csv
sed -i '/recent,mame/d' ${INSTALLPATH}pixelcade/console.csv
sed -i '/fbn,mame/d' ${INSTALLPATH}pixelcade/console.csv

if cat /storage/.config/custom_start.sh | grep "^[^#;]" | grep -q 'java'; then  #ignore any comment line, user has the old java pixelweb, we need to comment out this line and replace
    echo "Backing up custom.sh to custom.bak"
    cp /storage/.config/custom_start.sh /storage/.config/custom_start.bak
    echo "Replacing old java pixelweb with new pixelweb"
    sed -i "/java -jar pixelweb.jar/c\cd ${INSTALLPATH}pixelcade && ./pixelweb -image "system/emuelec.png" -startup &" /storage/.config/custom_start.sh #comment out the line
    sed -i "s|pixelweb.jar|pixelweb|" /storage/.config/custom_start.sh
fi

if cat /storage/.config/custom_start.sh | grep -q 'pixelweb -image'; then
    echo "Pixelcade was already added to custom_start.sh, skipping..."
else
    echo "Adding Pixelcade Listener auto start to custom_start.sh ..."
    sed -i "/^"before")/a cd ${INSTALLPATH}pixelcade && ./pixelweb -image "system/emuelec.png" -startup &" /storage/.config/custom_start.sh  #insert this line after "before"
fi

chmod +x /storage/.config/custom_start.sh

echo "Cleaning up..."
rm -r ${INSTALLPATH}ptemp >/dev/null 2>&1

exit 0 
EOF
chmod +x /tmp/pixelcade_install.rc

killall java >/dev/null 2>&1

# Lets check if java is installed and up to date, called from profile
install_java

# Install Pixelcade software
progressor --log "/emuelec/logs/install_pixelcade.log" --title "Installing Pixelcade, please wait..." "/tmp/pixelcade_install.rc" --font "dummy.ttf"

         if [[ $? == 0 && -f ${INSTALLPATH}pixelcade/pixelweb && -d ${INSTALLPATH}pixelcade ]]; then
          cd ${INSTALLPATH}pixelcade && ./pixelweb -image "system/emuelec.png" -startup >/dev/null 2>&1 &
           pixelcade_version="$(cd ${INSTALLPATH}pixelcade && ./pixelweb -version)"
           text_viewer -y -w -t "Installation complete!" -f 24 -m "PixelCade Version: ${pixelcade_version} INSTALLATION COMPLETE, The EmuELEC logo should now be displayed. If you don't see the logo, please reboot and then Pixelcade will be controlled by EmuELEC, would you like to reboot now?"
            if [[ $? == 21 ]]; then
               systemctl reboot
            fi
         else
           text_viewer -e -w -t "ERROR: Installation incomplete!" -f 24 -m "Something went wrong! Please make sure you have enough disk space and are connnected to the internet!"
         fi
# Delete temporary files
rm -rf /tmp/pixelcade* >/dev/null 2>&1
exit 0
