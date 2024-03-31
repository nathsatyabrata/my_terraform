/*
Setting up Infrastructure on AWS using Terraform
 
Requirements -> AWS account, terraform installed on your machine, IAM user

-> In terminal run (aws configure) command. Then need to give AWS Access Key ID, Secrect access key, select a default region and output format.

*/

# provider.tf  (Don't hard code any variable so we kept secret key and secrect access key in aws configure command)

terraform { #if you want to store your backend file (like statefile) in S3 then you can define that in terraform block
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.43.0"
    }
  }
}



provider "aws" {
  region = "us-east-1"
}

# main.tf 
/*
need to crete - VPC, subnet, internet gateway, route table, EC2 instances, IAM role, load balancer. 
*/

# VPC
resource "aws_vpc" "myvpc" {
   cidr_block = var.cidr
}
# variable.tf 
variable "cidr" {
    default = "10.0.0.0/16"
}

# Subnet
resource "aws_subnet" "sub1" {
  vpc_id = aws_vpc.myvpc.id # You can take reference of aws console for what you need 
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "sub2" {
  vpc_id = aws_vpc.myvpc.id # You can take reference of aws console for what you need 
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
}

# Internet Gateway (to allow internet)
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.myvpc.id
}
resource "aws_route_table" "rt" {
    vpc_id = aws_vpc.myvpc.id
    route{
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id # Target is internet gateway
    } 
}

resource "aws_route_table_association" "rta1" { # Connected to first subnet to routebale
  subnet_id = aws_subnet.sub1.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "rta2" { # Connected to second subnet to routebale
  subnet_id = aws_subnet.sub2.id
  route_table_id = aws_route_table.rt.id
}

# Security group
resource "aws_security_group" "webSg" {
    name = "webSg"
    vpc_id = aws_vpc.myvpc.id

    ingress {
        description = "TLS from VPC"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description = "http from VPC"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress{  #All egreess communication is allowed here
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "Web-SG"
    }
}

# S3
resource "aws_s3_bucket" "example" {
  bucket = "satyaterraformproject2024"
}

# not required for now
/*
resource "aws_s3_bucket_public_access_block" "example1" {
    bucket = aws_s3_bucket.example.id

    block_public_acls = false   
    block_public_policy = false
    ignore_public_acls = false
    restrict_public_buckets = false  
}
resource "aws_s3_bucket_acl" "example2" {
    depends_on = [
        aws_s3_bucket_ownership_controls.example1,
        aws_s3_bucket_public_access_block.example1
    ]
    bucket = aws_s3_bucket.example.id
    acl = "public-read"
}
*/

# EC2 instances

resource "aws_instance" "webserver1" {
    ami = "ami-080e1f13689e07408"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.webSg.id]
    subnet_id = aws_subnet.sub1.id
    user_data =  base64encode(file("userdata.sh"))
}

resource "aws_instance" "webserver2" {
    ami = "ami-0cd59ecaf368e5ccf"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.webSg.id]
    subnet_id = aws_subnet.sub2.id
    user_data =  base64encode(file("userdata1.sh"))
}

# Application Load Balance
resource "aws_lb" "mylb" {
  name = "mylb"
  internal = false #public LB
  load_balancer_type = "application"

  security_groups = [aws_security_group.webSg.id]
  subnets = [aws_subnet.sub1.id, aws_subnet.sub2.id]
  
  tags = {
    Name = "web"
  }
}

resource "aws_lb_target_group" "tg" {
  name = "myTG"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.myvpc.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

resource "aws_lb_target_group_attachment" "attach1" {  
  target_group_arn = aws_lb_target_group.tg.arn
  target_id = aws_instance.webserver1.id
  port = 80  
}
resource "aws_lb_target_group_attachment" "attach2" {  
  target_group_arn = aws_lb_target_group.tg.arn
  target_id = aws_instance.webserver2.id
  port = 80  
}

/*
resource "aws_lb_target_group_attachment" "attach1" {
  for_each = toset(["webserver1", "webserver2"])  
  target_group_arn = aws_lb_target_group.tg.arn
  target_id = each.key
  port = 80  
}
*/

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.mylb.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

# Output

output "loadbalancerdns" {
  value = aws_lb.mylb.dns_name  
}

#------------------------------------------------------------------------------
