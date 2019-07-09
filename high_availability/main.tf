#AWS Provider
provider "aws" {
  region = "us-east-2"
  access_key = "AKIA2J7U6ODZGYQHOB7Y" 
  secret_key = "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"
}


#VPC
resource "aws_vpc" "test_vpc" {
  cidr_block = "${var.vpc_cidr}"
  instance_tenancy = "default"

  tags = {
    Name = "test_vpc"
  }
}

resource "aws_subnet" "public" {
  count = "${length(var.subnet_cidrs_public)}"

  vpc_id = "${aws_vpc.test_vpc.id}"
  cidr_block = "${var.subnet_cidrs_public[count.index]}"
  availability_zone = "${var.availability_zones[count.index]}"

  tags = {
    Name        = "${var.public_name[count.index]}"
    Environment = "${terraform.workspace}"
  }
}

resource "aws_subnet" "private" {
  count = "${length(var.subnet_cidrs_private)}"

  vpc_id = "${aws_vpc.test_vpc.id}"
  cidr_block = "${var.subnet_cidrs_private[count.index]}"
  availability_zone = "${var.availability_zones[count.index]}"

  tags = {
    Name        = "${var.private_name[count.index]}"
    Environment = "${terraform.workspace}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.test_vpc.id}"

  tags = {
    Name = "Public_rt"
  }
}

resource "aws_default_route_table" "private" {
  default_route_table_id = "${aws_vpc.test_vpc.default_route_table_id}"

  #route {
    # ...
  #}

  tags = {
    Name = "Private_rt"
  }
}

resource "aws_route_table_association" "public" {
  count = "${length(var.subnet_cidrs_public)}"

  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "private" {
  count = "${length(var.subnet_cidrs_private)}"

  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${aws_default_route_table.private.id}"
}
