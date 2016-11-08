#!/bin/bash
: > ${module_path}/master_ips.txt

for i in `aws autoscaling describe-auto-scaling-groups --auto-scaling-group-name ${master_asg_name} | grep -i instanceid  | awk '{ print $2}' | cut -d',' -f1| sed -e 's/"//g'`
do
aws ec2 describe-instances --instance-ids $i | grep -i PrivateIpAddress | awk '{ print $2 }' | head -1 | cut -d"," -f1 | tr -d '"' | tr '\n' ',' >> ${module_path}/master_ips.txt;
done;

sed -i 's/,$//' ${module_path}/master_ips.txt && echo $(cat ${module_path}/master_ips.txt) > ${module_path}/master_ips.txt
