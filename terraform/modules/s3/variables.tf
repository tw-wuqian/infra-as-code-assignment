variable "bucket_name" {
  type        = string
  description = "The name of the S3 bucket"
}

variable "index_file" {
  type        = string
  description = "Path to the index.html file"
}

variable "error_file" {
  type        = string
  description = "Path to the error.html file"
}
