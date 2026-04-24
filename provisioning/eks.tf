module "eks" {
  source = "terraform-aws-modules/eks/aws"

  providers = {
    aws = aws.target_region
  }
  name               = local.cluster_name
  kubernetes_version = local.kube_version

  # Gives Terraform identity admin access to cluster which will
  # allow deploying resources (Karpenter) into the cluster
  enable_cluster_creator_admin_permissions = true
  endpoint_public_access                   = true

  addons = {
    coredns = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy = {}
    vpc-cni = {
      before_compute = true
    }
  }

  vpc_id     = module.vpc_for_eks.vpc_id
  subnet_ids = module.vpc_for_eks.private_subnets

  eks_managed_node_groups = var.node_groups
  enabled_log_types       = ["scheduler", "controllerManager"]
  node_security_group_tags = merge(local.tags, {
    # NOTE - if creating multiple security groups with this module, only tag the
    # security group that Karpenter should utilize with the following tag
    # (i.e. - at most, only one security group should have this tag in your account)
    "karpenter.sh/discovery" = local.cluster_name
  })

  tags = local.tags
}
