terraform {
  backend "s3" {
    bucket         = "ssl-dev-app-buckettt"
    key            = "dev/terraform.tfstate"
    region         = "af-south-1"
    dynamodb_table = "ssl-dev-app-dbb"
    encrypt        = true
  }
}
