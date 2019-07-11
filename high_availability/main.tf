#AWS Provider
provider "aws" {
  region = "${var.AWS_REGION}"
  access_key = "${var.AWS_ACCESS_KEY}" 
  secret_key = "${var.AWS_SECRET_KEY}"
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
  count    = "3"
  vpc      = true
}


#NAT gateway
resource "aws_nat_gateway" "nat" {
  count         = "3"
  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.public.*.id, count.index)}"

  tags = {
    Name = "test_NAT"
  }
}


#route table for public subnet 
resource "aws_default_route_table" "public" {
  default_route_table_id = "${aws_vpc.test.default_route_table_id}"
  
  
  #adding internet gateway
  route {
    cidr_block  = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags = {
    Name = "Public_rt"
  }
}

#default route table for private subnet

resource "aws_route_table" "private" {
  count  = "${length(var.subnet_cidrs_private)}"
  vpc_id = "${aws_vpc.test.id}"
  
  tags = {
    Name = "${var.private_rt[count.index]}"
  }
}

resource "aws_route" "gw" {
  count          = "${length(var.subnet_cidrs_private)}"
  route_table_id = "${element(aws_route_table.private.*.id,count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = "${element(aws_nat_gateway.nat.*.id,count.index)}"
}

#public route table association
resource "aws_route_table_association" "public" {
  count          = "${length(var.subnet_cidrs_public)}"

  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_default_route_table.public.id}"
}

#private route table association
resource "aws_route_table_association" "private" {
  count          = "${length(var.subnet_cidrs_private)}"

  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
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

  tags = [
    {
      key                 = "Name"
      value               = "${var.instance_name_autogroup}"
      propagate_at_launch = true
    },
  ]

  lifecycle {
    create_before_destroy = true
  }
}

# scale up alarm
resource "aws_autoscaling_policy" "asg-cpu-policy" {
    name = "asg-cpu-policy"
    autoscaling_group_name = "${aws_autoscaling_group.asg.name}"
    adjustment_type = "ChangeInCapacity"
    scaling_adjustment = "1"
    cooldown = "300"
    policy_type = "SimpleScaling"
}
resource "aws_cloudwatch_metric_alarm" "asg-cpu-alarm" {
    alarm_name = "${aws_autoscaling_group.asg.name}-cpu-alarm"
    alarm_description = "asg-cpu-alarm"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods = "2"
    namespace = "AWS/EC2"
    statistic = "Average"
    metric_name = "CPUUtilization"
    period = "120"
    threshold = "80"
    dimensions = {
    "AutoScalingGroupName" = "${aws_autoscaling_group.asg.name}"
}
actions_enabled = true
    alarm_actions = ["${aws_autoscaling_policy.asg-cpu-policy.arn}"]
}


# scale down alarm
resource "aws_autoscaling_policy" "cpu-policy-scaledown" {
    name = "example-cpu-policy-scaledown"
    autoscaling_group_name = "${aws_autoscaling_group.asg.name}"
    adjustment_type = "ChangeInCapacity"
    scaling_adjustment = "-1"
    cooldown = "300"
    policy_type = "SimpleScaling"
}
resource "aws_cloudwatch_metric_alarm" "cpu-alarm-scaledown" {
    alarm_name = "${aws_autoscaling_group.asg.name}-cpu-alarm-scaledown"
    alarm_description = "cpu-alarm-scaledown"
    comparison_operator = "LessThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = "120"
    statistic = "Average"
    threshold = "50"
    dimensions = {
    "AutoScalingGroupName" = "${aws_autoscaling_group.asg.name}"
}
actions_enabled = true
    alarm_actions = ["${aws_autoscaling_policy.cpu-policy-scaledown.arn}"]
}
