module "vpc" {
  count = var.enable_vpc ? 1 : 0
  source = "./modules/vpc"
  name                       = var.name
  vpc_cidr                   = var.vpc_cidr
  create_vpc                 = var.create_vpc
  create_public_subnets      = var.create_public_subnets
  create_private_subnets     = var.create_private_subnets
  create_internet_gateway    = var.create_internet_gateway
  create_nat_gateway         = var.create_nat_gateway
  public_subnet_cidrs        = var.public_subnet_cidrs
  private_subnet_cidrs       = var.private_subnet_cidrs
  public_availability_zones  = var.public_availability_zones
  private_availability_zones = var.private_availability_zones
  tags                       = var.tags
}
###########################################################################
module "security_group" {
  count = var.enable_sg ? 1 : 0
  source = "./modules/sg"
  name                  = var.sg_name
  description           = var.sg_description
  vpc_id                = var.enable_vpc ? module.vpc[0].vpc_id : var.vpc_id
  create_security_group = var.create_security_group
  ingress_rules         = var.sg_ingress_rules
  egress_rules          = var.sg_egress_rules
  tags                  = var.tags
}
###########################################################################
module "jenkins" {
  count = var.enable_jenkins ? 1 : 0
  source = "./modules/ec2"
  name                = var.jenkins_name
  ami                 = var.jenkins_ami
  instance_type       = var.jenkins_instance_type
  subnet_id           = var.enable_vpc ? module.vpc[0].public_subnet_ids[0] : var.subnet_id
  security_group_ids  = var.enable_sg ? [module.security_group[0].security_group_id] : [var.sg_id]
  key_name            = var.key_name
  associate_public_ip = var.associate_public_ip
  user_data_template  = "${path.module}/scripts/jenkins.sh.tpl"
  user_data_vars      = {
    server_username   = var.server_username
    ssh_public_key    = var.ssh_public_key
    server_hostname   = var.server_hostname
  }
  tags                = var.tags
}

