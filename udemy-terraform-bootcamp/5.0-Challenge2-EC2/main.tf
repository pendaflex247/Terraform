provider "aws" {
    region = "us-east-1"
}

#1. Creat a DB Server and output the private IP

resource "aws_instance" "db-server" {
  ami           = "ami-0230bd60aa48260c6"
  instance_type = "t2.micro"

  tags = {
    Name = "db-server"
  }

}

#2. Create a web server and ensure it has a fixed public IP

resource "aws_instance" "webserver" {
  ami           = "ami-0230bd60aa48260c6"
  instance_type = "t2.micro"
  security_groups = [ aws_security_group.web_traffic.name ]

#4. Run the provided script bellow on the webserver (How do i add userdata to terraform script?)

  user_data = file("userdata.sh")

  tags = {
    Name = "webserver"
  }
}


#3. Create a security Group for the web server opening port 80 and 443 (HTTP and HTTPS)

variable "ingressrules" {
    type = list(number)
    default = [80,443]
}

variable "egressrules" {
    type = list(number)
    default = [80,443]
}


resource "aws_security_group" "web_traffic" {
    name = "Allow Web traffic"

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

#Out puting The public and private ip has to be outside the ec2 block

output "db_public_ip" {
  value = "${aws_instance.db-server.public_ip}"
}

output "db_private_ip" {
  value = "${aws_instance.db-server.private_ip}"
}

##Add the elastic IP

resource "aws_eip" "elasticip" {
  instance = aws_instance.webserver.id
}

##Output webserver the EIP

output "Webserver-eip" {
  value = aws_eip.elasticip.public_ip 
}
