#!/bin/bash

function checkbin() {
    type -P su-exec
}

function su_mt_user() {
    su android -c '"$0" "$@"' -- "$@"
}

if [[ $EMULATOR == "" ]]; then
    EMULATOR="android-26"
    echo "Using default emulator $EMULATOR"
fi

if [[ $ARCH == "" ]]; then
    ARCH="x86"
    echo "Using default arch $ARCH"
fi
echo EMULATOR  = "Requested API: ${EMULATOR} (${ARCH}) emulator."


chown android:android /opt/android-sdk-linux

if checkbin; then
    exec su-exec android:android /opt/tools/android-sdk-update.sh "$@"
else
    su_mt_user /opt/tools/android-sdk-update.sh ${1}
fi

ip=$(ifconfig  | grep 'inet'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $2}')
socat tcp-listen:5037,bind=$ip,fork tcp:127.0.0.1:5037 &
socat tcp-listen:5554,bind=$ip,fork tcp:127.0.0.1:5554 &
socat tcp-listen:5555,bind=$ip,fork tcp:127.0.0.1:5555 &

if [[ $ARCH == *"x86"* ]]
then 
    EMU="x86"
else
    EMU="arm"
fi

sdkmanager --list

# echo "no" | /opt/android-sdk-linux/tools/android create avd -f -n test -t ${EMULATOR} --abi default/${ARCH}
echo "no" | /opt/android-sdk-linux/tools/bin/avdmanager create avd -n test -k "system-images;${EMULATOR};google_apis_playstore;${ARCH}" 
echo "no" | /opt/android-sdk-linux/tools/emulator -avd test -noaudio -no-window -gpu off -verbose -qemu -usbdevice tablet -vnc :0