provider "aws" {
  region = "eu-west-2"
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
      resources = ["arn:aws:s3:::my-static-website-bucket/*"]
    }
  ]
}

# module "register_user_lambda" {
#   source        = "./modules/lambda_api_gateway"
#   function_name = "jijun_register_user"
#   runtime       = "nodejs16.x"
#   handler       = "jijun_register_user.handler"
#   role_arn      = module.iam.lambda_role_arn
#   source_file   = "build/register_user.zip"
#   environment_variables = { TABLE_NAME = module.dynamodb.table_name }
# }
