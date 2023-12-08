provider "aws" {
    region = "us-east-1"
}

#first get the desired AMI  (ami-0230bd60aa48260c6)

resource "aws_instance" "ec2" {
  ami           = "ami-0230bd60aa48260c6"
  instance_type = "t2.micro"

  tags = {
    Name = "my-eip-ec2-server"
  }
}

#For the elastic IP

resource "aws_eip" "elasticip" {
  instance = aws_instance.ec2.id
}

#Output the EIP

output "EIP" {
  value = aws_eip.elasticip.public_ip #to know this value check the documentation
}