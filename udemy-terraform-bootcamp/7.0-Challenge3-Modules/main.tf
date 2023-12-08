provider "aws" {
    region = "us-east-1"
}

# db module
module "dbmodule" {
    source = "./db"
    dbname = "DB-Server" 
}

#db module output
output "db_module_output" {
  value = module.dbmodule.instance_id
}

#Out puting The db public and private ip has to be outside the ec2 block

output "db_public_ip" {
  value = module.dbmodule.db_public_ip
}

output "db_private_ip" {
  value = module.dbmodule.db_private_ip
}



# web-server module
module "webmodule" {
    source = "./web"
    webname = "Web-Server" 
}

#webserver module output
output "web_module_output" {
  value = module.webmodule.instance_id
}

##Output webserver the EIP

output "Webserver-eip" {
  value = module.webmodule.Webserver-eip 
}

