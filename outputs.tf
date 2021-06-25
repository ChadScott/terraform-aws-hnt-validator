output "validator_instance_id" {
  value = aws_instance.validator.id
}

output "validator_private_ip" {
  value = aws_instance.validator.private_ip
}

output "validator_private_key" {
  sensitive = true 
  value = tls_private_key.validator.private_key_pem
}

output "validator_public_ip" {
  value = aws_eip.validator.public_ip
}
