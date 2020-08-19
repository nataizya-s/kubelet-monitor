#!/bin/bash

#VARIABLES
s3_bucket="aws-nasika-logs"

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
  if [[ "$state" == "false" ]]; then
     #zip up logs and upload them to S3
     script="eks-log-collector.sh"
     if test -f "$script"; then
        echo "Log collector script already exists..."
     else
        curl -O https://raw.githubusercontent.com/nithu0115/eks-logs-collector/master/eks-log-collector.sh
     fi
     sudo bash eks-log-collector.sh
     for f in /var/log/eks_i-*.tar.gz
     do
       echo $f
       log_file=$f
     done
     #push the logs to the specified S3 bucket
     aws s3api put-object --bucket $s3_bucket --key $log_file

     #terminate the instance so that the ASG can replace the node
     aws ec2 terminate-instances --instance-ids $instance_id
  fi
fi