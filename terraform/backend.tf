terraform {
  backend "s3" {
    key            = "wei-bucket-1/dev/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "wei-1-tfstate-locks"
    encrypt        = true
  }
}