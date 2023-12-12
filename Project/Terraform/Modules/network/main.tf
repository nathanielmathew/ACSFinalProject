# VPC - 
# subnet and route table for subnet  (3 public, 1 prviate
# Nat Gatway
# Internet Gateway
# Gateway Endpoint to go for S3

provider "aws" {
  region = var.region #"us-east-1"
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals{
    defaultTags = merge(
    var.defaultTags,
    { "Env" = var.env }
  )
  name_prefix = "${var.prefix}-${var.env}"
}

resource "aws_vpc" "VPC" {
  cidr_block           = var.vpc[var.env]
  instance_tenancy     = "default"
  enable_dns_support   = var.enableDNSSupport
  enable_dns_hostnames = var.enableDNSHostnames
  tags = merge(
    local.defaultTags, {
      Name = "${local.name_prefix}-vpc"
    }
  )
}

# Public_subnet
resource "aws_subnet" "publicSubnet" {
  count                   = length(var.publicCIDR[var.env])
  vpc_id                  = aws_vpc.VPC.id
  cidr_block              = var.publicCIDR[var.env][count.index]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  tags = merge(
    local.defaultTags, {
      Name = "${local.name_prefix}-public-subnet-${count.index + 1}"
    }
  )
}

# Add provisioning of the private subnet the default VPC
resource "aws_subnet" "privateSubnet" {
  count             = length(var.privateCIDR[var.env])
  vpc_id            = aws_vpc.VPC.id
  cidr_block        = var.privateCIDR[var.env][count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge(
    local.defaultTags, {
      Name = "${local.name_prefix}-private-subnet-${count.index + 1}"
    }
  )
}

#  Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.VPC.id
  tags = merge(
    local.defaultTags, {
      "Name" = "${local.name_prefix}-igw"
    }
  )

}


resource "aws_route_table" "publicRouteTable" {
  vpc_id = aws_vpc.VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(
    local.defaultTags, {
      Name = "${local.name_prefix}-public-route_table"
    }
  )
}


resource "aws_route_table_association" "publicSubnetRTAssociation" {
  count          = length(aws_subnet.publicSubnet)
  subnet_id      = aws_subnet.publicSubnet[count.index].id
  route_table_id = aws_route_table.publicRouteTable.id
}

# resource "aws_route_table_association" "webservers_subnet_routetable_assoication" {
#   count          = length(aws_subnet.privateSubnet)
#   subnet_id      = aws_subnet.privateSubnet[count.index].id
#   route_table_id = aws_route_table.webservers_private_routetable.id
# }