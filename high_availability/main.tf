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


#Public subnet
resource "aws_subnet" "public" {
  count = "${length(var.subnet_cidrs_public)}"

  vpc_id = "${aws_vpc.test.id}"
  cidr_block = "${var.subnet_cidrs_public[count.index]}"
  availability_zone = "${var.availability_zones[count.index]}"
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.public_name[count.index]}"
    Environment = "${terraform.workspace}"
  }
}


#Private subnet
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


#Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.test.id}"

  tags = {
    Name = "test_IGW"
  }
}


#Elastic IP
resource "aws_eip" "nat" {
  vpc      = true
}


#NAT gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${element(aws_subnet.public.*.id, 0)}"

  tags = {
    Name = "test_NAT"
  }
}


#route table for public subnet 
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.test.id}"
  
  #adding internet gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags = {
    Name = "Public_rt"
  }
}


#default route table for private subnet
resource "aws_default_route_table" "private" {
  default_route_table_id = "${aws_vpc.test.default_route_table_id}"
  
  #adding nat gateway
  route {
      cidr_block = "0.0.0.0/0"
      nat_gateway_id = "${aws_nat_gateway.nat.id}"
  }

  tags = {
    Name = "Private_rt"
  }
}


#public route table association
resource "aws_route_table_association" "public" {
  count          = "${length(var.subnet_cidrs_public)}"

  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

#private route table association
resource "aws_route_table_association" "private" {
  count          = "${length(var.subnet_cidrs_private)}"

  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${aws_default_route_table.private.id}"
}


## Security Group for ELB
resource "aws_security_group" "elb" {
  name          = "terraform-example-elb"
  vpc_id        = "${aws_vpc.test.id}"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
        Name = "Security Group ELB"
  }
}


#Elastic load balancing
resource "aws_elb" "elb" {
  name                  = "testelb"
  security_groups       = ["${aws_security_group.elb.id}"]
  #availability_zones   = ["${var.availability_zones[0]}","${var.availability_zones[1]}","${var.availability_zones[2]}"]
  subnets               = "${aws_subnet.public.*.id}"
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "HTTP:80/index.html"
  }
  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = "80"
    instance_protocol = "http"
  }
}


#Security Group for Launch config
resource "aws_security_group" "lc_sg" {
  name        = "lc_sg"
  description = "Allow HTTP inbound traffic"
  vpc_id      = "${aws_vpc.test.id}"

  #allow http
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #allow ssh
  #ingress {
  #  from_port   = 22
  #  to_port     = 22
  #  protocol    = "tcp"
  #  cidr_blocks = ["0.0.0.0/0"]
  #}

  tags = {
        Name = "Security Group lc"
  }

  
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}


#Launch Configuration
resource "aws_launch_configuration" "lc" {
  name_prefix      = "terraform-lc-"
  image_id         = "${data.aws_ami.ubuntu.id}"
  instance_type    = "${var.instance_type}"
  security_groups  = ["${aws_security_group.lc_sg.id}"]
  key_name         = "${var.key_name}"
  user_data        = "${data.template_file.app.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}


#Autoscaling Group
resource "aws_autoscaling_group" "asg" {
  name                 = "terraform-asg"
  launch_configuration = "${aws_launch_configuration.lc.name}"
  min_size             = 1
  desired_capacity     = 2
  max_size             = 4
  health_check_type    = "ELB"
  vpc_zone_identifier  = "${aws_subnet.private.*.id}"
  load_balancers       = ["${aws_elb.elb.name}"]


  lifecycle {
    create_before_destroy = true
  }
}
