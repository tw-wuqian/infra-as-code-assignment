variable "role_name" {
  type        = string
  description = "The name of the IAM role for the Lambda function"
}

variable "policy_statements" {
  type        = list(object({
    actions   = list(string)
    resources = list(string)
  }))
  description = "Policy statements defining permissions for the Lambda function"
}
