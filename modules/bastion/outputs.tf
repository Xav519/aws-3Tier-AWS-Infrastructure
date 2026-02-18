output "instance_id" {
  value = aws_instance.bastion.id
}

output "public_ip" {
  value = aws_eip.bastion_eip.public_ip
}

output "private_ip" {
  value = aws_instance.bastion.private_ip
}
