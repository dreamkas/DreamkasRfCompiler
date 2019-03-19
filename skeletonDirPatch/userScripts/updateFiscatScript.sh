#!/bin/sh

#это скрипт автоматического обновления
echo $(date +%Y_%m_%d:%H:%M:%S)" Automatical update script" \
										>> /var/log/updateLog

#does update exist?
if ! [ -d /download/ ]; then
  echo $(date +%Y_%m_%d:%H:%M:%S)" New updates are not available" \
									>> /var/log/updateLog
  return 0
fi

#if updateBackup exists
if ! [ -d /updateBackup/ ]; then
	rm -r /updateBackup
	echo $(date +%Y_%m_%d:%H:%M:%S)" updateBackup removed" \
									>> /var/log/updateLog
fi

#save current date
current_date=$(date +%Y_%m_%d:%H:%M:%S)
cd /
mkdir updateBackup
touch /updateBackup/MANIFEST

echo $(date +%Y_%m_%d:%H:%M:%S)" Unpack update start!" \
									>> /var/log/updateLog
cd /download
#tar -xzvf fisGoUpdate.tar -C /download

#gunzip unpack result
#if [ $? != 0 ]; then
#  echo $(date +%Y_%m_%d:%H:%M:%S)" Unpack update failed!" \
#										>> /var/log/updateLog
#  return 1
#else
#  echo $(date +%Y_%m_%d:%H:%M:%S)" Unpack update success!" \
#										>> /var/log/updateLog
#fi

#check checksum
md5sum fisGoUpdate.tar > ourCsFile;
read ourCs trash < ourCsFile;
read inetCs < cs;

if [ "$inetCs" != "$ourCs" ]; then
	echo $(date +%Y_%m_%d:%H:%M:%S)" CS error, update aborted!" \
		 >> /var/log/updateLog
		
	#remove download directory
	rm -r /download/
	
	exit 0
fi

cd /download
mv fisGoUpdate.tar fisGoUpdate.tar.gz
gunzip fisGoUpdate.tar.gz
tar xvf fisGoUpdate.tar -C /download/

#remove archive
rm fisGoUpdate.tar

#kill all process from manifest
#read all strings from file
updateFailure=false;
cat MANIFEST | while read tag val1 val2;
do
	if [ $tag == "process" ]; then
		echo "process $val1" >> /updateBackup/MANIFEST
		
		killall -9 $val1;
		
		if [ $? != 0 ]; then
			echo $(date +%Y_%m_%d:%H:%M:%S)" Failed to kill process: \
			 $val1" >> /var/log/updateLog
		fi
	fi
	
	if [ $tag == "file" ]; then
		#if file is new
		if ! [ -d $val2 ]; then 
			echo "remove $val1 $val2" >> /updateBackup/MANIFEST
			mkdir -p $val2;
			cp $val1 $val2;
			if [ $? != 0 ]; then
				echo $(date +%Y_%m_%d:%H:%M:%S)" Failed to copy $val1 \
				 to $val2" >> /var/log/updateLog
				updateFailure=true;
			fi
			sync $val2$val1
			continue
		fi
		
		#if file need to backup
		pathToFile=$val2$val1
		echo $pathToFile
		if ! [ -f $pathToFile ]; then
			#file is new
			echo "remove $val1 $val2" >> /updateBackup/MANIFEST
			cp $val1 $val2;
			sync $val2$val1;
			continue
		else
			#old file exits
			echo "file $val1 $val2" >> /updateBackup/MANIFEST
			cp $pathToFile /updateBackup/
			sync /updateBackup/*
			
			#change files
			cp $val1 $val2;
			if [ $? != 0 ]; then
				echo $(date +%Y_%m_%d:%H:%M:%S)" Failed to copy $val1 \
				 to $val2" >> /var/log/updateLog
				updateFailure=true;
			fi
			sync $val2$val1
		fi
	fi
	
	if [ $tag == "remove" ]; then
		echo "remove $val1 $val2" >> /updateBackup/MANIFEST
		pathToFile=$val2$val1 
		
		cp $pathToFile /updateBackup/
		
		#remove file
		rm $pathToFile
		
		if [ $? != 0 ]; then
			echo $(date +%Y_%m_%d:%H:%M:%S)" Failed to remove \
			$pathToFile" >> /var/log/updateLog
			updateFailure=true;
		fi
		
		#if directory stay empty
		pathToFile=$val2
		cd $pathToFile
		filesCntInDir=$(ls -1A|wc -l);
		echo $(date +%Y_%m_%d:%H:%M:%S)" files cnt in directory = \
				$filesCntInDir"
		if [ $filesCntInDir == 0 ]; then
			rm -rf $pathToFile
		fi
	fi 
done

# backuping configDb.db
cp /FisGo/configDb.db /updateBackup/
if [ $? != 0 ]; then
	echo $(date +%Y_%m_%d:%H:%M:%S)" Failed to copy configDb.db \
	 to /updateBackup/ " >> /var/log/updateLog
	updateFailure=true;
fi

#remove download directory
rm -r /download/
#correctly update folder removed?
if ! [ -d /download/ ]; then
  echo $(date +%Y_%m_%d:%H:%M:%S)" Update folder removed correctly!" \
											>> /var/log/updateLog
else
  echo $(date +%Y_%m_%d:%H:%M:%S)" Update folder removed incorrectly" \
											>> /var/log/updateLog
fi

#flag Up!
touch /flags/flagUpd
echo "1" > /flags/flagUpd
sync /flags/flagUpd

#reboot device!
echo $(date +%Y_%m_%d:%H:%M:%S)" Reboot device after update!" \
											>> /var/log/updateLog 
reboot




