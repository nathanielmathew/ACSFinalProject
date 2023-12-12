output "BastionPublicIP"{
    value = aws_instance.bastion.public_ip
}

# output "WebServerPublicIPs"{
#     value = aws_instance.publicSubnet.*.id
# }

# output "PrivateVMPrivateIPs"{
#     value = aws_instance.
# }