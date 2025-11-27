# AWS Provider Configuration
aws_region  = "us-west-2"
access_key  = ""
secret_key  = ""
# VPC Settings
name     = "devil"
vpc_cidr = "10.0.0.0/24"
# Feature Toggles
create_vpc              = true
create_public_subnets   = true
create_private_subnets  = true
create_internet_gateway = true
create_nat_gateway      = true
# Subnet Configuration
public_subnet_cidrs  = ["10.0.0.0/26"]
private_subnet_cidrs = ["10.0.0.128/26", "10.0.0.192/26"]
public_availability_zones  = []
private_availability_zones = []
# Tags
tags = {
  Environment = "dev"
  Owner       = "Mohan"
}

#=====================================================================
# Security Group Configuration
#=====================================================================
create_security_group = true
sg_name        = "Jenkins-sg"
sg_description = "Security group for demo app"
sg_ingress_rules = [
  {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access"
  },
  {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access"
  },
  {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all inbound TCP traffic"
  }
]
sg_egress_rules = [
  {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
]

# -------------------------------------------------------------------
# Jenkins EC2 Configuration
# -------------------------------------------------------------------
jenkins_name          = "jenkins-server"
jenkins_ami           = "ami-0357fd8270bb3203e"
jenkins_instance_type = "t3.small"
key_name              = "mohan"
associate_public_ip   = true

# -------------------------------------------------------------------
# Jenkins Host Configuration
# -------------------------------------------------------------------
server_username  = "mydevops"
ssh_public_key   = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCdlcZBxW1ZJOl8XaoL1drKrg0oNy5lAsn79IGb1C/n+k0CunP9K3udzPoIn1Vw5V8HRv4wf6TMQ2VAYNApOqVj2OLoRgTZwTtAdLA7iHYkANm+FKZklG+Sr8v2dqQ6NQFI68bZ7MFNeLSY10w9XizQ4mlY+XfvgwDC0iyxCMb/pocdq2sgqRRM0ZsAF7nKpGQZNWxyYb6qCvxY59SB/D8hc6WFVX70rgeuY1wj4hBW/gJCO7wIXEuZsS1pbl3L5iBwnS75Ci2+a8hHm2oa3KP5Y7KlP+y7WBRcEOsmLe4L4yVvBGiFd6RGMA50RiUTjiu80da0mbQsdHuIDgeMRiGD7hNpUVMUDgwiwIceIVi8qASxaOZLBbDVO73rVDUMEQ2rs+idbLKiqFkKBnctDV7LO+3TqqKF/IwkL41yvwqGsKDDU81qcsn6IvXAuOjFQ/qKNrqnwRoTjWyQhnn7anyD3h44Yo4BvazB1jiRgJVJHnEnQ6AiLhNUgHLSgH04qC0= mydevops@MOHAN"
server_hostname  = "MYJENKINS01"

# -------------------------------------------------------------------
# Common Tags
# -------------------------------------------------------------------
# tags = {
#   Environment = "dev"
#   Owner       = "cloud-team"
#   CostCenter  = "cicd"
#   Project     = "DevOps-Automation"
# }
# -------------------------------------------------------------------
# Jenkins EC2 Configuration
# -------------------------------------------------------------------
agent_name          = "jenkins-server"
agent_ami           = "ami-0357fd8270bb3203e"
agent_instance_type = "t3.small"
# key_name              = "mohan"
# associate_public_ip   = true

# -------------------------------------------------------------------
# Jenkins Host Configuration
# -------------------------------------------------------------------
agent_server_username  = "mydevops"
agent_ssh_public_key   = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCdlcZBxW1ZJOl8XaoL1drKrg0oNy5lAsn79IGb1C/n+k0CunP9K3udzPoIn1Vw5V8HRv4wf6TMQ2VAYNApOqVj2OLoRgTZwTtAdLA7iHYkANm+FKZklG+Sr8v2dqQ6NQFI68bZ7MFNeLSY10w9XizQ4mlY+XfvgwDC0iyxCMb/pocdq2sgqRRM0ZsAF7nKpGQZNWxyYb6qCvxY59SB/D8hc6WFVX70rgeuY1wj4hBW/gJCO7wIXEuZsS1pbl3L5iBwnS75Ci2+a8hHm2oa3KP5Y7KlP+y7WBRcEOsmLe4L4yVvBGiFd6RGMA50RiUTjiu80da0mbQsdHuIDgeMRiGD7hNpUVMUDgwiwIceIVi8qASxaOZLBbDVO73rVDUMEQ2rs+idbLKiqFkKBnctDV7LO+3TqqKF/IwkL41yvwqGsKDDU81qcsn6IvXAuOjFQ/qKNrqnwRoTjWyQhnn7anyD3h44Yo4BvazB1jiRgJVJHnEnQ6AiLhNUgHLSgH04qC0= mydevops@MOHAN"
agent_server_hostname  = "MYAGENT01"
# -------------------------------------------------------------------
# Sonar Host Configuration
# -------------------------------------------------------------------
sonar_name          = "sonar-server"
sonar_ami           = "ami-0357fd8270bb3203e"
sonar_instance_type = "t3.small"
sonar_server_username  = "mydevops"
sonar_ssh_public_key   = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCdlcZBxW1ZJOl8XaoL1drKrg0oNy5lAsn79IGb1C/n+k0CunP9K3udzPoIn1Vw5V8HRv4wf6TMQ2VAYNApOqVj2OLoRgTZwTtAdLA7iHYkANm+FKZklG+Sr8v2dqQ6NQFI68bZ7MFNeLSY10w9XizQ4mlY+XfvgwDC0iyxCMb/pocdq2sgqRRM0ZsAF7nKpGQZNWxyYb6qCvxY59SB/D8hc6WFVX70rgeuY1wj4hBW/gJCO7wIXEuZsS1pbl3L5iBwnS75Ci2+a8hHm2oa3KP5Y7KlP+y7WBRcEOsmLe4L4yVvBGiFd6RGMA50RiUTjiu80da0mbQsdHuIDgeMRiGD7hNpUVMUDgwiwIceIVi8qASxaOZLBbDVO73rVDUMEQ2rs+idbLKiqFkKBnctDV7LO+3TqqKF/IwkL41yvwqGsKDDU81qcsn6IvXAuOjFQ/qKNrqnwRoTjWyQhnn7anyD3h44Yo4BvazB1jiRgJVJHnEnQ6AiLhNUgHLSgH04qC0= mydevops@MOHAN"
sonar_server_hostname  = "MYSONAR01"
####################################################################
# SonarQube Database Configuration
sonar_db        = "sonarqube"
sonar_db_user   = "sonar"
sonar_db_pass   = "MohanG12345"
pg_super_pass   = "Postgres123"

# ------------------------------------------------------------------
# JFrog EC2 Configuration
# ------------------------------------------------------------------
jfrog_name            = "jfrog-artifactory"
jfrog_ami             = "ami-0357fd8270bb3203e"
jfrog_instance_type   = "t3.medium"

jfrog_server_username = "mydevops"
jfrog_ssh_public_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCdlcZBxW1ZJOl8XaoL1drKrg0oNy5lAsn79IGb1C/n+k0CunP9K3udzPoIn1Vw5V8HRv4wf6TMQ2VAYNApOqVj2OLoRgTZwTtAdLA7iHYkANm+FKZklG+Sr8v2dqQ6NQFI68bZ7MFNeLSY10w9XizQ4mlY+XfvgwDC0iyxCMb/pocdq2sgqRRM0ZsAF7nKpGQZNWxyYb6qCvxY59SB/D8hc6WFVX70rgeuY1wj4hBW/gJCO7wIXEuZsS1pbl3L5iBwnS75Ci2+a8hHm2oa3KP5Y7KlP+y7WBRcEOsmLe4L4yVvBGiFd6RGMA50RiUTjiu80da0mbQsdHuIDgeMRiGD7hNpUVMUDgwiwIceIVi8qASxaOZLBbDVO73rVDUMEQ2rs+idbLKiqFkKBnctDV7LO+3TqqKF/IwkL41yvwqGsKDDU81qcsn6IvXAuOjFQ/qKNrqnwRoTjWyQhnn7anyD3h44Yo4BvazB1jiRgJVJHnEnQ6AiLhNUgHLSgH04qC0= mydevops@MOHAN"
jfrog_server_hostname = "MYJFROG01"

jfrog_db        = "artdb"
jfrog_db_user   = "artifactory"
jfrog_db_pass   = "Mohan123"
jfrog_pg_super_pass   = "PgRoot@123"

# ------------------------------------------------------------------
# vault EC2 Configuration
# ------------------------------------------------------------------
vault_name            = "hashicorp-vault-server"
vault_ami             = "ami-0357fd8270bb3203e"
vault_instance_type   = "t3.medium"

vault_server_username = "mydevops"
vault_ssh_public_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCdlcZBxW1ZJOl8XaoL1drKrg0oNy5lAsn79IGb1C/n+k0CunP9K3udzPoIn1Vw5V8HRv4wf6TMQ2VAYNApOqVj2OLoRgTZwTtAdLA7iHYkANm+FKZklG+Sr8v2dqQ6NQFI68bZ7MFNeLSY10w9XizQ4mlY+XfvgwDC0iyxCMb/pocdq2sgqRRM0ZsAF7nKpGQZNWxyYb6qCvxY59SB/D8hc6WFVX70rgeuY1wj4hBW/gJCO7wIXEuZsS1pbl3L5iBwnS75Ci2+a8hHm2oa3KP5Y7KlP+y7WBRcEOsmLe4L4yVvBGiFd6RGMA50RiUTjiu80da0mbQsdHuIDgeMRiGD7hNpUVMUDgwiwIceIVi8qASxaOZLBbDVO73rVDUMEQ2rs+idbLKiqFkKBnctDV7LO+3TqqKF/IwkL41yvwqGsKDDU81qcsn6IvXAuOjFQ/qKNrqnwRoTjWyQhnn7anyD3h44Yo4BvazB1jiRgJVJHnEnQ6AiLhNUgHLSgH04qC0= mydevops@MOHAN"
vault_server_hostname = "MYVAULT01"

# ------------------------------------------------------------------
# role configuration
# ------------------------------------------------------------------
roles = {
  eks_cluster_role = {
    role_name = "eks-dev-cluster-role"
    assume_role_policy = {
      Service = "eks.amazonaws.com"
      Action  = "sts:AssumeRole"
    }
    managed_policy_arns = [
      "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
      "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
    ]
    inline_policy_json = null
  }
  
  eks_nodegroup_role = {
    role_name = "eks-dev-nodegroup-role"
    assume_role_policy = {
      Service = "ec2.amazonaws.com"
      Action  = "sts:AssumeRole"
    }
    managed_policy_arns = [
      "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
      "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
      "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    ]
    inline_policy_json = null
  }
}

#   alb_controller_role = {
#     role_name            = "aws-load-balancer-controller-role"
#     assume_oidc_provider = true
#     oidc_issuer          = "https://oidc.eks.us-east-1.amazonaws.com/id/ABCDEF123456"
#     oidc_sa              = "system:serviceaccount:kube-system:aws-load-balancer-controller"
#     managed_policy_arns  = []
#     inline_policy_json = <<POLICY
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Action": [
#         "elasticloadbalancing:*",
#         "ec2:Describe*",
#         "iam:CreateServiceLinkedRole",
#         "wafv2:GetWebACL",
#         "tag:GetResources",
#         "ec2:AuthorizeSecurityGroupIngress",
#         "ec2:RevokeSecurityGroupIngress"
#       ],
#       "Resource": "*"
#     }
#   ]
# }
# POLICY
#   }
# }

alb_controller_role = {
  role_name   = "aws-load-balancer-controller-role"
  oidc_sa     = "system:serviceaccount:kube-system:aws-load-balancer-controller"
  managed_policy_arns = []
  inline_policy_json = "./policies/alb_controller_policy.json"
}
#-------------------------------------------------------------------
# eks vars
#-------------------------------------------------------------------
# name = "dev"
eks_version = "1.30"

eks_instance_types = ["t3.small"]
desired_size   = 1
min_size       = 1
max_size       = 2


#-------------------------------------------------------------------
# Common Tags
#-------------------------------------------------------------------
enable_vpc   = true
enable_sg    = false
enable_jenkins = false
enable_agent   = false
enable_sonar = false
enable_jfrog = false
enable_vault = false
enable_normal = false
enable_role   = true
enable_eks    = true
enable_alb_iam_role = true

vpc_id = ""
subnet_id = ""
sg_id   = ""
private_subnet_ids = []