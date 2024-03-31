#AWS

provider "aws" {
  region = "us-east-1"
}

#Azure

# provider "azurerm" {
#   subscription_id = ""
#   client_id = ""
#   client_secret = ""
#   tenant_id = ""
# }

#In your other Terraform configuration filr, you can then use the aws and azurerm providers to create resources in aws and azure respectively

resource "aws_instance" "example" {
  ami = "ami-834r320948290230982"
  instance_type = "t2.micro"  
}

# resource "azurerm_virtual_machine" "example" {
#   name = "example-vm"
#   location = "eastus"
#   size ="Standard_A1"
# }
