Challenge 3: Module

1. Modularise Challenge 2 (EC2 Challenge)

#### Terraform EC2 Challenge

1. Creat a DB Server and output the private IP
2. Create a web server and ensure it has a fixed public IP
3. Create a security Group for the web server opening port 80 and 443 (HTTP and HTTPS)
4. Run the provided script bellow on the webserver (How do i add userdata to terraform script?)


Solution:

0. Create a folder named challenge3-module
1. Create two folders DB and Web Folders and main.tf (this will be for the module)
2. Configure their respective instance with outputs
3. Create a folder named module configure the module
4. add the register the DB and web output


#inside db folder create db.tf
#configure: the variable, the resources and the output


```
#Configure the variable

variable "dbname"{
    type = string
}

#Configure the resource

resource "aws_instance" "db-server" {
  ami           = "ami-0230bd60aa48260c6"
  instance_type = "t2.micro"

  tags = {
    Name = "db-server"
  }

}

#Configure the output

output "instance_id" {
    value = aws_instance.db-server.id
}

```

##inside web folder create web.tf
##configure: the variable, the resources and the output

```
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
    Name = "web-server"
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

#Configure the output

output "instance_id" {
    value = aws_instance.web-server.id
}

```

#### Create the module

1. crete main.tf
2. Create the db module and output
3. Create the web module and output
4. add the out output the will provide the EIP for web-server and private ip for dbserver

