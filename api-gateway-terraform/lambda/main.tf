provider "aws" {
  region = "${var.AWS_REGION}"
  version = "~> 2.4"
}

// -------- Data Remote State VPC --------- //
data "terraform_remote_state" "onica_iam_role" {
  backend = "s3"

  config = {
    bucket   = "${var.bucket_remote_state}"
    key      = "env:/${var.workspace}/iam_roles/terraform.tfstate"
    region   = "${var.bucket_region}"
    role_arn = "${var.tf_mgmt_role_arn}"
  }
}

resource "aws_lambda_function" "getIdsFromOnicatest" {
  role             = "${data.terraform_remote_state.onica_iam_role.outputs.arn}"
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.7"
  filename         = "getIdsFromOnicatest/lambda_function.zip"
  function_name    = "getIdsFromOnicatest"
  source_code_hash = "${data.archive_file.lambdaGetIds.output_base64sha256}"
  depends_on       = ["aws_cloudwatch_log_group.lambdacloudwatchlogs"]

  environment {
    variables = {
      simple = "API"
    }
  }
}

resource "aws_lambda_function" "getIdItemsFromOnicatest" {
  role             = "${data.terraform_remote_state.onica_iam_role.outputs.arn}"
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.7"
  filename         = "getIdItemsFromOnicatest/lambda_function.zip"
  function_name    = "getIdItemsFromOnicatest"
  source_code_hash = "${data.archive_file.lambdaGetIdItems.output_base64sha256}"
  depends_on       = ["aws_cloudwatch_log_group.lambdacloudwatchlogs"]

  environment {
    variables = {
      simple = "API"
    }
  }
}

resource "aws_lambda_function" "postItemsToOnicatest" {
  role             = "${data.terraform_remote_state.onica_iam_role.outputs.arn}"
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.7"
  filename         = "postItemsToOnicatest/lambda_function.zip"
  function_name    = "postItemsToOnicatest"
  source_code_hash = "${data.archive_file.lambdaPostItems.output_base64sha256}"
  depends_on       = ["aws_cloudwatch_log_group.lambdacloudwatchlogs"]

  environment {
    variables = {
      simple = "API"
    }
  }
}

resource "aws_cloudwatch_log_group" "lambdacloudwatchlogs" {
  name              = "lambdacloudwatchlogs"
  retention_in_days = 30
}