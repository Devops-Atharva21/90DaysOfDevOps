### Provider 

provider "aws" {
  region = "us-west-2"
}

### Common Tags

locals {
  common_tags = {
    Enviroment = "Dev"
    Project    = "Automation"
  }
}

### VPC

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = merge(
    local.common_tags,
    {
      Name = "terraweek-vpc"
    }
  )
}

### Public Subnet 

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  tags = merge(
    local.common_tags,
    {
      Name = "terraweek-public-subnet"
    }
  )
}

### Ubuntu Linux AMI

data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

### Security Group Module

module "web_sg" {
  source        = "./modules/security-group"
  vpc_id        = aws_vpc.main.id
  sg_name       = "terraweek-web-sg"
  ingress_ports = [22, 80, 443]
  tags          = local.common_tags
}


### Web Server Module

module "web_server" {
  source            = "./modules/ec2-instance"
  ami_id            = data.aws_ami.ubuntu.id
  instance_type     = "t3.micro"
  subnet_id         = aws_subnet.public.id
  security_group_id = module.web_sg.sg_id
  instance_name     = "terraweek-web"
  tags              = local.common_tags
}


### API Server Module

module "api_server" {
  source            = "./modules/ec2-instance"
  ami_id            = data.aws_ami.ubuntu.id
  instance_type     = "t3.micro"
  subnet_id         = aws_subnet.public.id
  security_group_id = module.web_sg.sg_id
  instance_name     = "terraweek-api"
  tags              = local.common_tags
}
