# Create VPC for EKS Cluster
module "vpc_for_eks" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0.0"
  providers = {
    aws = aws.target_region
  }

  name = local.vpc_name
  cidr = "10.0.0.0/16"

  azs                          = ["${var.eks_region}a", "${var.eks_region}b"]
  public_subnets               = ["10.0.0.0/24", "10.0.1.0/24"]
  private_subnets              = ["10.0.10.0/24", "10.0.11.0/24"]
  public_subnet_ipv6_prefixes  = [0, 1]
  private_subnet_ipv6_prefixes = [2, 3]

  enable_ipv6                                   = true
  public_subnet_assign_ipv6_address_on_creation = true
  enable_nat_gateway                            = true
  single_nat_gateway                            = true
  one_nat_gateway_per_az                        = false
  create_egress_only_igw                        = true

  enable_dns_hostnames    = true
  enable_dns_support      = true
  map_public_ip_on_launch = true # Explicitly set "auto-assign public IP" on public subnets

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
    # Tags subnets for Karpenter auto-discovery
    "karpenter.sh/discovery" = local.cluster_name
  }

}
