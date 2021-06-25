data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

data "aws_region" "current" {}

data "aws_subnet" "validator" {
  id = var.validator_subnet
}

data "template_cloudinit_config" "validator" {
  base64_encode = true
  gzip          = true

  part {
    content      = data.template_file.validator_cloud_config.rendered
    content_type = "text/cloud-config"
    filename     = "init.cfg"
  }
}

data "template_file" "validator_cloud_config" {
  template = file("${path.module}/templates/cloud-config.tpl")
  vars = {
    public_ip = aws_eip.validator.public_ip
    volume_id = aws_ebs_volume.validator.id
  }
}
