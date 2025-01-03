provider "aws" {
  region = "eu-central-1"
}

module "s3" {
  source      = "./modules/s3"
  bucket_name = "wei-bucket-1"
}


module "iam" {
  source    = "./modules/iam"
  role_name = "jijun-iam"
  policy_statements = [
    {
      actions = ["dynamodb:PutItem", "dynamodb:GetItem"]
      resources = ["arn:aws:dynamodb:eu-central-1:160071257600:table/wei-1-tfstate-locks"]
    },
    {
      actions = ["s3:PutObject", "s3:GetObject"]
      resources = ["arn:aws:s3:::wei-bucket-1/*"]
    }
  ]
}

module "register_user_lambda" {
  source        = "./modules/lambda_api_gateway"
  lambda_role_arn = "arn:aws:iam::160071257600:role/jijun-iam"
}
