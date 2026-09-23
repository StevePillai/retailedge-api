resource "aws_security_group" "app" {
  name        = "retailedge-${var.environment}-app-sg"
  description = "RetailEdge app server"
  vpc_id      = var.vpc_id

  tags = { Name = "retailedge-${var.environment}-app-sg" }
}

resource "aws_vpc_security_group_ingress_rule" "ssh_from_jenkins" {
  security_group_id = aws_security_group.app.id
  description       = "SSH for Ansible - Jenkins only"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = var.jenkins_ip_cidr
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.app.id
  description       = "HTTP"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = aws_security_group.app.id
  description       = "HTTPS"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "app" {
  for_each = toset(var.app_allowed_cidrs)

  security_group_id = aws_security_group.app.id
  description       = "Application port"
  ip_protocol       = "tcp"
  from_port         = 3000
  to_port           = 3000
  cidr_ipv4         = each.value
}

resource "aws_vpc_security_group_egress_rule" "https_out" {
  security_group_id = aws_security_group.app.id
  description       = "ECR image pulls and package downloads"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
}
