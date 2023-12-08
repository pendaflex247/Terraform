#Configure the variable

variable "dbname"{
    type = string
}

#Configure the resource

resource "aws_instance" "db-server" {
  ami           = "ami-0230bd60aa48260c6"
  instance_type = "t2.micro"

  tags = {
    Name = var.dbname
  }

}

#Configure the output

output "instance_id" {
    value = aws_instance.db-server.id
}


#Out puting The public and private ip has to be outside the ec2 block

output "db_public_ip" {
  value = aws_instance.db-server.public_ip
}

output "db_private_ip" {
  value = aws_instance.db-server.private_ip
}