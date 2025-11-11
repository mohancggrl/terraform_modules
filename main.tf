module "vpc" {
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
  source = "./modules/sg"
  name                  = var.sg_name
  description           = var.sg_description
  vpc_id                = module.vpc.vpc_id
  create_security_group = var.create_security_group
  ingress_rules         = var.sg_ingress_rules
  egress_rules          = var.sg_egress_rules
  tags                  = var.tags
}
###########################################################################
module "jenkins" {
  source = "./modules/ec2"
  name                = var.jenkins_name
  ami                 = var.jenkins_ami
  instance_type       = var.jenkins_instance_type
  subnet_id           = module.vpc.public_subnet_ids[0]
  security_group_ids  = [module.security_group.security_group_id]
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
  source = "./modules/ec2"
  name                = var.agent_name
  ami                 = var.agent_ami
  instance_type       = var.agent_instance_type
  subnet_id           = module.vpc.public_subnet_ids[0]
  security_group_ids  = [module.security_group.security_group_id]
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
