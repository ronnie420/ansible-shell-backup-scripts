#!/bin/bash
logfile="/var/log/pr_dr_backups.log"
echo "Starting backup process.."
sleep 3

# Backup one by one - Avoid timeout issues
echo ""
echo "Cleaning old backups.."
sleep 3
/etc/backups/pr_dr_backups.sh prerun

echo ""
echo "Starting /etc backup.."
sleep 3
/etc/backups/pr_dr_backups.sh etc
echo ""
echo "Starting /srv backup.."
sleep 3
/etc/backups/pr_dr_backups.sh srv
echo ""
echo "Starting tomcat backup.."
sleep 3
/etc/backups/pr_dr_backups.sh tomcat
echo ""
echo "Starting /var/www backup.."
sleep 3
/etc/backups/pr_dr_backups.sh www
echo ""
echo "Starting /apps backup.."
sleep 3
/etc/backups/pr_dr_backups.sh apps
echo ""
echo "Starting all backups compression to single zip ..."
sleep 3
/etc/backups/pr_dr_backups.sh zip
echo "Uploading Yesterdays backup to s3 ..."
sleep 3
/etc/backups/pr_dr_backups.sh s3

# Check sucees status

if [[ $? -eq "0" ]]; then
    echo "" >> $logfile
    echo "PR $(date) Backup successful.." | tee -a $logfile
    exit 0
else
    echo "" >> $logfile
    echo "Backup for $(date) failed.." | tee -a $logfile
    exit 1
fi

