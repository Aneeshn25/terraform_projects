#AWS Provider
provider "aws" {
  region = "us-east-2"
  access_key = "" 
  secret_key = ""
}


#VPC
resource "aws_vpc" "test" {
  cidr_block = "${var.vpc_cidr}"
  instance_tenancy = "default"

  tags = {
    Name = "test_vpc"
  }
}

resource "aws_subnet" "public" {
  count = "${length(var.subnet_cidrs_public)}"

  vpc_id = "${aws_vpc.test.id}"
  cidr_block = "${var.subnet_cidrs_public[count.index]}"
  availability_zone = "${var.availability_zones[count.index]}"

  tags = {
    Name        = "${var.public_name[count.index]}"
    Environment = "${terraform.workspace}"
  }
}

resource "aws_subnet" "private" {
  count = "${length(var.subnet_cidrs_private)}"

  vpc_id = "${aws_vpc.test.id}"
  cidr_block = "${var.subnet_cidrs_private[count.index]}"
  availability_zone = "${var.availability_zones[count.index]}"

  tags = {
    Name        = "${var.private_name[count.index]}"
    Environment = "${terraform.workspace}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.test.id}"

  tags = {
    Name = "test_IGW"
  }
}

resource "aws_eip" "nat" {
  vpc      = true
}

resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.public.*.id}"

  tags = {
    Name = "test_NAT"
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.test.id}"
  
  route {
    cidr_block = "10.0.0.0/24"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags = {
    Name = "Public_rt"
  }
}

resource "aws_default_route_table" "private" {
  default_route_table_id = "${aws_vpc.test.default_route_table_id}"

  route {
      cidr_block = "10.0.0.0/24"
      nat_gateway_id = "${aws_nat_gateway.nat.id}"
  }

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
