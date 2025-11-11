output "instance_id" {
  description = "ID of the EC2 instance"
  value       = length(aws_instance.this) > 0 ? aws_instance.this[0].id : null
}

output "private_ip" {
  description = "Private IP of the EC2 instance"
  value       = length(aws_instance.this) > 0 ? aws_instance.this[0].private_ip : null
}

output "public_ip" {
  description = "Public IP of the EC2 instance"
  value       = length(aws_instance.this) > 0 ? aws_instance.this[0].public_ip : null
}