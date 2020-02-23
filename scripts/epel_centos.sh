#!/bin/bash

centos () {

local centos_base_dir="/data/repo-data/centos/"
local centos_7_mirror_dir="/data/repo-data/centos/7"
local centos_6_mirror_dir="/data/repo-data/centos/6"


# Check if required directories exist

if [[ -d "$centos_7_mirror_dir"  && -d "$centos_6_mirror_dir" ]] ; then
for i in os/x86_64/ extras/x86_64/ os/x86_64 updates/x86_64/ centosplus/x86_64/ cr/x86_64/; do
    rsync  -avSHP --delete rsync://mirror.liquidtelecom.com/centos/7/${i}   "$centos_7_mirror_dir/${i}" && \
    rsync  -avSHP --delete rsync://mirror.liquidtelecom.com/centos/6/${i}   "$centos_6_mirror_dir/${i}" 
done

rsync  -avSHP --delete rsync://mirror.liquidtelecom.com/centos/RPM-GPG-KEY-CentOS-7	  "$centos_base_dir" && \
rsync  -avSHP --delete rsync://mirror.liquidtelecom.com/centos/RPM-GPG-KEY-CentOS-6	  "$centos_base_dir" 

fi

if [[ $? -eq '0' ]]; then
    echo ""
    echo "Sync successful.."
else
    echo " Syncing failed"
    exit 1
fi
}

epel () {

local epel6_mirror_dir="/data/repo-data/epel/6/x86_64/"
local epel7_mirror_dir="/data/repo-data/epel/7/x86_64/"
local epel_base_dir="/data/repo-data/epel/"

# Start sync

if [[ -d "$epel6_mirror_dir"  && -d "$epel7_mirror_dir" ]] ; then
   rsync  -avSHP --delete rsync://mirror.wbs.co.za/epel/6/x86_64/ "$epel6_mirror_dir" && \
   rsync  -avSHP --delete rsync://mirror.wbs.co.za/epel/7/x86_64/ "$epel7_mirror_dir" && \
   rsync  -avSHP --delete rsync://mirror.wbs.co.za/epel/RPM-GPG-KEY-EPEL-7 "$epel_base_dir" && \
   rsync  -avSHP --delete rsync://mirror.wbs.co.za/epel/RPM-GPG-KEY-EPEL-6 "$epel_base_dir"
fi

if [[ $? -eq '0' ]]; then
    echo ""
    echo "Sync successful.."
else
    echo " Syncing failed"
    exit 1
fi
}


# Call main

centos
epel

