data "archive_file" "lambdaGetIds" {
  type        = "zip"
  source_file = "${path.module}/getIdsFromOnicatest/lambda_function.py"
  output_path = "${path.module}/getIdsFromOnicatest/lambda_function.zip"
}

data "archive_file" "lambdaGetIdItems" {
  type        = "zip"
  source_file = "${path.module}/getIdItemsFromOnicatest/lambda_function.py"
  output_path = "${path.module}/getIdItemsFromOnicatest/lambda_function.zip"
}

data "archive_file" "lambdaPostItems" {
  type        = "zip"
  source_file = "${path.module}/postItemsToOnicatest/lambda_function.py"
  output_path = "${path.module}/postItemsToOnicatest/lambda_function.zip"
}

resource "aws_lambda_function" "getIdsFromOnicatest" {
  role             = "${aws_iam_role.LambdaDynamoAPICloudWatch.arn}"
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
  role             = "${aws_iam_role.LambdaDynamoAPICloudWatch.arn}"
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
  role             = "${aws_iam_role.LambdaDynamoAPICloudWatch.arn}"
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
