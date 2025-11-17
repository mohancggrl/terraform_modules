variable "enable_sonar" {
  description = "Deploy SonarQube EC2 module?"
  type        = bool
}

variable "sonar_name" {
  description = "Name of the SonarQube EC2 instance"
  type        = string
}

variable "sonar_ami" {
  description = "AMI ID for SonarQube instance (RHEL 9 or compatible)"
  type        = string
}

variable "sonar_instance_type" {
  description = "EC2 instance type for SonarQube"
  type        = string
}

variable "sonar_server_username" {
  description = "User to create on the agent EC2 instance"
  type        = string
  default     = "agent"
}

variable "sonar_ssh_public_key" {
  description = "Public SSH key to allow access to the created user"
  type        = string
}

variable "sonar_server_hostname" {
  description = "Hostname to assign to the agent EC2 instance"
  type        = string
  default     = "agent-server"
}

#########################
# --- SonarQube DB Variables ---
variable "sonar_db" {
  description = "Name of the SonarQube PostgreSQL database"
  type        = string
}

variable "sonar_db_user" {
  description = "PostgreSQL username for SonarQube"
  type        = string
}

variable "sonar_db_pass" {
  description = "PostgreSQL password for SonarQube user"
  type        = string
  sensitive   = true
}

variable "pg_super_pass" {
  description = "Password for PostgreSQL superuser (postgres)"
  type        = string
  sensitive   = true
  default     = "Postgres123"
}
#############################

variable "enable_normal" {
  description = "Deploy Normal EC2 module?"
  type        = bool
}