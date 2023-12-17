output "created_sg_id" {
  description = "The ID of the created Security Group"
  value       = module.sg.id
}

output "created_sg_arn" {
  description = "The ARN of the created Security Group"
  value       = module.sg.arn
}

output "created_sg_name" {
  description = "The name of the created Security Group"
  value       = module.sg.name
}

# output "test_created_sg_id" {
#   description = "The security group created by the test to use as \"target\" security group"
#   value       = local.enabled ? aws_security_group.target[0].id : null
# }

# output "target_sg_id" {
#   description = "The target Security Group ID"
#   value       = module.target_security_group.id
# }

# output "target_sg_arn" {
#   description = "The target Security Group ARN"
#   value       = module.target_security_group.arn
# }

# output "target_sg_name" {
#   description = "The target Security Group name"
#   value       = module.target_security_group.name
# }

output "rules_terraform_ids" {
  description = "List of Terraform IDs of created `security_group_rule` resources"
  value       = module.sg.rules_terraform_ids
}

output "ebs_volume_name" {
  value       = aws_volume_attachment.cloud9_instance.device_name
}