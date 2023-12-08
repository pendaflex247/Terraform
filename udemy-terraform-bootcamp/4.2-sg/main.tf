provider "aws" {
    region = "us-east-1"
}

#first get the desired AMI  (ami-0230bd60aa48260c6)
#attach a security group to the EC2 instance

resource "aws_instance" "ec2" {
  ami           = "ami-0230bd60aa48260c6"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.webtraffic.name]

  tags = {
    Name = "my-ec2-server"
  }
}

#Create igress and egress rules to allow traffic in and out of the network
#

resource "aws_security_group" "webtraffic" {
    name = "Allow HTTPS"

    ingress {
        from_port = 443    
        to_port = 443     
        protocol = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 443    
        to_port = 443     
        protocol = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

#Why do we have a from and to port? #for incase we need And instead of  manually creating an ingress rule for every single port.
#We create a range that is why we have the from and to port.