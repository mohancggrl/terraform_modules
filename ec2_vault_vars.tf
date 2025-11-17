variable "enable_vault" {
  description = "Deploy vault EC2 module?"
  type        = bool
}

variable "vault_name" {
  description = "Name of the vault EC2 instance"
  type        = string
}

variable "vault_ami" {
  description = "AMI ID for vault instance (RHEL 9 or compatible)"
  type        = string
}

variable "vault_instance_type" {
  description = "EC2 instance type for vault"
  type        = string
}

variable "vault_server_username" {
  description = "User to create on the agent EC2 instance"
  type        = string
}

variable "vault_ssh_public_key" {
  description = "Public SSH key to allow access to the created user"
  type        = string
}

variable "vault_server_hostname" {
  description = "Hostname to assign to the agent EC2 instance"
  type        = string
}