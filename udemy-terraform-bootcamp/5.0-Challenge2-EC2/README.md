Challenge 2: Terraform EC2 Challenge

1. Creat a DB Server and output the private IP
2. Create a web server and ensure it has a fixed public IP
3. Create a security Group for the web server opening port 80 and 443 (HTTP and HTTPS)
4. Run the provided script bellow on the webserver (How do i add userdata to terraform script?)

```
#!/bin/bash
sudo yum update
sudo yum install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd
echo "<h1>Hello from Terraform</h1>" | sudo tee /var/www/html/index.html

```

Update this script
1. upload the resume template to github
2. add the git clone to clone the resume 

```
cd /var/www/html/
git clone "enter the github repo url here"

```


Solution:

Ways to add userdata to ec2 instance

Example 1

```
resource "aws_instance" "webserver" {
  ami           = "ami-0230bd60aa48260c6"
  instance_type = "t2.micro"

  user_data = <<EOF
  #!/bin/bash

  sudo yum update
  sudo yum install -y httpd
  sudo systemctl start httpd
  sudo systemctl enable httpd
  echo "<h1>Hello from Terraform</h1>" | sudo tee /var/www/html/index.html

  EOF
   
  tags = {
    Name = "webserver"
  }
}

```

Example 2

```
resource "aws_instance" "webserver" {
  ami           = "ami-0230bd60aa48260c6"
  instance_type = "t2.micro"

  user_data = file("userdata.sh)


  tags = {
    Name = "webserver"
  }
}

```

Complete Solution

```
provider "aws" {
    region = "us-east-1"
}


#1. Creat a DB Server and output the private IP
#2. Create a web server and ensure it has a fixed public IP
#3. Create a security Group for the web server opening port 80 and 443 (HTTP and HTTPS)
#4. Run the provided script bellow on the webserver (How do i add userdata to terraform script?)



#1. Creat a DB Server and output the private IP

##first get the desired AMI  (ami-0230bd60aa48260c6)

resource "aws_instance" "db-server" {
  ami           = "ami-0230bd60aa48260c6"
  instance_type = "t2.micro"

  tags = {
    Name = "db-server"
  }

}




#2. Create a web server and ensure it has a fixed public IP

##first get the desired AMI  (ami-0230bd60aa48260c6)
## Add an Elastic IP  (EIP)

resource "aws_instance" "webserver" {
  ami           = "ami-0230bd60aa48260c6"
  instance_type = "t2.micro"

  ##attach the security group
  security_groups = [ aws_security_group.web_traffic.name ]

#4. Run the provided script bellow on the webserver (How do i add userdata to terraform script?)
## the userdata.sh is add to the same directory as the main.tf

  user_data = file("userdata.sh")

  tags = {
    Name = "webserver"
  }
}


#3. Create a security Group for the web server opening port 80 and 443 (HTTP and HTTPS)
##Declare the varaibles (ingressrules and egressrules)
##Create ingress and egress rules using dynamic block


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
## Output the Public IP

output "db_public_ip" {
  value = "${aws_instance.db-server.public_ip}"
}

## Output the Private IP

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

```