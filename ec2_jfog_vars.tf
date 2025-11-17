variable "enable_jfrog" {
  description = "Deploy jfrog EC2 module?"
  type        = bool
}

variable "jfrog_name" {
  description = "Name of the jfrog EC2 instance"
  type        = string
}

variable "jfrog_ami" {
  description = "AMI ID for jfrog instance (RHEL 9 or compatible)"
  type        = string
}

variable "jfrog_instance_type" {
  description = "EC2 instance type for jfrogQube"
  type        = string
}

variable "jfrog_server_username" {
  description = "User to create on the agent EC2 instance"
  type        = string
  default     = "agent"
}

variable "jfrog_ssh_public_key" {
  description = "Public SSH key to allow access to the created user"
  type        = string
}

variable "jfrog_server_hostname" {
  description = "Hostname to assign to the agent EC2 instance"
  type        = string
  default     = "agent-server"
}

#########################
# --- jfrogQube DB Variables ---
variable "jfrog_db" {
  description = "Name of the jfrogQube PostgreSQL database"
  type        = string
}

variable "jfrog_db_user" {
  description = "PostgreSQL username for jfrogQube"
  type        = string
}

variable "jfrog_db_pass" {
  description = "PostgreSQL password for jfrogQube user"
  type        = string
  sensitive   = true
}

variable "jfrog_pg_super_pass" {
  description = "Password for PostgreSQL superuser (postgres)"
  type        = string
  sensitive   = true
}