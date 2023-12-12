#variable 


variable "defaultTags" {
  type    = map(string)
  default = {}
}

variable "prefix" {
  default = "team9project"
  type    = string
}

variable "instance_type" {
  default = {
    "prod"    = "t3.medium"
    "staging" = "t3.small"
  }
  type = map(string)
}

#Network 
#Project


variable "env" {
  default = "prod"
  type    = string
}

variable "region" {
  default = "us-east-1"
  type    = string
}

variable "vpc" {
  default = {
    "prod"    = "10.1.0.0/16"
    "staging" = "10.2.0.0/16"
  }
  type = map(string)
}


variable "enableDNSSupport" {
  type    = bool
  default = true
}

variable "enableDNSHostnames" {
  type    = bool
  default = true
}


variable "publicCIDR" {
  default = {
    "prod"    = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24", "10.1.4.0/24"]
    "staging" = ["10.2.1.0/24", "10.2.2.0/24", "10.2.3.0/24", "10.2.4.0/24"]
  }
  type = map(list(string))
}

variable "privateCIDR" {
  default = {
    "prod"    = ["10.1.5.0/24", "10.1.6.0/24"]
    "staging" = ["10.2.5.0/24", "10.2.6.0/24"]
  }
  type = map(list(string))
}




#SG

variable "vpcID" {
  default = null
  type    = string

}

#ALB
variable "security_group_id" {
  type    = list(string)
  default = null

}


variable "public_subnet" {
  default = null
  type    = list(string)
}

variable "key_name_webservers" {
  default = null
  type    = string
}

variable "launch_configuration_name" {
  default = null
  type    = string
}



variable "target_group_arns" {
  default = null
  type    = string
}

variable "desired_capacity" {
  default = "3"
  type    = number
}




variable "bucket_name" {
  default = "finalproject-acs730"
  type    = string
}

variable "path_terraform_state" {
  type    = string
  default = "main/terraform.tfstate"
}


variable "iam_policy" {
  default = null
  type    = string
}


variable "ssh_webservers" {
  type    = list(string)
  default = null
}
