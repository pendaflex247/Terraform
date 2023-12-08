provider "aws" {
    region = "us-east-1"
}

#Chhlenege 
#Create a VPC 
#that will allow you input the VPC name TerraformVPC and CIDR 192.168.0.0/24
#Output the VPC ID

#1. input variable to allow me input me name of the VPC 

variable "inputname" {
  type = string
  description = "Enter the name for the VPC"
}

#2. input CIDR block

variable "cidrblock" {
    type = string
    description = "Enter the cidr block range i.e 172.16.0.0/24"
}

#Definning the VPC

resource "aws_vpc" "TerraformVPC" {
    cidr_block = var.cidrblock

    tags = {
      Name = var.inputname  #this will ask you to enter the VPC name
    }
}


#Output the VPC ID upon completion

output "vpcid" {
  value = aws_vpc.TerraformVPC.id
}