#!/bin/bash

#VARIABLES
s3_bucket =

instance_id=$(wget -q -O - http://169.254.169.254/latest/meta-data/instance-id)
echo "Instance ID is "$instance_id

check=$(systemctl status kubelet | grep "Active")
echo $check

Active="Active: active (running)"
Inactive="Active: inactive (dead)"

state="false"
if [[ "$check" == *"$Active"* ]]; then
  echo "Kubelet is active"
  #aws autoscaling set-instance-health --instance-id $instance_id --health-status Unhealthy
else
  for i in {1..5}
  do
    echo "Kubelet is inactive, trying to restart... Attempt" [$i]
    systemctl start kubelet
    sleep 10
    if [[ "$check" == *"$Inactive"* ]]; then
      echo "Failed to start kubelet..."
      state="false"
      continue
    else
      echo "Kubelet has been restarted successfully..."
      state="true"
      break
    fi
  done
  if [[ "$state" == "false" ]] then
     #zip up logs and upload them to S3
     curl -O https://raw.githubusercontent.com/nithu0115/eks-logs-collector/master/eks-log-collector.sh
     sudo bash eks-log-collector.sh


fi
