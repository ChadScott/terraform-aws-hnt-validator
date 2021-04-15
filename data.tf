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

data "aws_subnet" "validator" {
  id = element(var.validator_subnets, count.index)

  count = var.validator_count
}

data "aws_region" "current" {}

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
}
