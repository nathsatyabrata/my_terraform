provider "aws" {
    alias = "us-east-1"
    region = "us-east-1"  
}

provider "aws" {
    alias = "us-west-2"
    region = "us-west-2"
}

resource "aws_instance" "example" {
    ami = "ami-7834r9873457334"
    instance_type = "t2-micro"
    provider = "aws.us-east-1"  
}

resource "aws_instance" "example2" {
    ami = "ami-238475674839202xc"
    instance_type = "t2-micro"
    provider = "aws.us-west-2"
}
