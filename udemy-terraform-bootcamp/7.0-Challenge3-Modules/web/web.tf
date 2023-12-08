
#Configure the variable

variable "webname"{
    type = string
}

#Configure the resource


resource "aws_instance" "web-server" {
  ami           = "ami-0230bd60aa48260c6"
  instance_type = "t2.micro"

  ##Attach security group
  security_groups = [ aws_security_group.web_traffic.name ]

#4. Run the provided script bellow on the webserver (How do i add userdata to terraform script?)

  user_data = file("userdata.sh")

  tags = {
    Name = var.webname
  }
}

variable "ingressrules" {
    type = list(number)
    default = [80,443]
}

variable "egressrules" {
    type = list(number)
    default = [80,443]
}

##Add security group
##And attache it to the webserver

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

##Add the elastic IP

resource "aws_eip" "elasticip" {
  instance = aws_instance.web-server.id
}

##Output webserver the EIP

output "Webserver-eip" {
  value = aws_eip.elasticip.public_ip 
}


#Configure the output

output "instance_id" {
    value = aws_instance.web-server.id
}
