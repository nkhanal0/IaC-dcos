#!/bin/bash
: > agent_ips.txt
: > ${instance_id_output_file_name}
for i in `aws autoscaling describe-auto-scaling-groups --auto-scaling-group-name ${public_agent_autoscaling_group_name} | grep -i instanceid  | awk '{ print $2}' | cut -d',' -f1| sed -e 's/"//g'`
do
aws ec2 describe-instances --instance-ids $i | grep -i PrivateIpAddress | awk '{ print $2 }' | head -1 | cut -d"," -f1 | tr -d '"' | tr '\n' ',' >> agent_ips.txt;
aws ec2 describe-instances --instance-ids $i | grep -i InstanceId | awk '{ print $2 }' | head -1 | cut -d"," -f1 | tr -d '"' | tr '\n' ',' >> ${instance_id_output_file_name};
done;
for i in `aws autoscaling describe-auto-scaling-groups --auto-scaling-group-name ${private_agent_autoscaling_group_name} | grep -i instanceid  | awk '{ print $2}' | cut -d',' -f1| sed -e 's/"//g'`
do
aws ec2 describe-instances --instance-ids $i | grep -i PrivateIpAddress | awk '{ print $2 }' | head -1 | cut -d"," -f1 | tr -d '"' | tr '\n' ',' >> agent_ips.txt;
done;
sed -i 's/,$//' agent_ips.txt && echo agent_ips = \"$(cat agent_ips.txt)\" >> $HOME/terraform.out
echo $(cat agent_ips.txt) > agent_ips.txt
sed -i 's/,$//' ${instance_id_output_file_name} && echo public_agent_ids = \"$(cat ${instance_id_output_file_name})\" >> $HOME/terraform.out
echo $(cat ${instance_id_output_file_name}) > ${instance_id_output_file_name}
