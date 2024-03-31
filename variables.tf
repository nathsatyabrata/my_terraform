#Two types of variable we have: Input Variable and Output Variable

#variable.tf
# Define an input variable for the EC2 instance type
variable "instance_type" {
    description = "EC2 instance type"
    type = string
    default = "t2.micro" #this is hard-coded value
}
#Define an input variable for the EC2 instance AMI ID
variable "ami_id" {
    description = "EC2 AMI ID"
    type = string  
}

variable "subneta_id_value" {
    description = "value for the subnet_id"
  
}

#Provider.tf
# Configure the AWS provider using the input variables
provider "aws" {
    region = "us-east-1"
  
}

#main.tf
#Create an EC2 instance using the input variables
resource "aws_instance" "example_instance" {
    ami = var.ami_id
    instance_type = var.instance_type
    subnet_id = var.subneta_id_value
}

#output.tf
#Define an Output variable to expose the public IP address of the EC2 instance
output "public_ip" {
    description = "Public IP address of the EC2 instance"
    value = aws_instance.example_instance.public_ip
  
}

# inside teraform.tfvars we can write values of the variable 
# example: instance type, keypair, AMI ID, subnet ID
# When you run terrafor-apply it will look for terraform.tfvars file and then it will update inn input.tf file
# if you want to give some other name to .tfvars file (Ex: dev.tfvars) then you need to pass that file name (Ex: terraform-apply dev.tfvars)

