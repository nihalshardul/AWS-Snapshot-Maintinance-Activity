#!/bin/bash


helpFunction()
{
   echo ""
   echo "Usage: $0 -t Tag -m Month"
   echo -e "\t-t tag"
   echo -e "\t-m month"
   echo -e "\t-y year [Optional]"
   exit 1 # Exit script after printing help
}

while getopts t:m:y: options; do
	case $options in
		t) t=$OPTARG;;
		m) m=$OPTARG;;
		y) y=$OPTARG;;
	esac
done

if [ -z "$y" ]
then
	y=$(date +"%Y")
fi

if [ -z "$t" ] 	|| [ -z "$m" ]
then
   echo "Some or all of the parameters are empty";
   helpFunction
fi

mn=$m
sm=$(echo $m | awk '{printf "%01d\n",(index("JanFebMarAprMayJunJulAugSepOctNovDec",$0)+2)/3}')


size=${#sm}
if [[ $size == 1 ]]
then
	m='0'$sm
else
        m=$sm
fi

td=$t'_'$mn'_'$y.log

lg=$(pwd)
l=$lg'/'$td
exec > >(tee -i $td)
exec 2>&1

d=01


st=$(date +"$y-$m-$d")
fixd=27
fixdate=$(date +"$y-$m-$fixd")



siz=$((sm+1))

si=${#siz}
if [[ $si == 1 ]]
then
	m='0'$siz
else
        m=$siz
fi

if [[ $m == 13 ]]
then
	m=01
	y=$((y+1))
fi

et=$(date +"$y-$m-$d")

n=nautilian.snapshot.kubernetes.namespace

echo -e "\n From 	: $st "
echo -e "\n To   	: $et "
echo -e "\n Namespace 	: $n "
echo -e "\n Tag 	: $t "
echo -e "\n Log_File 	: $l "

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
		aws ec2 delete-snapshot --snapshot-id $snp
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
echo -e "\n Total number of deleted Snapshotes : $ds"
echo -e "\n----------------------------------------------------------------------------------------------------------------------------"

