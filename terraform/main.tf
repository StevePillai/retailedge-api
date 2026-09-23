provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project = "retailedge"
    }
  }
}

locals {
  # The Terraform workspace name IS the environment: staging or production
  environment = terraform.workspace
}

module "networking" {
  source      = "./modules/networking"
  environment = local.environment
  az          = "${var.aws_region}a"
}

module "security" {
  source            = "./modules/security"
  environment       = local.environment
  vpc_id            = module.networking.vpc_id
  jenkins_ip_cidr   = var.jenkins_ip_cidr
  app_allowed_cidrs = var.app_allowed_cidrs
}

module "compute" {
  source           = "./modules/compute"
  environment      = local.environment
  instance_type    = var.instance_type
  public_subnet_id = module.networking.public_subnet_id
  sg_id            = module.security.app_sg_id
  public_key       = file("${path.module}/deployer.pub")

  # The internet gateway must exist before the Elastic IP is attached
  depends_on = [module.networking]
}

# One shared ECR repository, created only from the staging workspace
module "ecr" {
  count  = local.environment == "staging" ? 1 : 0
  source = "./modules/ecr"
}

module "monitoring" {
  source      = "./modules/monitoring"
  environment = local.environment
  instance_id = module.compute.instance_id
  alert_email = var.alert_email
}
