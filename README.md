# kubelet-monitor
A script to allow the kubelet on AWS EKS worker nodes to be monitored and automatically restarted if failing.
If the restart of the kubelet fails (after 5 attempts), the logs on the node are collected and the node is automatically terminated. 

The logs on the worker node are collected using the script [here](https://github.com/nithu0115/eks-logs-collector).

This script can be added to the userdata of the worker nodes (i.e. via the launch template/launch configuration).

## Prerequisites
### IAM Permissions on Node Instance Role
| IAM Action        | Reason      |
| ------------- |:-------------:| 
| ec2:TerminateInstances | This will be needed to allow the script to terminate the instance when the kubelet fails to start. | 
| s3:PutObject | This will be used to push the collected logs from the instance to a the specified S3 bucket |

### Resources
| Resource        | Description      |
| ------------- |:-------------:|
| S3 Bucket | This needs to be set in the healthchecker.sh script where the "s3_bucket" variable is set. Replace the <S3-Bucket-Name> with your existing bucket that the logs will be pushed to. Please note that the bucket policy needs to allow the worker node instance role as well. | 

### How to make the script work
Once the script is added to the userdata, it will also be important to create a cron for the script to run on a regular schedule. For example, the cron could run the healthchecker.sh script every 5 minutes by using the following cron:

        */5 * * * * ./var/healthchecker.sh
        
It must be noted that this cron needs to be added to the userdata as well to ensure that it is configured for every worker node in the nodegroup. Steps on how to setup a cron can be found [here](https://phoenixnap.com/kb/set-up-cron-job-linux).

### Things to note

#### Node Draining
The script does not drain the node before the node is terminated. This would mean that there may be downtime if the node has pods on it that are running but aren't managed by a controller. 

#### Script Changes
Feel free to make changes to the script to make it more robust and consider best practices. This script just offers a base to allow for automated management of worker nodes and ensure that they are highly available and self healing. 


