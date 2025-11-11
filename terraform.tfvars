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
create_nat_gateway      = false
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
