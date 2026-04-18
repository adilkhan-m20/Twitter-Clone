# --- 1. Network Setup (VPC) ---
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "${var.cluster_name}-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${var.aws_region}a", "${var.aws_region}b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  # REQUIRED for EKS (VERY IMPORTANT)
  public_subnet_tags = {
    "kubernetes.io/role/elb"                      = 1
    "kubernetes.io/cluster/${var.cluster_name}"   = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"             = 1
    "kubernetes.io/cluster/${var.cluster_name}"   = "shared"
  }
}

# --- 2. Kubernetes Cluster (EKS) ---
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.10.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.30"

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true

  enable_cluster_creator_admin_permissions = true

  # --- 3. Compute Nodes ---
  eks_managed_node_groups = {
    twitter_nodes = {
      instance_types = ["t3.small"]

      # AL2023 is the current standard for EKS 1.30
      ami_type = "AL2023_x86_64_STANDARD"

      min_size     = 1
      max_size     = 4
      desired_size = 3

      # (better stability)
      capacity_type = "ON_DEMAND"
    }
  }
}