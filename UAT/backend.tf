terraform {
  backend "s3" {
    bucket         = "ssl-uat-app-buckettt"
    key            = "uat/terraform.tfstate"
    region         = "af-south-1"
    dynamodb_table = "ssl-uat-app-dbb"
    encrypt        = true
  }
}
