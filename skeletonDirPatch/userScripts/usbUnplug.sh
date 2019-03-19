#script, that runnung after usb hotUnplugged

#!/bin/sh

echo "umounted" > /userScripts/flashMountFlag

umount -f /mnt
if [ $? != 0 ]; then
  echo "Umount /dev/sda1 failed!!!" >> /root/usblog
fi

rm -r /mnt
if [ $? != 0 ]; then
  echo "Removing /mnt failed!" >> /root/usblog
fi
