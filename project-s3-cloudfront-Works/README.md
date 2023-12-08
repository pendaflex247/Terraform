#Things to add to a VPC




#Create VPC
#Terraform aws create vpc
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc.html
#resource type aws_vpc
#logical/reference name vpc (will be used only with the terraform script)

```
resource "aws_vpc" "vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true
  assign_generated_ipv6_cidr_block = true

  tags = {
    Name = "TerraformVPC"
  }
}

```
Main commands

terraform init
terraform plan
terraform apply
terraform destory



Refrences:

https://gist.github.com/danihodovic/a51eb0d9d4b29649c2d094f4251827dd