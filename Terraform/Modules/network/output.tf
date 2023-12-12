output "vpcID" {
  value = aws_vpc.VPC.id
}


output "publicSubnetID" {
  value = aws_subnet.publicSubnet.*.id
}

output "privateSubnetID" {
  value = aws_subnet.privateSubnet.*.id
}