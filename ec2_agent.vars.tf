# -------------------------------------------------------------------
# EC2 agent Instance Configuration
# -------------------------------------------------------------------

variable "agent_name" {
  description = "Name tag for the agent EC2 instance"
  type        = string
}

variable "agent_ami" {
  description = "AMI ID for the agent EC2 instance"
  type        = string
}

variable "agent_instance_type" {
  description = "Instance type for agent EC2 instance"
  type        = string
  default     = "t3.micro"
}

# variable "key_name" {
#   description = "EC2 key pair name for SSH access"
#   type        = string
# }

# variable "associate_public_ip" {
#   description = "Whether to assign a public IP to the agent instance"
#   type        = bool
#   default     = false
# }
# -------------------------------------------------------------------
# agent Server Metadata
# -------------------------------------------------------------------
variable "agent_server_username" {
  description = "User to create on the agent EC2 instance"
  type        = string
  default     = "agent"
}

variable "agent_ssh_public_key" {
  description = "Public SSH key to allow access to the created user"
  type        = string
}

variable "agent_server_hostname" {
  description = "Hostname to assign to the agent EC2 instance"
  type        = string
  default     = "agent-server"
}

# -------------------------------------------------------------------
# Common Tags
# -------------------------------------------------------------------
# variable "tags" {
#   description = "Tags to apply to agent EC2 instance"
#   type        = map(string)
#   default = {
#     Project     = "CICD"
#     Application = "agent"
#   }
# }
