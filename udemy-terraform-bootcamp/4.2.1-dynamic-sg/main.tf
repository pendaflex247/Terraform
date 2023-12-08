provider "aws" {
    region = "us-east-1"
}

#Add two variables for dynamic blocks
#first get the desired AMI  (ami-0230bd60aa48260c6)
#attach a security group to the EC2 instance

variable "ingressrules" {
    type = list(number)
    default = [80,443]
}

variable "egressrules" {
    type = list(number)
    default = [80,443,25,3306,53,8080]
}


resource "aws_instance" "ec2" {
  ami           = "ami-0230bd60aa48260c6"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.webtraffic.name]

  tags = {
    Name = "my-ec2-server"
  }
}

#Create ingress and egress rules to allow traffic in and out of the network
#

resource "aws_security_group" "webtraffic" {
    name = "Allow HTTPS"

    dynamic "ingress" {
        iterator = port
        for_each = var.ingressrules
        content{
            from_port = port.value
            to_port = port.value
            protocol = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
        }
    }

    dynamic "egress" {
        iterator = port
        for_each = var.egressrules
        content{
            from_port = port.value
            to_port = port.value
            protocol = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
        }
    }
}
