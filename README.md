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

### Things to take note of
## Node Draining



