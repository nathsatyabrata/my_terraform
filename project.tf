#app.py

# from flask import Flask
# app = Flask(__name__)
# @app.rout("/")
# def hello():
#     return "Hello, Terraform!"
# if __name__ : "__main__"
# app.run(host="0.0.0.0", port=80)

# Define the AWS Provider configuration
provider "aws" {
    region = "us-east-1"  
}

#To create VPC we need CIDR block
variable "cidr" {
    default = "10.0.0.0/16" #this cidr block is for VPC
}

resource "aws_key_pair" "example" {
    key_name = "terraform-demo-satya"  #relpace with your key name
    public_key = file("~/.ssh/id_ras.pub") #replace with the path to your public key file
}

resource "aws_vpc" "myvpc" {
    cidr_block = var.cidr
}

resource "aws_subnet" "sub1" {  
    vpc_id = aws_vpc.myvpc.id #this is indicating that this subnet will be attached to above VPC
    cidr_block = "10.0.0.0/24" #This cider block is subnet sider blok and above one is VPC cider block
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true #if you want a public ip
}

#above one is not a public subne to make it public we need Rout table and internet gateway and need to attached both.

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.myvpc.id
  
}

resource "aws_route_table" "RT" {
    vpc_id = aws_vpc.myvpc.id

    route { #destination
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    } 
}

resource "aws_route_table_association" "rtal" {
    subnet_id = aws_subnet.sub1.id
    route_table_id = aws_route_table.RT.id  
}

resource "aws_security_group" "webSg" {
    name = "web"
    vpc_id = aws_vpc.myvpc.id

    ingress {
        description = "HTTP from VPC"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description = "SSH"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
      Name = "Web-sg"
    }
}

# EC2 instance configuration
resource "aws_instance" "server" {
    ami = "ami-2983764yr8392k478392"
    instance_type = "t2-micro"
    key_name = aws_key_pair.example.key_name
    vpc_security_group_ids = [aws_security_group.webSg.id]
    subnet_id = aws_subnet.sub1.id

    connection { # how to connect to the instance
      type = "ssh"
      user = "ubuntu" #username
      private_key = file("~/.ssh/id_rsa")
      host = self.public_ip # if you are inside the resource block then can use self otherwise if you are outside of resource block then use (resource-type.resorusename.public_ip)
    }
}

# To Use provisione you need to connect to the instance
# File provisioner to copy a file form local to the remote EC2 instance

# provisioner "file" {
#     source = "app.py" # Replace with the path to your local file
#     destinition = "/home/ubuntu/app.py" #Replace with the path on the remote instance  
# }

# provisioner "remote-exec" {
#     inline = [ 
#             "echon 'Hello from the remote instance",
#             "sudo apt update -y",
#             "sudo apt-get install -y python3-pip",
#             "cd /home/ubuntu",
#             "sudo pip3 install flask",
#             "sudo python3 app.py &",
#         ]
# }


