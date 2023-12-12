# Default tags
variable "defaultTags" {
  default = {}
  type    = map(any)

}


# Name prefix
variable "prefix" {
  type = string
}


variable "env" {
  type = string
}


variable "region" {
  type = string
}

variable "vpc" {
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

variable "enableDNS" {
  type    = bool
  default = true
}

variable "publicCIDR" {
  type = map(list(string))
}

variable "privateCIDR" {
  type = map(list(string))
}



/*
variable "create_s3_endpoint" {
  type        = bool
}

variable "create_cloudwatch_logs_endpoint" {
  type        = bool
}
*/