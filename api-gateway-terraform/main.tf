provider "aws" {
  region = "${var.AWS_REGION}"
  access_key = "${var.AWS_ACCESS_KEY}" 
  secret_key = "${var.AWS_SECRET_KEY}"
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


#API Gateway Configuration
resource "aws_api_gateway_rest_api" "onicaTestAPI" {
  name        = "onicaTestAPI"
  description = "RESTAPI for dynamodb table onicatest"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "id-api-resource" {
  rest_api_id = "${aws_api_gateway_rest_api.onicaTestAPI.id}"
  parent_id   = "${aws_api_gateway_rest_api.onicaTestAPI.root_resource_id}"
  path_part   = "id"
}

resource "aws_api_gateway_resource" "idno-api-resource" {
  rest_api_id = "${aws_api_gateway_rest_api.onicaTestAPI.id}"
  parent_id   = "${aws_api_gateway_resource.id-api-resource.id}"
  path_part   = "{idno}"
}

resource "aws_api_gateway_method" "idGetMethod" {
  rest_api_id   = "${aws_api_gateway_rest_api.onicaTestAPI.id}"
  resource_id   = "${aws_api_gateway_resource.id-api-resource.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "idnoGetMethod" {
  rest_api_id   = "${aws_api_gateway_rest_api.onicaTestAPI.id}"
  resource_id   = "${aws_api_gateway_resource.idno-api-resource.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_lambda_permission" "apigw_lambda_id" {
  statement_id  = "AllowExecutionFromAPIGatewayId"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.getIdsFromOnicatest.function_name}"
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${var.AWS_REGION}:${var.AWS_ACCOUNT}:${aws_api_gateway_rest_api.onicaTestAPI.id}/*/${aws_api_gateway_method.idGetMethod.http_method}${aws_api_gateway_resource.id-api-resource.path}"
}

resource "aws_lambda_permission" "apigw_lambda_idItems" {
  statement_id  = "AllowExecutionFromAPIGatewayIdItems"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.getIdItemsFromOnicatest.function_name}"
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${var.AWS_REGION}:${var.AWS_ACCOUNT}:${aws_api_gateway_rest_api.onicaTestAPI.id}/*/${aws_api_gateway_method.idnoGetMethod.http_method}${aws_api_gateway_resource.idno-api-resource.path}"
}

resource "aws_api_gateway_integration" "id-lambda-api-integration" {
  rest_api_id = "${aws_api_gateway_rest_api.onicaTestAPI.id}"
  resource_id = "${aws_api_gateway_resource.id-api-resource.id}"
  http_method = "${aws_api_gateway_method.idGetMethod.http_method}"
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "${aws_lambda_function.getIdsFromOnicatest.invoke_arn}"
  #uri                     = "arn:aws:apigateway:${var.AWS_REGION}:lambda:path/2015-03-31/functions/${aws_lambda_function.getIdsFromOnicatest.arn}/invocations"
  credentials             = "${aws_iam_role.LambdaDynamoAPICloudWatch.arn}"

  
}

resource "aws_api_gateway_method_response" "id-lambda-api-method-response" {
  rest_api_id = "${aws_api_gateway_rest_api.onicaTestAPI.id}"
  resource_id = "${aws_api_gateway_resource.id-api-resource.id}"
  http_method = "${aws_api_gateway_method.idGetMethod.http_method}"
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "id-lambda-api-integration-response" {
  rest_api_id = "${aws_api_gateway_rest_api.onicaTestAPI.id}"
  resource_id = "${aws_api_gateway_resource.id-api-resource.id}"
  http_method = "${aws_api_gateway_method.idGetMethod.http_method}"

  status_code = "${aws_api_gateway_method_response.id-lambda-api-method-response.status_code}"

  # Configure the Velocity response template for the application/json MIME type
  response_templates = {
    "application/json" = <<EOF
    EOF
  }
  depends_on = [
      "aws_api_gateway_integration.id-lambda-api-integration"
  ]
}

resource "aws_api_gateway_integration" "idno-lambda-api-integration" {
  rest_api_id = "${aws_api_gateway_rest_api.onicaTestAPI.id}"
  resource_id = "${aws_api_gateway_resource.idno-api-resource.id}"
  http_method = "${aws_api_gateway_method.idnoGetMethod.http_method}"
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "${aws_lambda_function.getIdItemsFromOnicatest.invoke_arn}"
  #uri                     = "arn:aws:apigateway:${var.AWS_REGION}:lambda:path/2015-03-31/functions/${aws_lambda_function.getIdItemsFromOnicatest.arn}/invocations"
  credentials             = "${aws_iam_role.LambdaDynamoAPICloudWatch.arn}"

  request_templates = {
      "application/json" = <<EOF
{
    "idno":  "$input.params('idno')" 
}
EOF
  }
}


resource "aws_api_gateway_method_response" "idno-lambda-api-method-response" {
  rest_api_id = "${aws_api_gateway_rest_api.onicaTestAPI.id}"
  resource_id = "${aws_api_gateway_resource.idno-api-resource.id}"
  http_method = "${aws_api_gateway_method.idnoGetMethod.http_method}"
  status_code = "200"

}

resource "aws_api_gateway_integration_response" "idno-lambda-api-integration-response" {
  rest_api_id = "${aws_api_gateway_rest_api.onicaTestAPI.id}"
  resource_id = "${aws_api_gateway_resource.idno-api-resource.id}"
  http_method = "${aws_api_gateway_method.idnoGetMethod.http_method}"

  status_code = "${aws_api_gateway_method_response.idno-lambda-api-method-response.status_code}"

  # Configure the Velocity response template for the application/json MIME type
  response_templates = {
    "application/json" = <<EOF
    EOF
  }
  depends_on = [
      "aws_api_gateway_integration.idno-lambda-api-integration"
  ]
}

#deploying API
resource "aws_api_gateway_deployment" "dev" {
  depends_on = ["aws_api_gateway_integration.id-lambda-api-integration","aws_api_gateway_integration.idno-lambda-api-integration"]

  rest_api_id = "${aws_api_gateway_rest_api.onicaTestAPI.id}"
  stage_name  = "dev"

}

resource "aws_api_gateway_deployment" "prod" {
  depends_on = ["aws_api_gateway_integration.id-lambda-api-integration","aws_api_gateway_integration.idno-lambda-api-integration"]

  rest_api_id = "${aws_api_gateway_rest_api.onicaTestAPI.id}"
  stage_name  = "prod"

}

#OUTPUT of basr url of the stages
output "dev_base_url" {
  value = "${aws_api_gateway_deployment.dev.invoke_url}"
}

output "prod_base_url" {
  value = "${aws_api_gateway_deployment.prod.invoke_url}"
}