output "vpc_id" {
  value = aws_vpc.test.id
}

output "subnet_id" {
  value = aws_subnet.main.id
}

output "instance_id" {
  value = aws_instance.aws_linux.id
}

output "instance_public_ip" {
  value = aws_instance.aws_linux.public_ip
}

output "instance_public_dns" {
  value = aws_instance.aws_linux.public_dns
}

output "aws_security_group" {
  value = aws_security_group.sg.id
}
