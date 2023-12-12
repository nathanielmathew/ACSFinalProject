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


data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}






# Bastion deployment
# resource "aws_instance" "bastion" {
#   ami                         = data.aws_ami.latest_amazon_linux.id
#   instance_type               = lookup(var.instance_type, var.env)
#   key_name                    = aws_key_pair.bastion_key.key_name
#   subnet_id                   = module.vpc.public_subnet_id[0]
#   security_groups             = [module.SG.ssh_sg_id]
#   associate_public_ip_address = true


#   lifecycle {
#     create_before_destroy = true
#   }

#   tags = merge(local.default_tags,
#     {
#       "Name" = "${local.name_prefix}-bastion"
#     }
#   )
# }

# resource "aws_key_pair" "web_key" {
#   key_name   = local.name_prefix
#   public_key = file("${local.name_prefix}.pub")
# }



# resource "aws_key_pair" "bastion_key" {
#   key_name   = "bastion-${local.name_prefix}"
#   public_key = file("bastion-${local.name_prefix}.pub")
# }







# module "template" {
#   source              = "../Modules/template"
#   env                 = var.env
#   default_tags        = var.default_tags
#   prefix              = var.prefix
#   instance_type       = var.instance_type
#   security_group_id   = [module.SG.ssh_sg_webservers_id, module.SG.http_sg_id]
#   key_name_webservers = aws_key_pair.web_key.key_name

# }



# module "ASG" {
#   source                    = "../Modules/ASG"
#   env                       = var.env
#   default_tags              = var.default_tags
#   prefix                    = var.prefix
#   launch_configuration_name = module.template.webservers_template_id
#   public_subnet             = module.vpc.webservers_subnet_id
#   max_size                  = var.max_size
#   min_size                  = var.min_size
#   target_group_arns         = [module.alb.target_group_arn]
#   desired_capacity          = var.desired_capacity

# }

