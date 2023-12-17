# Terraform for testing with terratest
#
# For this module, a large portion of the test is simply
# verifying that Terraform can generate a plan without errors.
#

provider "aws" {
  region = var.region
}

module "vpc" {
  source  = "cloudposse/vpc/aws"
  version = "2.1.1"

  ipv4_primary_cidr_block = "10.0.0.0/24"

  assign_generated_ipv6_cidr_block = true

  context = module.this.context
}

module "dynamic_subnets" {
  source = "cloudposse/dynamic-subnets/aws"
  # Cloud Posse recommends pinning every module to a specific version
  version            = "2.4.1"
  namespace          = "eg"
  stage              = "test"
  name               = "app"
  availability_zones = ["us-east-2a","us-east-2b","us-east-2c"]
  vpc_id             = module.vpc.vpc_id
  igw_id             = [module.vpc.igw_id]
  ipv4_cidr_block    = ["10.0.0.0/24"]
}

resource "random_integer" "coin" {
  count = local.enabled ? 1 : 0
  max   = 2
  min   = 1
}

locals {
  enabled = module.this.enabled
  coin    = local.enabled ? random_integer.coin[0].result : 0
}

resource "aws_cloud9_environment_ec2" "cloud9_instance" {
  name                        = "cloud9_instance"
  instance_type               = "t3.micro"
  automatic_stop_time_minutes = 30
  image_id                    = "amazonlinux-2-x86_64"
  connection_type             = "CONNECT_SSM"
  subnet_id                   = module.dynamic_subnets.private_subnet_ids[0]
}

data "aws_iam_user" "mmubeen" {
  user_name = "mrmubeen"
}

resource "aws_cloud9_environment_membership" "mmubeen" {
  environment_id = aws_cloud9_environment_ec2.cloud9_instance.id
  permissions    = "read-write"
  user_arn       = data.aws_iam_user.mmubeen.arn
}

module "sg" {
  source = "cloudposse/security-group/aws"
  # Cloud Posse recommends pinning every module to a specific version
  version = "2.2.0"

  # Security Group names must be unique within a VPC.
  # This module follows Cloud Posse naming conventions and generates the name
  # based on the inputs to the null-label module, which means you cannot
  # reuse the label as-is for more than one security group in the VPC.
  #
  # Here we add an attribute to give the security group a unique name.
  attributes = ["primary"]

  # Allow unlimited egress
  allow_all_egress = true

  rules = [
    {
      key         = "ssh"
      type        = "ingress"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      self        = null  # preferable to self = false
      description = "Allow SSH from anywhere"
    }
  ]

  vpc_id  = module.vpc.vpc_id

  context = module.this.context
}

data "aws_instance" "cloud9_instance" {
  filter {
    name   = "tag:aws:cloud9:environment"
    values = [aws_cloud9_environment_ec2.cloud9_instance.id]
  }
}

resource "aws_ebs_volume" "cloud9_instance" {
  availability_zone = "us-east-2a"
  size              = 40

  tags = {
    Name = aws_cloud9_environment_ec2.cloud9_instance.id
  }
}

resource "aws_volume_attachment" "cloud9_instance" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.cloud9_instance.id
  instance_id = data.aws_instance.cloud9_instance.id
}