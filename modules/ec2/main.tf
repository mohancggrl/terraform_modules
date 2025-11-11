# -------------------------------------------------------------------
# EC2 Instance Module
# -------------------------------------------------------------------
resource "aws_instance" "this" {
  count = var.create_instance ? 1 : 0
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  key_name                    = var.key_name
  associate_public_ip_address = var.associate_public_ip
  user_data = var.user_data_template != "" ? templatefile(var.user_data_template, var.user_data_vars) : null
  tags = merge(var.tags, { 
    Name = var.name 
    }
  )
}