variable "environment" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "public_subnet_id" {
  type = string
}

variable "sg_id" {
  type = string
}

variable "public_key" {
  description = "Contents of the deployer SSH public key"
  type        = string
}
