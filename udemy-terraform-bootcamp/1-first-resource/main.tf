provider "aws" {
    region = "us-east-1"
}

resource "aws_vpc" "nb-vpc" {
    cidr_block = "172.18.0.0/16"
}