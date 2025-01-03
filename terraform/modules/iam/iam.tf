resource "aws_iam_role" "lambda_role" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "lambda_policy" {
  name        = var.role_name
  description = "IAM policy for the Lambda function"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      for statement in var.policy_statements : {
        Effect   = "Allow"
        Action   = statement.actions
        Resource = statement.resources
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem"
        ],
        Resource = "arn:aws:dynamodb:eu-central-1:160071257600:table/wei-1-tfstate-locks"
      },
      {
        Effect   = "Allow",
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        "Effect" : "Allow",
        "Action" : "lambda:InvokeFunction",
        Resource = "arn:aws:lambda:eu-central-1:160071257600:function:registerUser"
      },
      {
        "Effect": "Allow",
        "Action": "s3:GetObject",
        "Resource": "arn:aws:s3:::jijun-s3/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}
