# inside teraform.tfvars we can write values of the variable 
# example: instance type, keypair, AMI ID, subnet ID
# When you run terrafor-apply it will look for terraform.tfvars file and then it will update inn input.tf file
# if you want to give some other name to .tfvars file (Ex: dev.tfvars) then you need to pass that file name (Ex: terraform-apply dev.tfvars)

ami_id = "ami-3848392jwnd8392012"
instance_type = "t2.micro"
subneta_id_value = "subnet-98uhn098u89098998"
