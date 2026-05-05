terraform {
  backend "s3" {
    bucket         = "ssl-uat-app-buckettt"
    key            = "uat/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "ssl-uat-app-dbb"
    encrypt        = true
  }
}
