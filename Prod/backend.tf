terraform {
  backend "s3" {
    bucket         = "ssl-prod-app-buckettt"
    key            = "prod/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "ssl-prod-app-dbb"
    encrypt        = true
  }
}
