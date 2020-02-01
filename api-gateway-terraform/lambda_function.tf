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
  source_code_hash = "${filebase64sha256("getIdsFromOnicatest/lambda_function.zip")}"
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
  source_code_hash = "${filebase64sha256("getIdItemsFromOnicatest/lambda_function.zip")}"
  depends_on       = ["aws_cloudwatch_log_group.lambdacloudwatchlogs"]

  environment {
    variables = {
      simple = "API"
    }
  }
}
