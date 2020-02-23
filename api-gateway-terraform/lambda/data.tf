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
