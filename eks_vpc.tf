/*
Create EKS cluster with VPC using Terraform

Install aws CLI
Install Terraform

*/

# 1. VPC.tf (learn more about terraform AWS modules. because we are using it frequently)
provider "aws" {
    region = var.aws_region
}

data "aws_availability_zones" "available" {}

locals {
  cluster_name = "satya-eks-${random_string.sufix.result}"
}

resource "random_string" "sufix" {
    length = 8
    special = false  
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.7.0"

  name = "satya-eks-vpc"
  cidr = var.vpc_cidr
  azs = data.aws_availability_zones.available.names
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets = ["10.0.4.0/24", "10.0.5.0/24"]
  enable_nat_gateway = true
  single_nat_gateway = true
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    "kubernites.io/cluster/${local.cluster_name}" = "shared"
  }
  public_subnet_tags = {
    "kubernites.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb" = "1"
  }
  private_subnet_tags = {
    "kubernites.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

# 2. EKS_cluster.tf
module "eks" {
    source = "terraform-aws-modules/eks/aws"
    version = "20.8.4"
    cluster_name = local.cluster_name
    cluster_version = var.kubernetes_version
    subnet_ids = module.vpc.private_subnets

    enable_irsa = true

    tags = {
        cluster = "demo"
    }

    vpc_id = module.vpc.vpc_id 

    eks_managed_node_group_defaults = {
        ami_type = "AL2_x86_64"
        instance_type = ["t3.medium"]
        vpc_security_group_ids = [aws_security_group.all_worker_mgmt.id]
    }

    eks_managed_node_groups = {
        node_group = {
            min_size = 2
            max_size = 6
            desired_size = 2
        }
    }
}

# 3. Security_group.tf
resource "aws_security_group" "all_worker_mgmt" {
    name_prefix = "all_worker_management"
    vpc_id = module.vpc.vpc_id 
}

resource "aws_security_group_rule" "all_worker_mgmt_ingress" {
  description = "allow inbound trafic from eks"
  from_port = 0
  protocol = "-1"
  to_port = 0
  security_group_id = aws_security_group.all_worker_mgmt.id
  type = "ingress"
  cidr_blocks = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
}

resource "aws_security_group_rule" "all_worker_mgmt_egress" {
    description = "allow outbound trafic to anywhere"  
    from_port = 0
    protocol = "-1"
    security_group_id = aws_security_group.all_worker_mgmt.id
    to_port = 0
    type = "egress"
    cidr_blocks = ["0.0.0.0/0"]
}
# 4. Variables.tf
variable "kubernetes_version" {
  default = 1.27
  description = "kubernetes version"  
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
  description = "default CIDR range of the VPC"  
}

variable "aws_region"{
  default = "us-east-1"
  description = "aws region"
}
# 5. Output.tf
output "cluster_id" {
  description = "EKS cluster ID."
  value = module.eks.cluster_id  
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "security group ids attached to the cluster control plane."
  value = module.eks.cluster_security_group_id  
}

output "region" {
  description = "AWS region"
  value = var.aws_region  
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn  
}
# 6. Versions.tf 
