locals {
  default_tags = merge(
    var.defaultTags,
    { "Env" = var.env }
  )
  name_prefix = "${var.prefix}-${var.env}"
}

terraform {
  backend "s3" {
    bucket         = "acsprojectbucket"
    key            = "main/terraform.tfstate"
    region         = "us-east-1"
    encrypt = true
  }
}

module "Network" {
  source               = "../Modules/network"
  region               = var.region
  vpc                  = var.vpc
  enableDNSSupport    = var.enableDNSSupport
  enableDNSHostnames  = var.enableDNSHostnames
  publicCIDR          = var.publicCIDR
  privateCIDR         = var.privateCIDR

  env          = var.env
  defaultTags = var.defaultTags
  prefix       = var.prefix
}


data "aws_ami" "latestAmazonLinux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}


#Bastion deployment
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.latestAmazonLinux.id
  instance_type               = lookup(var.instanceType, var.env)
  key_name                    = aws_key_pair.bastionKey.key_name
  subnet_id                   = module.Network.publicSubnetID[0]
  security_groups             = [aws_security_group.webServerSG.id]
  associate_public_ip_address = true
  user_data = templatefile("${path.module}/install_httpd.sh.tpl",
    {
      env    = upper(var.env),
      prefix = upper(var.prefix)
    }
  )
  lifecycle {
    create_before_destroy = true
  }
  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-bastion-VM1"
      "Type" = "Bastion"
    }
  )
}

resource "aws_instance" "webServer" {
  count         = 3
  subnet_id     = module.Network.publicSubnetID[count.index+1]
  ami           = data.aws_ami.latestAmazonLinux.id
  instance_type = lookup(var.instanceType, var.env)
  key_name      = local.name_prefix
  security_groups = [aws_security_group.webServerSG.id]
  
  #tag_specifications 
    tags = merge(local.default_tags, {
      "Name" = "${local.name_prefix}-WebServer${count.index+2}"
      "Type" = (count.index == 0) ? "TFWebserver" : "AnsibleWebserver" 
      
    })
    user_data = (count.index == 0) ? templatefile("${path.module}/install_httpd.sh.tpl", {env=upper(var.env), prefix = upper(var.prefix)}) : null  
  }
  
  resource "aws_instance" "privateVM" {
  count         = 2
  subnet_id     = module.Network.privateSubnetID[count.index]
  ami           = data.aws_ami.latestAmazonLinux.id
  instance_type = lookup(var.instanceType, var.env)
  key_name      = local.name_prefix
  security_groups = [aws_security_group.privateVMSG.id]
  #tag_specifications 
    tags = merge(local.default_tags, {
      "Name" = "${local.name_prefix}-VM${count.index+5}"
      "Type" = "TFPrivateVM"
    })
  }

resource "aws_key_pair" "webKey" {
  key_name   = local.name_prefix
  public_key = file("${local.name_prefix}.pub")
}



resource "aws_key_pair" "bastionKey" {
  key_name   = "bastion-${local.name_prefix}"
  public_key = file("bastion-${local.name_prefix}.pub")
}


resource "aws_security_group" "webServerSG" {
  name        = "webServerSG"
  description = "Allow HTTP and SSH inbound"
  vpc_id      = module.Network.vpcID

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(local.default_tags, {
    "Name" = "${local.name_prefix}-webServerSG"
  })
}


resource "aws_security_group" "privateVMSG" {
  name        = "privateVMSG"
  description = "Allow SSH inbound"
  vpc_id      = module.Network.vpcID

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(local.default_tags, {
    "Name" = "${local.name_prefix}-privateVMSG"
  })
}