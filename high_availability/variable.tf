variable "AWS_ACCESS_KEY" { default = "access_key"}
variable "AWS_SECRET_KEY" { default = "security_key" }
variable "AWS_REGION" { default = "us-east-2" }

variable "vpc_cidr" {
	default = "10.0.0.0/21"
}

variable "subnet_cidrs_public" {
  type    = "list"
  default = ["10.0.2.0/25", "10.0.4.0/25", "10.0.6.0/25"]
}

variable "subnet_cidrs_private" {
  type    = "list"
  default = [ "10.0.1.0/25", "10.0.3.0/25", "10.0.5.0/25"]
}

variable "instance_name_autogroup" {
	default = "webserver-asg-test"
}

variable "public_name" {
	type    = "list"
	default = ["subnet-public-us-e2a", "subnet-public-us-e2b", "subnet-public-us-e2c"]
}

variable "private_name" {
	type    = "list"
	default = ["subnet-private-us-e2a", "subnet-private-us-e2b", "subnet-private-us-e2c"]
}

variable "private_rt" {
	type    = "list"
	default = ["private-rt-1", "private-rt-2", "private-rt-3"]
}

variable "availability_zones" {
  description = "AZs in this region to use"
  default = ["us-east-2a", "us-east-2b", "us-east-2c"]
  type = "list"
}

#variable "ami" {
#	default = "ami-05bab2b5ef946e505"
#}

variable "instance_type" {
	default = "t2.micro"
}

variable "key_name" {
  description = "Key name for SSHing into EC2"
  default = "aneesh"
}