###########################################################################
module "agent" {
  count = var.enable_agent ? 1 : 0
  source = "./modules/ec2"
  name                = var.agent_name
  ami                 = var.agent_ami
  instance_type       = var.agent_instance_type
  subnet_id           = var.enable_vpc ? module.vpc[0].public_subnet_ids[0] : var.subnet_id
  security_group_ids  = var.enable_sg ? [module.security_group[0].security_group_id] : [var.sg_id]
  key_name            = var.key_name
  associate_public_ip = var.associate_public_ip
  user_data_template  = "${path.module}/scripts/agent.sh.tpl"
  user_data_vars      = {
    server_username   = var.agent_server_username
    ssh_public_key    = var.agent_ssh_public_key
    server_hostname   = var.agent_server_hostname
  }
  tags                = var.tags
}
###########################################################################
module "sonar" {
  count = var.enable_sonar ? 1 : 0
  source = "./modules/ec2"
  name                = var.sonar_name
  ami                 = var.sonar_ami
  instance_type       = var.sonar_instance_type
  subnet_id           = var.enable_vpc ? module.vpc[0].public_subnet_ids[0] : var.subnet_id
  security_group_ids  = var.enable_sg ? [module.security_group[0].security_group_id] : [var.sg_id]
  key_name            = var.key_name
  associate_public_ip = var.associate_public_ip
  user_data_template  = "${path.module}/scripts/sonar.sh.tpl"
  user_data_vars      = {
    server_username   = var.sonar_server_username
    ssh_public_key    = var.sonar_ssh_public_key
    server_hostname   = var.sonar_server_hostname
    sonar_db = var.sonar_db
    sonar_db_user = var.sonar_db_user
    sonar_db_pass = var.sonar_db_pass
    pg_super_pass = var.pg_super_pass
  }
  tags                = var.tags
}
###########################################################################
module "jfrog" {
  count = var.enable_jfrog ? 1 : 0
  source = "./modules/ec2"
  name                = var.jfrog_name
  ami                 = var.jfrog_ami
  instance_type       = var.jfrog_instance_type
  subnet_id           = var.enable_vpc ? module.vpc[0].public_subnet_ids[0] : var.subnet_id
  security_group_ids  = var.enable_sg ? [module.security_group[0].security_group_id] : [var.sg_id]
  key_name            = var.key_name
  associate_public_ip = var.associate_public_ip
  user_data_template  = "${path.module}/scripts/jfrog.sh.tpl"
  user_data_vars      = {
    server_username   = var.jfrog_server_username
    ssh_public_key    = var.jfrog_ssh_public_key
    server_hostname   = var.jfrog_server_hostname
    jfrog_db = var.jfrog_db
    jfrog_db_user = var.jfrog_db_user
    jfrog_db_pass = var.jfrog_db_pass
    jfrog_pg_super_pass = var.jfrog_pg_super_pass
  }
  tags                = var.tags
}
###########################################################################
module "vault" {
  count = var.enable_vault ? 1 : 0
  source = "./modules/ec2"
  name                = var.vault_name
  ami                 = var.vault_ami
  instance_type       = var.vault_instance_type
  subnet_id           = var.enable_vpc ? module.vpc[0].public_subnet_ids[0] : var.subnet_id
  security_group_ids  = var.enable_sg ? [module.security_group[0].security_group_id] : [var.sg_id]
  key_name            = var.key_name
  associate_public_ip = var.associate_public_ip
  user_data_template  = "${path.module}/scripts/vault.sh.tpl"
  user_data_vars      = {
    vault_server_username   = var.vault_server_username
    vault_ssh_public_key   = var.vault_ssh_public_key
    vault_server_hostname   = var.vault_server_hostname
  }
  tags                = var.tags
}
###########################################################################
module "normal" {
  count = var.enable_normal ? 1 : 0
  source = "./modules/ec2"
  name                = var.sonar_name
  ami                 = var.sonar_ami
  instance_type       = var.sonar_instance_type
  subnet_id           = var.enable_vpc ? module.vpc[0].public_subnet_ids[0] : var.subnet_id
  security_group_ids  = var.enable_sg ? [module.security_group[0].security_group_id] : [var.sg_id]
  key_name            = var.key_name
  associate_public_ip = var.associate_public_ip
  user_data_template  = ""
  user_data_vars      = {}
  tags                = var.tags
}
###########################################################################
module "iam_roles" {
  count = var.enable_role ? 1 : 0
  source = "./modules/role"
  roles = var.roles
  tags  = var.tags
}
###########################################################################
module "eks" {
  count = var.enable_eks ? 1 : 0
  source = "./modules/eks"
  name        = var.name
  eks_version = var.eks_version
  private_subnet_ids = var.enable_vpc ? try(module.vpc[0].private_subnet_ids, []) : var.private_subnet_ids
  cluster_role_arn = module.iam_roles[0].role_arns["eks_cluster_role"]
  node_role_arn    = module.iam_roles[0].role_arns["eks_nodegroup_role"]
  instance_types = var.eks_instance_types
  desired_size   = var.desired_size
  min_size       = var.min_size
  max_size       = var.max_size
  tags = var.tags
  depends_on = [module.iam_roles]
}
############################################################################
# data "aws_eks_cluster" "eks" {
#   name = module.eks[0].cluster_name
# }

locals {
  alb_role = var.enable_alb_iam_role ? {
    alb_controller_role = {
      role_name            = var.alb_controller_role.role_name
      assume_oidc_provider = true
      oidc_issuer          = module.eks[0].oidc_issuer
      oidc_sa              = var.alb_controller_role.oidc_sa
      managed_policy_arns  = var.alb_controller_role.managed_policy_arns
      inline_policy_json   = var.alb_controller_role.inline_policy_json
    }
  } : {}
}

module "alb_iam_role" {
  count  = var.enable_alb_iam_role ? 1 : 0
  source = "./modules/role"
  roles  = local.alb_role
  tags   = var.tags

  depends_on = [module.eks]
}

###########################################################################
