data "archive_file" "lambdagetIds" {
  type        = "zip"
  source_file = "${path.module}/getIdsFromOnicatest/lambda_function.py"
  output_path = "${path.module}/getIdsFromOnicatest/lambda_function.zip"
}

data "archive_file" "lambdagetIdItems" {
  type        = "zip"
  source_file = "${path.module}/getIdItemsFromOnicatest/lambda_function.py"
  output_path = "${path.module}/getIdItemsFromOnicatest/lambda_function.zip"
}

resource "aws_lambda_function" "getIdsFromOnicatest" {
  role             = "${aws_iam_role.LambdaDynamoAPICloudWatch.arn}"
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.7"
  filename         = "getIdsFromOnicatest/lambda_function.zip"
  function_name    = "getIdsFromOnicatest"
  source_code_hash = "${data.archive_file.lambdagetIds.output_base64sha256}"
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
  source_code_hash = "${data.archive_file.lambdagetIdItems.output_base64sha256}"
  depends_on       = ["aws_cloudwatch_log_group.lambdacloudwatchlogs"]

  environment {
    variables = {
      simple = "API"
    }
  }
}
