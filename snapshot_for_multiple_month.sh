#!/bin/bash


helpFunction()
{
   echo ""
   echo "Usage: $0 -t Tag -s From Month -e To Month"
   echo -e "\t-t tag"
   echo -e "\t-s From Month"
   echo -e "\t-e To Month"
   echo -e "\t-y year [Optional]"
   exit 1 # Exit script after printing help
}

while getopts t:s:e:y: options; do
	case $options in
		t) t=$OPTARG;;
		s) s=$OPTARG;;
		e) e=$OPTARG;;
		y) y=$OPTARG;;
	esac
done

if [ -z "$y" ]
then
        y=$(date +"%Y")
fi

if [ -z "$t" ] 	|| [ -z "$s" ] || [ -z "$e" ]
then
   echo "Some or all of the parameters are empty";
   helpFunction
fi

from=$(echo $s | awk '{printf "%01d\n",(index("JanFebMarAprMayJunJulAugSepOctNovDec",$0)+2)/3}')
to=$(echo $e | awk '{printf "%01d\n",(index("JanFebMarAprMayJunJulAugSepOctNovDec",$0)+2)/3}')
td=$t'_'$s'_'$e'_'$y.log
lg=$(pwd)
l=$lg'/'$td
exec > >(tee -i $td)
exec 2>&1

ds=0

d=01
n=nautilian.snapshot.kubernetes.namespace
fixd=27

echo -e "----------------------------------------------------------------------------------------------------------------------------"

read -r -p " Are you sure? [y/N] " response
if [[ ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
        exit 0
fi

lnm=$(logname)
ds=0

echo -e "\n Snapshots deletion done by : $lnm \n"


echo -e "----------------------------------------------------------------------------------------------------------------------------"


while [ $from != $to ];do


	size=${#from}
	if [[ $size == 1 ]]
	then
		m='0'$from
	else
		m=$from
	fi
	
	st=$(date +"$y-$m-$d")
	fixdate=$(date +"$y-$m-$fixd")
	from=$[$from+1]

	size=${#from}

	if [[ $size == 1 ]]
	then
		nm='0'$from
	else
		nm=$from
	fi
	
	if [[ $nm == 13 ]]
	then
        	nm=01
		from=1
        	y=$((y+1))
	fi
	
	et=$(date +"$y-$nm-$d")

	echo -e "\n From 	: $st "
	echo -e "\n To   	: $et "
	echo -e "\n Namespace 	: $n "
	echo -e "\n Tag 	: $t "
	echo -e "\n Log_File 	: $l "
	
	snapshots_to_delete=$(aws ec2 describe-snapshots --filter Name=tag:$n,Values=$t --query "Snapshots[?(StartTime>='$st') && (StartTime<='$et')].SnapshotId" --output text)

	echo -e "\n Total Snapshots :\n "
	echo -e "$snapshots_to_delete"

	echo -e "----------------------------------------------------------------------------------------------------------------------------"
	echo -e "\n Listing Snapshot_Id with their respective dates..."
	echo -e "\n Snapshot_Id 	==> Date"


	for snp in $snapshots_to_delete;do
		sd=$(aws ec2 describe-snapshots --snapshot-ids $snp | grep StartTime | cut -b 27-36)
		if [[ $fixdate == $sd ]]
		then
			echo -e "\n $snp ==> $sd	--	No need to delete this snapshot" 
		else
			echo -e "\n $snp ==> $sd	--	Deleting this SnapShot" 	
			#aws ec2 delete-snapshot --snapshot-id $snp
			if [[ $? == 0 ]]
			then
				echo -e " Snapshot : $snp -- Deleted "
				ds=$[$ds+1]
			else
				echo -e " Failed to delete snapshot : $snp "
			fi
		fi
	done
	echo -e "\n----------------------------------------------------------------------------------------------------------------------------"
done

echo -e "\n Total number of deleted Snapshotes : $ds"
echo -e "\n----------------------------------------------------------------------------------------------------------------------------"
