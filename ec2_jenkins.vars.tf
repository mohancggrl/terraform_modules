# -------------------------------------------------------------------
# EC2 Jenkins Instance Configuration
# -------------------------------------------------------------------

variable "jenkins_name" {
  description = "Name tag for the Jenkins EC2 instance"
  type        = string
}

variable "jenkins_ami" {
  description = "AMI ID for the Jenkins EC2 instance"
  type        = string
}

variable "jenkins_instance_type" {
  description = "Instance type for Jenkins EC2 instance"
  type        = string
  default     = "t3.micro"
}

# variable "subnet_id" {
#   description = "Subnet ID where the Jenkins EC2 instance will be launched"
#   type        = string
# }

# variable "security_group_ids" {
#   description = "List of security groups to attach to the Jenkins instance"
#   type        = list(string)
# }

variable "key_name" {
  description = "EC2 key pair name for SSH access"
  type        = string
}

variable "associate_public_ip" {
  description = "Whether to assign a public IP to the Jenkins instance"
  type        = bool
  default     = false
}

# -------------------------------------------------------------------
# User Data Template Variables
# -------------------------------------------------------------------
# variable "user_data_template" {
#   description = "Path to the user data template file for Jenkins setup"
#   type        = string
#   default     = ""
# }

# variable "user_data_vars" {
#   description = "Map of variables to pass into the user data template"
#   type        = map(string)
#   default     = {}
# }

# -------------------------------------------------------------------
# Jenkins Server Metadata
# -------------------------------------------------------------------
variable "server_username" {
  description = "User to create on the Jenkins EC2 instance"
  type        = string
  default     = "jenkins"
}

variable "ssh_public_key" {
  description = "Public SSH key to allow access to the created user"
  type        = string
}

variable "server_hostname" {
  description = "Hostname to assign to the Jenkins EC2 instance"
  type        = string
  default     = "jenkins-server"
}

# -------------------------------------------------------------------
# Common Tags
# -------------------------------------------------------------------
# variable "tags" {
#   description = "Tags to apply to Jenkins EC2 instance"
#   type        = map(string)
#   default = {
#     Project     = "CICD"
#     Application = "Jenkins"
#   }
# }
