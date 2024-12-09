# AWS-Snapshot-Maintinance-Activity

We will write a script which will fetch snapshot from specific month and delete all snapshot except 27th date of that month, as we want to have a backup of 27th date for each month.
We will create two script: 
1- for one month
2- for dynamic month with year 

Below data contain basic information about, how script will work and what will be the flow of those script.

1. snapshot_for_one_month.sh =
			This script needs parameter -t, -m and -y[optional] where -t refers to tag-name, -m refers to month (Should be given three letters as 1st one Capital e.g. Jul) and -y refers to year which is optional parameter i.e. If want to delete month snapshot from current year then no need to give -y parameter, else give year from which you want to delete specific month snapshots.   This script will delete given month snapshots exept date 27th. Log File for same will  be created as tag-name_Monthname.log  e.g. psp-prod_Jul.log
		format -  	./snapshot_for_one_month.sh -t fs-prod -m Dec  		-- for current year
				./snapshot_for_one_month.sh -t fs-prod -m Dec -y 2021	-- for current year
				./snapshot_for_one_month.sh -t fs-prod -m Dec -y 2020	-- for previous year

2. snapshot_for_multiple_period.sh =
			This script needs parameter -t, -s, -e and -y[optional] where -t refers to tag-name, -s refers to start month, -e refers to end month  (Should be given three letters as 1st one Capital e.g. Jul) and -y refers to year which is optional parameter i.e. If want to delete months snapshot from current year then no need to give -y parameter, else give year from which you want to delete start month snapshots. This script will delete given months snapshots exept date 27th. It will delete snapshots from start month to end months starting. e.g. If want to delete snapshots from June to Aug, then -s parameter will be June (as it will take 01-Jun) and -e parameter will be Sep (as it will take 01-Sep). So, condition for this will be 01-June<= snapshots < 01-Sep. This way it will delete all the snapshots from 01-Jun to 31-Aug. Log File for same will  be created as     tag-name_StartMonthname_EndMonthname.log  e.g. psp-prod_Jun_Jul.log
		format -	./snapshot_for_multiple_month.sh -t fs-prod -s Jun -e Aug		-- for current year
				./snapshot_for_multiple_month.sh -t fs-prod -s May -e Aug -y 2021	-- for current year
				./snapshot_for_multiple_month.sh -t fs-prod -s Dec -e Feb -y 2020	-- for previous year (year should be related to start month)
