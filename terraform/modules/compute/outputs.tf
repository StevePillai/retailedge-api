output "instance_id" {
  value = aws_instance.app_server.id
}

output "public_ip" {
  value = aws_eip.app.public_ip
}
