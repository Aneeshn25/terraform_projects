provider "aws" {
  region = "${var.AWS_REGION}"
  version = "~> 2.4"
}

#Creating a Dynamodb table onicatest
resource "aws_dynamodb_table" "onica" {
  name           = "${var.table_name}"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "${var.hash}"

  attribute {
    name = "id"
    type = "S"
  }


  tags = {
    Name        = "dynamodb-table-1"
    Environment = "production"
  }
}

#inserting an item
resource "aws_dynamodb_table_item" "init-items" {
  table_name = "${aws_dynamodb_table.onica.name}"
  hash_key = "${aws_dynamodb_table.onica.hash_key}"
  item = "${data.template_file.items.rendered}"
}
