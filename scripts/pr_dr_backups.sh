#!/bin/bash
set -eu
#########################################################
## Author - Ronnie
## Email  -ronnymbuthia@gmail.com --> 07/06/2018
########################################################

# Glabal variables
backupDir="/data/HubBackup"
day=`date "+%d-%m-%y"`
day_yesteday=`date -d "1 day ago" '+%d-%m-%y'`
run_func="$@"
log_file="/var/log/upload_backups.log"
s_hostname=`hostname -s`

# Backup functions
pre_run () {
    mkdir -p /data/HubBackup 2>/dev/null
    local logfile="/var/log/datacleanUp.log"
    # Clean old backups
    find /data/HubBackup/ -name "${s_hostname}-BackupDownload*" -mtime +7 -print -exec rm -rf {} \; 2>/dev/null
    find /data/HubBackup/ -name "backups*"  -mtime +7 -print -exec rm -rf {} \; 2>/dev/null
    cd $backupDir
    if [ -f $backupDir/${s_hostname}-BackupDownload.zip ]; then
        mv $backupDir/${s_hostname}-BackupDownload.zip $backupDir/${s_hostname}-BackupDownload-$day_yesteday.zip
        rm -f $backupDir/*tar.gz
    else
        echo "$backupDir/${s_hostname}-BackupDownload.zip doesn't exist"
        rm -f $backupDir/*.tar.gz
    fi
}

backup_etc () {
    local etc_backup_dirs=`ls /etc/ | egrep -o "zabbix|telegraf|httpd|pki|rc.d|nagios|crontab|logrotate.d|php.ini|tripwire|applications|monit.d|monit.conf"`
    local appDir="/etc"
    local todaydir="$backupDir/etc-$day"
    cd $appDir

    # Start backup process
    echo "Archiving the $appDir Dir ($etc_backup_dirs) to $todaydir.tar.gz"
    tar -zcf $todaydir.tar.gz $etc_backup_dirs 2>/dev/null
}

backup_tomcat () {
    local tomcat_backup_dirs=`ls /usr/share/ | grep apache-`
    if [[ -z $tomcat_backup_dirs ]]; then
        echo "Apache not configured.."
    else
        local appDir="/usr/share/"
        local todaydir="$backupDir/tomcat7-$day"
        cd $appDir
        echo "Archiving the $appDir Dir ($tomcat_backup_dirs) to $todaydir.tar.gz"
        tar -zcf $todaydir.tar.gz $tomcat_backup_dirs 2>/dev/null
    fi
}

backup_apps () {
    local apps_backup_dirs=`ls /apps/ | egrep -v "logs|backupScripts|RestoreScriptsbak|finishefinised" | grep -v lost+found`
    if [[ -z $apps_backup_dirs ]]; then
        echo "/apps directory is empty"
    else
        local appDir="/apps"
        local todaydir=$backupDir/apps-$day
        cd $appDir
        echo "Archiving the $appDir Dir ($apps_backup_dirs) to $todaydir.tar.gz"
        tar -zcf $todaydir.tar.gz $apps_backup_dirs 2>/dev/null
    fi
}

backup_www () {
    local www_backup_dirs=`ls /var/www | egrep -v "logs|html-49000|finishefinised|error|cgi-bin|icons" | grep -v lost+found`
    if [[ -z $www_backup_dirs ]]; then
        echo "/var/www/ empty.. Skipping!"
    else
        local appDir=/var/www
        local todaydir=$backupDir/var_www_backup-$day
        cd $appDir
        echo "Archiving the $appDir Dir ($www_backup_dirs) to $todaydir.tar.gz"
        tar -zcf $todaydir.tar.gz $www_backup_dirs 2>/dev/null
    fi
}

backup_srv () {
    local srv_backup_dirs=`ls /srv | egrep -v "finishefinised"`
    if [[ -z $srv_backup_dirs ]]; then
        echo "/srv dir is empty.. Skipping!"
    else
        local appDir=/srv
        local todaydir=$backupDir/srv_backup-$day
        cd $appDir
        echo "Archiving the $appDir Dir ($srv_backup_dirs) to $todaydir.tar.gz"
        tar -zcf $todaydir.tar.gz $srv_backup_dirs 2>/dev/null
    fi

}

zip_all () {
    if [[ $? -eq '0' ]]; then
        echo ":: Combining tar archives to zip file.."
        cd $backupDir
        zip -9 ${s_hostname}-BackupDownload.zip *.tar.gz
    else
        echo "Backup process failed"
        exit 199
    fi
}

backup_s3 () {
    aws_cli=`which aws`
    if [[ $? -eq '0' ]]; then
        # Push yesterday's backup to s3
        echo "Uploading Yesterday's backup to S3" | tee -a $log_file
        upload_file="$backupDir/${s_hostname}-BackupDownload-$day_yesteday.zip"
        local month=`date -d "1 day ago" '+%m'`
        local year=`date -d "1 day ago" '+%Y'`
        local s3_bucket="s3://cellulantbucket/Apps/ServerBackups/$s_hostname/$year/$month/"
        $aws_cli s3 cp ${upload_file} ${s3_bucket}
    else
        echo "AWS CLI is not configured.."
        exit 1
    fi
}


###################################
# Main Script Logic Starts Here   #
###################################
if [[ $run_func == "" ]]; then
    run_func="all"
fi

# Start case
case "$run_func" in
        prerun)
                pre_run
                ;;
        etc)
                backup_etc
                ;;
        apps)
                backup_apps
                ;;
        srv)
                backup_srv
                ;;
        tomcat)
                backup_tomcat
                ;;
        www)
                backup_www
                ;;
        zip)
                zip_all
                ;;
        s3)
            backup_s3
            ;;
        all)
            pre_run
            backup_srv
            backup_etc
            backup_apps
            backup_tomcat
            backup_www
            zip_all
            backup_s3
esac

