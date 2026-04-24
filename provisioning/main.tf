provider "aws" {
  region = var.eks_region
  alias  = "target_region"
}

provider "helm" {
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}

locals {
  vpc_name     = "${var.project}-vpc"
  cluster_name = "${var.project}-cluster"
  kube_version = var.kube_version

  eks_addons = toset([
    "kube-proxy",
    "vpc-cni",
    "eks-pod-identity-agent",
    "coredns"
  ])

  tags = {
    Terraform   = "true"
    Environment = "ci_runners"
    Project     = var.project
    Owner       = "Sergio"
    CreatedBy   = "terraform"
  }
}

output "kube-config" {
  description = "command to update kube context to newly created cluster"
  value       = <<EOT
Please switch Kube Context to the cluster just created
AWS_PROFILE=<optional_AWS_profile> aws eks update-kubeconfig --region ${var.eks_region} --name ${module.eks.cluster_name}
  EOT
}

output "karpenter_node_role_name" {
  value = module.karpenter.node_iam_role_name
}