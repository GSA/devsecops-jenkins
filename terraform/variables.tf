variable "aws_az1" {
  type = "string"
  description = "Must be a valid AWS availability zone"
}
variable "aws_az2" {
  type = "string"
  description = "Must be a valid AWS availability zone"
}
variable "private_vpc_zone_name" {
  type = "string"
}
variable "vpc_name" {
  type = "string"
}
variable "jenkins_key_name" {
  description = "The key pair name for the Jenkins instance. The key pair must already exist in the AWS account."
  type = "string"
}
variable "jenkins_backup_s3_bucket" {
  description = "Name of an S3 bucket to backup the jenkins configuration."
}
variable "jenkins_backup_s3_bucket_expiration_days" {
  description = "Number of days to keep a backup file"
  default = "30"
}
variable "jenkins_backup_s3_bucket_acl" {
  description = "ACL of the backup bucket"
  default = "private"
}
variable "region" {
  default = "us-east-1"
}
variable "aws_partition" {
  default = "aws"
}
variable "vpc_cidr" {
  default = "10.0.0.0/16"
}
variable "app_public_subnet_cidrs" {
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}
variable "app_private_subnet_cidrs" {
  default = ["10.0.10.0/24", "10.0.20.0/24"]
}
variable "database_subnet_cidrs" {
  default = ["10.0.100.0/24", "10.0.101.0/24"]
}
variable "create_database_subnet_group" {
  default = "true"
}
variable "enable_nat_gateway" {
  type = "string"
  default = "true"
}
variable "enable_dns_hostnames" {
  type = "string"
  default = "true"
}
variable "enable_dns_support" {
  type = "string"
  default = "true"
}
variable "app_flow_log_group_name" {
  default = "vpc_app_flow_logs"
}
variable "devsecops_iam_log_role_name" {
  default = "vpc_flow_log_role"
  description = "name for the IAM role that will be attached to the VPC logging"
}
variable "devsecops_flow_log_policy" {
  default = "vpc_flow_log_policy"
  description = "name for the log policy to attach to the VPCs"
}
variable "jenkins_sg_name" {
  description = "The name of the new Jenkins security group."
  type = "string"
  default = "sg_jenkins_master"
}
variable "jenkins_http_cidrs" {
  description = "List of CIDR ranges to allow http/https access to the instance."
  type = "list"
  default = ["0.0.0.0/0"]
}
variable "jenkins_ssh_cidrs" {
  description = "List of CIDR ranges to allow ssh access to the instances."
  type = "list"
  default = ["0.0.0.0/0"]
}
variable "jenkins_master_name" {
  description = "Name of the master instance that will be created."
  type = "string"
  default = "jenkins-master"
}
variable "jenkins_ami_id" {
  description = "AMI ID to use for the Jenkins instance."
  type = "string"
  default = "ami-a8d369c0"
}
variable "jenkins_instance_type" {
  description = "Instance type for the Jenkins instance."
  type = "string"
  default = "m4.xlarge"
}
variable "jenkins_iam_role_name" {
  description = "Name for the IAM EC2 instance role that will be created."
  type = "string"
  default = "jenkins_master_ec2_role"
}
variable "jenkins_private_master_dns" {
  description = "Private DNS hostname for the Jenkins instance"
  type = "string"
  default = "jenkins-master.devsecops.local"
}
variable "jenkins_vm_user" {
  description = "Name of the ssh user to use."
  type = "string"
  default = "ec2-user"
}
variable "jenkins_backup_s3_key" {
  description = "Folder key to use in the S3 backup bucket."
  default = "jenkins_master_backup"
}