Here we will learn about Terraform (HashiCorp Configuration Language ) and then create below AWS resources.
1. VPC
2. Subnet
3. Internet Gateway
4. Route Table
5. Security Group
6. S3 
7. EC2
8. Application Load Balancer
9. LB Target Group
10. LB listener


to install terraform in you system run below command
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update
sudo apt install terraform

Validation:
terraform -v
