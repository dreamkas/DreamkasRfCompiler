#!/bin/sh

#update correct check script

#we must not to check correct of updates
if ! [ -f /flags/flagUpd ]; then
	exit 0
fi

read var < /flags/flagUpd;

#we must not to check correct of updates
if [ $var -eq "0" ]; then
	exit 0
fi

echo $(date +%Y_%m_%d:%H:%M:%S)" Update correct check script!" \
								>> /var/log/updateLog

#counters
secsCnt=0;
timeoutSecs=15;
fiscatProcessesCnt=0;

#flags
isWorkingFlag=0;
isNeedBackUp=0;

while :
do
	procCnt=$(pgrep fiscat|wc -l);
	
	if [ $procCnt -eq 1 ]; then
		isWorkingFlag=1;
		echo $(date +%Y_%m_%d:%H:%M:%S)"Process started!" \
										>> /var/log/updateLog
		#echo "Process started!"
	else
		isWorkingFlag=0;
		echo $(date +%Y_%m_%d:%H:%M:%S)"Process stoped!" \
										>> /var/log/updateLog
		#echo "Process stopped!"
	fi
	
	if [ $secsCnt -eq $((timeoutSecs-1)) ]; then
		if ! [ $isWorkingFlag -eq 1 ]; then
			echo $(date +%Y_%m_%d:%H:%M:%S)"Process not started! \
									Need backup!" >> /var/log/updateLog
			isNeedBackUp=1;
			#echo "Updated process not started!"
			break
		else
			echo $(date +%Y_%m_%d:%H:%M:%S)"Upd proc started good! \
								       " >> /var/log/updateLog
			#echo "Updated process started!"
			break
		fi
	fi
	
	sleep 1
	secsCnt=$((secsCnt+1));
done

if [ $isNeedBackUp -eq 1 ]; then
	echo $(date +%Y_%m_%d:%H:%M:%S)"Backup start!" \
										>> /var/log/updateLog
	./updateBackupScript.sh
fi

exit 0
