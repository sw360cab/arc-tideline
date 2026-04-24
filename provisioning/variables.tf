variable "project" {
  default = "custom_ci"
}

variable "eks_region" {
  type        = string
  description = "AWS region where resources should be provisioned"
  default     = "eu-north-1"
}

variable "kube_version" {
  type        = string
  description = "Kubernetes Version used in the current cluster"
  default     = "1.33"
}

variable "node_groups" {
  description = "node groups configs"
  type        = any
  default = {
    generic = {
      instance_type = ["t3.large"]
      ami_type      = "BOTTLEROCKET_x86_64"
      desired_size  = 2
      min_size      = 1
      max_size      = 3
    },
    karpenter = {
      instance_types = ["t3.large"]
      ami_type       = "BOTTLEROCKET_x86_64"
      desired_size   = 1
      min_size       = 1
      max_size       = 2
      labels = {
        # Used to ensure Karpenter runs on nodes that it does not manage
        "karpenter.sh/controller" = "true"
      }
    }
  }
}