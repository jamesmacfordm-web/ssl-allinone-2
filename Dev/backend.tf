terraform {
  backend "s3" {
    bucket         = "ssl-dev-app-buckettt"
    key            = "dev/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "ssl-dev-app-dbb"
    encrypt        = true
  }
}
