#!/bin/bash
# Author - Josphat Mutai
set -e
date_format=`date +%d_%m_%Y`
log_file="/var/log/upload_logs.log"
aws_bin="/usr/bin/aws"
s_host_name=`hostname -s`

upload_ke () {
cd /data/ke/hub/Application

# Find compressed logs older than 3 days
file_list=`find  . -name "*.gz" -type f -mtime +3`

# Upload log files to s3
for i in ${file_list[@]}; do
    file=`echo "${i#./}"`
    month=`echo $file  | grep -o -E '[0-9]{8}' | cut -c 5-6`
    year=`echo  $file  | grep -o -E '[0-9]{8}' | cut -c 1-4`
    s3_bucket="s3://cellulantbucket/Apps/logs/$s_host_name/$year/$month"
    echo "" >> $log_file
    echo "Uploading  $i to s3" | tee -a $log_file
    $aws_bin s3 cp  $file ${s3_bucket}/ke/$file
    if [[ $? -eq '0' ]]; then
        echo "" >> $log_file
        echo "Upload of $i to s3 successful.." | tee -a $log_file
        echo  "Deleting file $i"
        rm $i
    else
        echo ":: Upload of $i to s3 failed.." >> $log_file
fi
done
}

# Call function
upload_ke

