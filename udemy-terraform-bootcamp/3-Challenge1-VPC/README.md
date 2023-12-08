Challege 1

1. Create a new folder called: challenge1
2. Create a VPC named "TerraformVPC"
3. CIDR Range: 192.168.0.0/24


#### Solution 1:

```
provider "aws" {
    region = "us-east-1"
}

#variable for vpc name

variable "vpcname" {
    type = string
    default = "TerraformVPC"
}


#Create VPC with CIDR range 192.168.0.0

resource "aws_vpc" "TerraformVPC" {
    cidr_block = "192.168.0.0/24"

    tags = {
      Name = var.vpcname #this will take in the default value of the vpcname variable 
    }
}

```

#### Solution 2:

```
#Create VPC with CIDR range 192.168.0.0

resource "aws_vpc" "TerraformVPC" {
    cidr_block = "192.168.0.0/24"

    tags = {
      Name = "TerraformVPC'
    }
}

```