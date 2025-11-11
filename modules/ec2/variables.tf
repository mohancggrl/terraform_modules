variable "create_instance" {
  type    = bool
  default = true
}

variable "name" {
  type = string
}

variable "ami" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "subnet_id" {
  type = string
}

variable "security_group_ids" {
  type = list(string)
}

variable "key_name" {
  type    = string
  default = ""
}

variable "associate_public_ip" {
  type    = bool
  default = false
}

variable "user_data_template" {
  description = "Path to the user data template"
  type        = string
  default     = ""
}

variable "user_data_vars" {
  description = "Dynamic map of variables to render in user_data template"
  type        = map(any)
  default     = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}