terraform {
  backend "s3" {
    bucket         = "ssl-prod-app-buckettt"
    key            = "prod/terraform.tfstate"
    region         = "af-south-1"
    dynamodb_table = "ssl-prod-app-dbb"
    encrypt        = true
  }
}
