# Terraform Module
# Terraform module is a set of terraform files inside a folder. Terraform files are like main.tf, variable.tf, output.tf, provider.tf and etc...  

module "ec2_instance" {
    source = "./module/ec2_instance" # we can fetch the module information from diffrent module like this
    ami_value = "ami-234r92iju39203984ur"  #either you can pass below information or you can pass a terraform.tfvars file
    instance_type = "t2-micro"
    subnet_id = "subnet-2345tfek245432jn345"
}
