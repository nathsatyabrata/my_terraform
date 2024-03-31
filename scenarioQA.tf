/*
-> Migration to terraform
Q. Suppose our infrastructure in cloude formation and we want to migrate to terraform, so tell me how to do
-> We need to use Terraform import command.
But how it will work lets understand that.
-> Here we dont have any state file so we need to use Import block.
   
*/

import {
  id = "i-324rtijefvij" #instance id which you want to import
  to = aws_instance.example # We need to run below command to generate a config file to get all the info about instance
                            # terraform plan -generate-config-out=generated_resources.tf.
                            #So above command will puul all the inoformation about that instance, which id is given above. 
                            # Then we can copy all the code from that file. then paste here. and can remore that fiole and import block. because its not required now.
} 

# example of that file
resource "aws_instance" "example" {
  ami = "ami-3847567843921sd"
  #....  
}
#But now the problem is teraform doesnt understand it. Terraform will try to create a instance. Because we dont have terraform's hert and brain which is state file.
# So we need to run below command to get the state file
# terraform import aws_instance.example i-987654323456789 #(instance id)
# Now if you run (terrform paln) then it will not ask to add any resourcess. 
