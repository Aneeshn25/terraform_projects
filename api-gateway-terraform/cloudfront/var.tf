variable "AWS_REGION" { default = "us-east-2" }
variable "AWS_ACCOUNT" { default = "847058713959" }

variable "api_orgin_id" { default = "apiOnicaOrigin" }

variable "tf_mgmt_role_arn" {
  description = "Role ARN for terraform management"
  default     = "arn:aws:iam::847058713959:role/terraform_management"
}
variable "bucket_remote_state" {
  description = "S3 bucket for remote state aneesh project infrastructure"
  default     = "aneesh-terraform-remote-state-storage"
}

variable "bucket_region" {
  description = "S3 bucket region for remote state UserZoom infrastructure"
  default     = "us-east-2"
}

variable "workspace" { default = "onica-test" }