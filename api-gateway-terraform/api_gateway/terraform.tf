terraform {
  backend "s3" {
    encrypt        = true
    bucket         = "aneesh-terraform-remote-state-storage"
    dynamodb_table = "aneesh-terraform-state-locks"
    region         = "us-east-2"
    key            = "api_gateway/terraform.tfstate"
    profile        = "aneesh"
    role_arn       = "arn:aws:iam::847058713959:role/terraform_management"
  }
}
