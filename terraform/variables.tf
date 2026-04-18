variable "aws_region" {
  description = "The AWS region to deploy the cluster in"
  type        = string
  default     = "ap-south-1"
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = "twitter-clone-eks"
}