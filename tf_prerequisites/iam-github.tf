data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

resource "aws_iam_role" "github_actions_role" {
  name = format("%s-github-actions-role", var.prefix)

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess",
    "arn:aws:iam::aws:policy/AmazonVPCFullAccess",
    "arn:aws:iam::aws:policy/AmazonECS_FullAccess",
    "arn:aws:iam::aws:policy/AmazonRDSFullAccess",
  ]

  inline_policy {
    name = "extra_permissions"

    policy = jsonencode(
      {
      Version = "2012-10-17"
      Statement = [
        {
          "Effect" : "Allow",
          "Action" : [
            "s3:*Bucket*",
          ],
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "s3:*",
          ],
          "Resource" : ["arn:aws:s3:::${var.prefix}-tfstate", "arn:aws:s3:::${var.prefix}-tfstate/*"]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "dynamodb:*",
          ],
          "Resource" : format("arn:aws:dynamodb:%s:%s:table/%s-tfstate-locks*", data.aws_region.current.id, data.aws_caller_identity.current.id, var.prefix)
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "dynamodb:CreateTable",
            "dynamodb:PutItem",
            "dynamodb:GetItem",
            "dynamodb:DescribeTable"
          ],
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "secretsmanager:*",
          ],
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "logs:*",
          ],
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ecr:*"
          ],
          "Resource" : format("arn:aws:ecr:*:%s:repository/*", data.aws_caller_identity.current.id)
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "iam:PassRole",
            "iam:*Role*",
            "iam:*Policy*"
          ],
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ecr:GetAuthorizationToken"
          ],
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "s3:GetAccelerateConfiguration"
          ],
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "s3:GetLifecycleConfiguration"
          ],
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "s3:GetReplicationConfiguration"
          ],
          "Resource" : "*"
        }
      ]
    })
  }

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = format("arn:aws:iam::%s:oidc-provider/token.actions.githubusercontent.com", data.aws_caller_identity.current.id)
        }
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          "StringLike" : {
            "token.actions.githubusercontent.com:sub" : "repo:tw-wuqian/infra-as-code-assignment:*"
          },
          "ForAllValues:StringEquals" : {
            "token.actions.githubusercontent.com:iss" : "https://token.actions.githubusercontent.com",
            "token.actions.githubusercontent.com:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}