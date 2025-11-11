output "security_group_id" {
  description = "The ID of the security group (null if not created)"
  value       = length(aws_security_group.main) > 0 ? aws_security_group.main[0].id : null
}