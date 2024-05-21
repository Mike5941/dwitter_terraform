locals {
  node_group_name = "${var.cluster_name}-node-group"
}

module "eks" {
  depends_on = [module.vpc]
  # 모듈 사용
  source = "terraform-aws-modules/eks/aws"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets

  eks_managed_node_group_defaults = {
    ami_type               = "AL2_x86_64" #
    disk_size              = 10           # EBS 사이즈
    instance_types         = ["t2.small"]
    vpc_security_group_ids = []

  }

  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    ("${var.cluster_name}-node-group") = {
      # node group 스케일링
      min_size     = 1 # 최소
      max_size     = 3 # 최대
      desired_size = 2 # 기본 유지

      labels = {
        ondemand = "true"
      }

      tags = {
        "k8s.io/cluster-autoscaler/enabled" : "true"
        "k8s.io/cluster-autoscaler/${var.cluster_name}" : "true"
      }
    }
  }
}

