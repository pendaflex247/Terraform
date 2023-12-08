provider "aws" {
    region = "us-east-1"
}

#first get the desired AMI  (ami-0230bd60aa48260c6)

resource "aws_instance" "ec2" {
  ami           = "ami-0230bd60aa48260c6"
  instance_type = "t2.micro"

  tags = {
    Name = "my-ec2-server"
  }
}