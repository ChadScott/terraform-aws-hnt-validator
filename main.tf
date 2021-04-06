resource "aws_eip" "validator" {
  vpc = true

  tags = var.validator_tags

  count = var.validator_count
}

resource "aws_eip_association" "validator" {
  instance_id   = aws_instance.validator[count.index].id
  allocation_id = aws_eip.validator[count.index].id

  count = var.validator_count
}

resource "aws_key_pair" "validator" {
  public_key = tls_private_key.validator[count.index].public_key_openssh

  count = var.validator_count
}

resource "aws_instance" "validator" {
  ami                         = data.aws_ami.ubuntu.id
  associate_public_ip_address = true
  instance_type               = var.validator_instance_type
  placement_group             = aws_placement_group.validator.id
  key_name                    = aws_key_pair.validator[count.index].key_name
  subnet_id                   = element(var.validator_subnets, count.index)
  security_groups             = [aws_security_group.validator[count.index].id]

  tags = merge({
    Name = "hnt-validator-${random_id.validator.hex}-${count.index}"
  }, var.validator_tags)

  root_block_device {
    delete_on_termination = true
    encrypted             = true
    volume_size           = 64
  }

  count = var.validator_count
}

resource "aws_placement_group" "validator" {
  name     = "hnt-validator-${random_id.validator.hex}"
  strategy = "spread"
}

resource "aws_security_group" "validator" {
  vpc_id = data.aws_subnet.validator[count.index].vpc_id

  # TODO: Needs to be restricted to the specific traffic required to operate
  ingress {
    from_port = 0
    to_port   = 0

    protocol = -1

    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0

    protocol = -1

    cidr_blocks = ["0.0.0.0/0"]
  }

  count = var.validator_count
}

resource "local_file" "validator" {
  file_permission   = "0600"
  filename          = "validator-${random_id.validator.hex}-${count.index}.key"
  sensitive_content = tls_private_key.validator[count.index].private_key_pem

  count = var.output_keys ? var.validator_count : 0
}

resource "random_id" "validator" {
  byte_length = 8
}

resource "tls_private_key" "validator" {
  algorithm = "RSA"
  rsa_bits  = 4096

  count = var.validator_count
}
