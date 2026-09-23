variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "EC2 instance type for the app server"
  type        = string
  default     = "t3.small"
}

variable "image_tag" {
  description = "Docker image tag being deployed (passed in by Jenkins, only recorded as an output)"
  type        = string
  default     = "none"
}

variable "jenkins_ip_cidr" {
  description = "Jenkins server Elastic IP as a /32 CIDR, e.g. 13.201.10.20/32"
  type        = string
}

variable "app_allowed_cidrs" {
  description = "Who may reach the app on port 3000"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "alert_email" {
  description = "Email address that receives CloudWatch alarm notifications"
  type        = string
}
