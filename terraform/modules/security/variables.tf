variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "jenkins_ip_cidr" {
  type = string
}

variable "app_allowed_cidrs" {
  type = list(string)
}
