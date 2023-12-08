provider "aws" {
    region = "us-east-1"
}


# String variable

variable "vpcname" {
    type = string
    default = "myvpc"
}

# Number variable
#this variable does not get a quote 
#number or interger don't got in double qoutes

variable "sshport" {
    type = number
    default = 22
}

# Bolean variable tru or false

variable "enable" {
  default = true
}

# List variable
#this is type is either bollean, numbers or strings
# a list starts counting at zero 0,1,2...
#was of storing multiple values

variable "mylist" {
  type = list(string)
  default = [ "value1","value2","value3" ]
}

#Map Variables
#it a key value peer
#stores multiple values but to acess the value you will need a key to identify the value


variable "mymap" {
  type = map
  default = {
    Key1 = "Value1"
    Key2 = "Value2"
    Key3 = "Value3"
  }
}

# Examples usecase for the above variables
# apply only the input and output example


# Example Strings for VPC

resource "aws_vpc" "my-vpc" {
    cidr_block = "172.18.0.0/16"

    tags = {
      Name = var.vpcname #check the string variable to know how to use the string vpcname
    }
}

# Example Using List for VPC

resource "aws_vpc" "myvpc" {
    cidr_block = "172.18.0.0/16"

    tags = {
      Name = var.mylist[0]  #to access the first value use 0 second value use 1 third value use 2
    }
}

# Example using Map for VPC

resource "aws_vpc" "my-vpc" {
    cidr_block = "172.18.0.0/16"

    tags = {
      Name = var.mymap[Key1]  #to access the first value use Key1 second value use Key2 third value use Key3
    }
}

#Input variable
# Eable use to nput the nae or value we want making the code reusable

variable "inputname" {
  type = string
  description = "Set the name of the VPC"
}


#Example Input
resource "aws_vpc" "myvpc" {
    cidr_block = "172.18.0.0/16"

    tags = {
      Name = var.inputname  #this will ask you to enter the VPC name
    }
}

#Example writing output 
#the resource name, the resource, the
#to display the value of what we provisioned e.g vpc id, vpc public ip

output "vpcid" {
  value = aws_vpc.myvpc.id
}


#Tuple
#the difference between a tuple and a list
#with a list we had to explicitly say whether it's going to hold strings or numbers
#whereas now with a tuple, we specify the data types we'd like inside the list.
#it's almost identical to a list except we can support multiple data types.
#could have string number and string.

variable "mytuple" {
  type = tuple([ string, number, string ])
  default = [ "cat", 0, "dog" ]
}

#Example usecase for tuple

variable "myobje" {
  type = object({name = string, port = list(number)})
  default = {
    name = "TJ"
    port = [22, 25, 80]
  }
}


# NOTE: for the terraform exam make sure to understad tupple on an Object and a map and a list