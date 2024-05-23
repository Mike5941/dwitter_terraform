# EKS 서비스만 이 역할을 수행할 수 있도록 하는 ROLE
resource "aws_iam_role" "eks" {
  name = "${local.env}-${local.eks_name}-eks-cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "eks.amazonaws.com"
      }
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks.name
}

resource "aws_eks_cluster" "eks" {
  name     = "${local.env}-${local.eks_name}"
  version  = local.eks_version
  role_arn = aws_iam_role.eks.arn

  vpc_config {
    endpoint_private_access = false
    endpoint_public_access  = true


    subnet_ids = [
      module.vpc.private_subnets[0],
      module.vpc.private_subnets[1]
    ]
  }

  access_config {
    authentication_mode                         = "API" // 사용자 관리를 위한 api
    bootstrap_cluster_creator_admin_permissions = true // EKS를 생성한 Terraform 사용자에게 권한 부여
  }

  depends_on = [aws_iam_role_policy_attachment.eks]
}



# locals {
#   node_group_name = "${var.cluster_name}-node-group"
# }
#
# module "eks" {
#   depends_on = [module.vpc]
#   # 모듈 사용
#   source = "terraform-aws-modules/eks/aws"
#
#   cluster_name    = var.cluster_name
#   cluster_version = var.cluster_version
#
#   cluster_endpoint_private_access = true
#   cluster_endpoint_public_access  = true
#
#   vpc_id          = module.vpc.vpc_id
#   subnet_ids      = module.vpc.private_subnets
#
#   eks_managed_node_group_defaults = {
#     ami_type               = "AL2_x86_64"
#     disk_size              = 10           # EBS 사이즈
#     instance_types         = ["t2.small"]
#     vpc_security_group_ids = []
#   }
#
#   enable_cluster_creator_admin_permissions = true
#
#   eks_managed_node_groups = {
#     ("${var.cluster_name}-node-group") = {
#       # node group 스케일링
#       min_size     = 1 # 최소
#       max_size     = 3 # 최대
#       desired_size = 2 # 기본 유지
#
#       labels = {
#         ondemand = "true"
#       }
#
#       tags = {
#         "k8s.io/cluster-autoscaler/enabled" : "true"
#         "k8s.io/cluster-autoscaler/${var.cluster_name}" : "true"
#       }
#     }
#   }
# }
#
