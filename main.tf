resource "aws_ebs_volume" "validator" {
  availability_zone = data.aws_subnet.validator.availability_zone
  encrypted         = true
  size              = var.validator_volume_size
  snapshot_id       = var.validator_ebs_snapshot

  tags = merge({
    Name = "hnt-validator-${random_id.validator.hex}-state"
  }, var.validator_tags)
}

resource "aws_volume_attachment" "validator" {
  device_name = "/dev/sdh"
  instance_id = aws_instance.validator.id
  volume_id   = aws_ebs_volume.validator.id
}

resource "aws_eip" "validator" {
  vpc = true

  tags = merge({
    Name = "hnt-validator-${random_id.validator.hex}"
  }, var.validator_tags)
}

resource "aws_eip_association" "validator" {
  allocation_id = aws_eip.validator.id
  instance_id   = aws_instance.validator.id
}

resource "aws_key_pair" "validator" {
  public_key = tls_private_key.validator.public_key_openssh

  tags = merge({
    Name = "hnt-validator-${random_id.validator.hex}"
  }, var.validator_tags)
}

resource "aws_instance" "validator" {
  ami                         = length(var.validator_ami) > 0 ? var.validator_ami : data.aws_ami.ubuntu.id
  associate_public_ip_address = true
  instance_type               = var.validator_instance_type
  key_name                    = aws_key_pair.validator.key_name
  monitoring                  = var.validator_monitoring
  subnet_id                   = var.validator_subnet
  user_data                   = data.template_cloudinit_config.validator.rendered
  vpc_security_group_ids      = [aws_security_group.validator.id]

  tags = merge({
    Name = "hnt-validator-${random_id.validator.hex}"
  }, var.validator_tags)

  root_block_device {
    delete_on_termination = true
    encrypted             = true
    tags                  = merge({
      Name = "hnt-validator-${random_id.validator.hex}-root",
    }, var.validator_tags)
    volume_size           = 8
  }
}

resource "aws_security_group" "validator" {
  revoke_rules_on_delete = true
  vpc_id                 = data.aws_subnet.validator.vpc_id

  tags = merge({
    Name = "hnt-validator-${random_id.validator.hex}"
  }, var.validator_tags)
}

resource "aws_security_group_rule" "validator_all_egress" {
  security_group_id = aws_security_group.validator.id
  type              = "egress"

  from_port = 0
  to_port   = 0

  protocol = -1

  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "validator_22_ingress" {
  security_group_id = aws_security_group.validator.id
  type              = "ingress"

  from_port = 22
  to_port   = 22

  protocol = "tcp"

  cidr_blocks = var.ssh_allowlist

  count = length(var.ssh_allowlist) > 0 ? 1 : 0
}

resource "aws_security_group_rule" "validator_2154_ingress" {
  security_group_id = aws_security_group.validator.id
  type              = "ingress"

  from_port = 2154
  to_port   = 2154

  protocol = "tcp"

  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "validator_8080_ingress" {
  security_group_id = aws_security_group.validator.id
  type              = "ingress"

  from_port = 8080
  to_port   = 8080

  protocol = "tcp"

  cidr_blocks = ["0.0.0.0/0"]
}

resource "local_file" "validator" {
  file_permission   = "0600"
  filename          = "validator-${random_id.validator.hex}.key"
  sensitive_content = tls_private_key.validator.private_key_pem

  count = var.output_keys ? 1 : 0
}

resource "random_id" "validator" {
  byte_length = 8
}

resource "tls_private_key" "validator" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
