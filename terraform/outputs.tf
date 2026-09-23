output "ec2_public_ip" {
  description = "Elastic IP of the app server (Ansible and the health check use this)"
  value       = module.compute.public_ip
}

output "ecr_repository_url" {
  description = "ECR repository URL (only set in the staging workspace)"
  value       = try(module.ecr[0].repository_url, null)
}

output "deployed_image_tag" {
  value = var.image_tag
}
