#### Static IP address

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip.html

On aws static ip is call elastic IP
you use this if you don't want the IP address of the webserver or ec2 instance to change

it always the resouce.instanceresourcename.atribute

aws_eip.ec2.id