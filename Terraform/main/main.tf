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


# module "SG" {
#   source       = "../Modules/SG"
#   env          = var.env
#   default_tags = var.default_tags
#   prefix       = var.prefix

#   vpc_id         = module.vpc.vpc_id
#   ssh_webservers = [module.SG.ssh_sg_id]

# }


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
  # security_groups             = [module.SG.ssh_sg_id]
  associate_public_ip_address = true
  lifecycle {
    create_before_destroy = true
  }
  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-bastion"
      "Type" = "Bastion"
    }
  )
}

resource "aws_instance" "webServer" {
  count         = 3
  subnet_id     = module.Network.publicSubnetID[count.index]
  ami           = data.aws_ami.latestAmazonLinux.id
  instance_type = lookup(var.instanceType, var.env)
  key_name      = var.webServerKey
  #tag_specifications 
    tags = merge(local.default_tags, {
      "Name" = "${local.name_prefix}-WebServer${count.index+1}"
      "Type" = "TFWebserver"
      
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




