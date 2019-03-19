#!/bin/sh

#update backup script

#does backup exist?
if ! [ -d /updateBackup ]; then
	echo $(date +%Y_%m_%d:%H:%M:%S)" Update backup dont exist! Backup \
	failed" >> /var/log/updateLog
	return 1
fi

#does manifest exist?
if ! [ -f /updateBackup/MANIFEST ]; then
	echo $(date +%Y_%m_%d:%H:%M:%S)" Update manifest dont exist! Backup\
	failed" >> /var/log/updateLog
	return 1
fi

cd /updateBackup
#read all strings from backup manifest file
updateFailure=false;
cat MANIFEST | while read tag val1 val2;
do
	if [ $tag == "process" ]; then
		killall -9 $val1;
		if [ $? != 0 ]; then
			echo $(date +%Y_%m_%d:%H:%M:%S)" Failed to kill process: \
			$val1" >> /var/log/updateLog
			updateFailure=true;
		fi
	fi
	
	if [ $tag == "file" ]; then
		if ! [ -f /updateBackup/$val1 ]; then
			echo $(date +%Y_%m_%d:%H:%M:%S)" File for change is not \
			exist /updateBackup/$val1" >> /var/log/updateLog
			updateFailure=true;
		fi
		
		if ! [ -d $val2 ]; then 
			echo $(date +%Y_%m_%d:%H:%M:%S)" Create directory \
			$val2$val1" >> /var/log/updateLog
			mkdir -p $val2;
		fi	
		
		cp $val1 $val2
		
		if ! [ $? != 0 ]; then
			echo $(date +%Y_%m_%d:%H:%M:%S)"Failed to copy file \
			$val1" >> /var/log/updateLog 
			updateFailure=true;
		fi
	fi
	
	if [ $tag == "remove" ]; then
		if [ -f /updateBackup/$val1 ]; then
			if ! [ -d $val2 ]; then 
				echo $(date +%Y_%m_%d:%H:%M:%S)" Create directory \
				$val2$val1" >> /var/log/updateLog
				mkdir -p $val2;
			fi	
			
			cp $val1 $val2
		
			if ! [ $? != 0 ]; then
				echo $(date +%Y_%m_%d:%H:%M:%S)"Failed to copy file \
				$val1" >> /var/log/updateLog 
				updateFailure=true;
			fi
		else
			pathToFile=$val2$val1
		
			if ! [ -f $pathToFile ]; then
				echo $(date +%Y_%m_%d:%H:%M:%S)" File for removing is not \
				exist $pathToFile" >> /var/log/updateLog
				updateFailure=true;
			fi
			
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
	fi
done

# rolling back backup configDb.db
cp /updateBackup/configDb.db /FisGo/
if [ $? != 0 ]; then
	echo $(date +%Y_%m_%d:%H:%M:%S)" Failed to roll back /updateBackup/configDb.db \
	 to /FisGo/ " >> /var/log/updateLog
	updateFailure=true;
fi

cd /flags
echo $(date +%Y_%m_%d:%H:%M:%S)"backup made!" >  backupWas;

reboot
