
#terraform.tfstate - file name

#Statefile: statefile will store or record the information of infrastructure that it has created.
# -> State file is the heart of terraform.
# -> we we are updateing the existing infrastructure, terraform will compaire the previous statefile and then add the new iteam.

# Drawbacks of statefile
# -> If you are pussing the statefile to github, the information will compermised because it store some sensitive information about infrastructure.
# -> Another drawback is, if you update anything in existing infra then the state file will change so again we need to push that to github and may be delete the old one.

# How can we fit those drawbacks
# -> Remote Backend: Your state file should be in S3 bucket insted of local storage. 
# -> We can restrict the access for more security
# -> If you are using romote-backend logic then state file will automatically upload/update in S3. 

# backend.tf -> remote backend file for s3
terraform {
  backend "s3" { # before this creatre a S3 bucket 
    bucket = "bucket-name"
    key    = "path/terraform_example.tfsatae"
    region = "us-east-1"
    dynamodb_table = "terraform_lock"
  }
}

# You can lock the S3 so only one person and edit at same time to not grt conflictes. S3 is in dynamo DB.
resource "aws_dynamodb_table" "terraform_lock" {
        name = "terraform-lock"
        billing_mode = "PAY_PER_REQUEST"
        hash_key = "LockID"

        attribute {
          name = "LockId"
          type = "S"
        }
}


