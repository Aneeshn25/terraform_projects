variable "vpc_cidr" {
	default = "10.0.0.0/24"
}

variable "subnet_cidrs_public" {
  type    = "list"
  default = ["10.0.0.0/26", "10.0.0.64/26"]
}

variable "subnet_cidrs_private" {
  type    = "list"
  default = ["10.0.0.128/26", "10.0.0.192/26"]
}

variable "public_name" {
	type    = "list"
	default = ["public-1", "public-2"]
}

variable "private_name" {
	type    = "list"
	default = ["private-1", "private-2"]
}

variable "availability_zones" {
  description = "AZs in this region to use"
  default = ["us-east-2a", "us-east-2b", "us-east-2c"]
  type = "list"
}

variable "ami" {
	default = "ami-05bab2b5ef946e505"
}

variable "instance_type" {
	default = "t2.micro"
}

variable "key_name" {
  description = "Key name for SSHing into EC2"
  default = "aneesh"
}
