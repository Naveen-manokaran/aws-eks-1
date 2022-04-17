# variable "cluster-name" {
#   default     = "eks-cluster"
#   type        = string
#   description = "The name of your EKS Cluster"
# }

# variable "k8s-version" {
#   default     = "1.21"
#   type        = string
#   description = "Required K8s version"
# }

# variable "aws-region" {
#   default     = "us-east-1"
#   type        = string
#   description = "The AWS Region to deploy EKS"
# }

# variable "availability-zones" {
#   default     = ["us-east-2a", "us-east-2b"]
#   type        = list
#   description = "The AWS AZ to deploy EKS"
# }

# variable "VPC_cidr_block" {
#   type = string
#   description = "(optional) describe your variable"
#   default = "10.0.0.0/16"
# }

# variable "instance_tenancy" {
#   type = string
#   description = "(optional) describe your variable"
#   default = "default"
# }

# variable "vpc_name" {
#   type = string
#   description = "(optional) describe your variable"
#   default = "my-vpc"
# }

# variable "subnet_private_cidr" {
#   type = string
#   description = "(optional) describe your variable"
#   default = "10.0.0.0/17"
# }
# /*
# variable "subnet_private_name" {
#   type = string
#   description = "(optional) describe your variable"
# }*/