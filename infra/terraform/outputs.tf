output "instance_id" {
  value = aws_instance.kombot.id
}

output "public_ip" {
  value = aws_instance.kombot.public_ip
}

output "public_dns" {
  value = aws_instance.kombot.public_dns
}

output "security_group_id" {
  value = aws_security_group.kombot.id
}

output "instance_profile_name" {
  value = aws_iam_instance_profile.kombot.name
}

output "ssm_parameter_prefix" {
  value = "/${var.project_name}/${var.environment}"
}