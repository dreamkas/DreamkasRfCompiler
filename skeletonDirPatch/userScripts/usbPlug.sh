#script, that runnung after usb hotplugged

#!/bin/sh

#/mnt exist?
echo "Flash plugged!" >> /root/usblog
if ! [-d /mnt/ ]; then
  echo "/mnt not exists!" >> /root/usblog
  cd /
  mkdir mnt
  echo "/mnt was created!" >> /root/usblog
fi

mount /dev/sda1 /mnt

if [ $? != 0 ]; then
  echo "Flash filesystem is not fat!!!" >> /root/usblog

  ntfs-32 /dev/sda1 /mnt

  if [$? != 0 ]; then
    echo "Extended fat on flash!" >> /root/usblog
  fi
fi

echo "mounting complete!!!" >> /root/usblog

#creating mount flag file
echo "mounted" > /userScripts/flashMountFlag

cd /

exit 0
