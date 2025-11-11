# -------------------------------------------------------------------
# Security Group Variables
# -------------------------------------------------------------------
variable "create_security_group" {
  description = "Whether to create the security group"
  type        = bool
  default     = true
}

variable "sg_name" {
  description = "Name of the security group"
  type        = string
}

variable "sg_description" {
  description = "Description for the security group"
  type        = string
  default     = "Managed by Terraform"
}

variable "sg_ingress_rules" {
  description = "List of ingress rules"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = optional(list(string))
    description = optional(string)
  }))
  default = []
}

variable "sg_egress_rules" {
  description = "List of egress rules"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = optional(list(string))
    description = optional(string)
  }))
  default = []
}

# # -------------------------------------------------------------------
# # Tags
# # -------------------------------------------------------------------
# variable "tags" {
#   description = "Tags for resources"
#   type        = map(string)
#   default     = {}
# }