# kubelet-monitor
A script to allow the kubelet on AWS EKS worker nodes to be monitored and automatically restarted if failing.
If the restart of the kubelet fails (after 5 attempts), the node is automatically terminated. 
## Prerequisites
### IAM Permissions on Node Instance Role
1. EC2
2. S3 putObject

### Resources
1. S3 Bucket
