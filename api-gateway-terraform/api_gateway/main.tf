provider "aws" {
  region = "${var.AWS_REGION}"
  version = "~> 2.4"
}

// -------- Data Remote State LAMBDA --------- //
data "terraform_remote_state" "onica_lambda" {
  backend = "s3"

  config = {
    bucket   = "${var.bucket_remote_state}"
    key      = "env:/${var.workspace}/lambda/terraform.tfstate"
    region   = "${var.bucket_region}"
    role_arn = "${var.tf_mgmt_role_arn}"
  }
}

// -------- Data Remote State IAM ROLE --------- //
data "terraform_remote_state" "onica_iam_role" {
  backend = "s3"

  config = {
    bucket   = "${var.bucket_remote_state}"
    key      = "env:/${var.workspace}/iam_roles/terraform.tfstate"
    region   = "${var.bucket_region}"
    role_arn = "${var.tf_mgmt_role_arn}"
  }
}

#API Gateway Configuration
resource "aws_api_gateway_rest_api" "onicaTestAPI" {
  name        = "onicaTestAPI"
  description = "RESTAPI for dynamodb table onicatest"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

#Creating resource "id"
resource "aws_api_gateway_resource" "id-api-resource" {
  rest_api_id = "${aws_api_gateway_rest_api.onicaTestAPI.id}"
  parent_id   = "${aws_api_gateway_rest_api.onicaTestAPI.root_resource_id}"
  path_part   = "id"
}

#creating resource "{idno}"
resource "aws_api_gateway_resource" "idno-api-resource" {
  rest_api_id = "${aws_api_gateway_rest_api.onicaTestAPI.id}"
  parent_id   = "${aws_api_gateway_resource.id-api-resource.id}"
  path_part   = "{idno}"
}

#creating resource "postit"
resource "aws_api_gateway_resource" "postit-api-resource" {
  rest_api_id = "${aws_api_gateway_rest_api.onicaTestAPI.id}"
  parent_id   = "${aws_api_gateway_rest_api.onicaTestAPI.root_resource_id}"
  path_part   = "postit"
}

#creating method GET for resource "id"
resource "aws_api_gateway_method" "idGetMethod" {
  rest_api_id   = "${aws_api_gateway_rest_api.onicaTestAPI.id}"
  resource_id   = "${aws_api_gateway_resource.id-api-resource.id}"
  http_method   = "GET"
  authorization = "NONE"
}

#creating method GET for resource "{idno}"
resource "aws_api_gateway_method" "idnoGetMethod" {
  rest_api_id   = "${aws_api_gateway_rest_api.onicaTestAPI.id}"
  resource_id   = "${aws_api_gateway_resource.idno-api-resource.id}"
  http_method   = "GET"
  authorization = "NONE"
}

#creating method POST for resource "postit"
resource "aws_api_gateway_method" "postitPostMethod" {
  rest_api_id   = "${aws_api_gateway_rest_api.onicaTestAPI.id}"
  resource_id   = "${aws_api_gateway_resource.postit-api-resource.id}"
  http_method   = "POST"
  authorization = "NONE"
}

#creating api gateway permissions for lambda_fuction "getIdsFromOnicatest"
resource "aws_lambda_permission" "apigw_lambda_id" {
  statement_id  = "AllowExecutionFromAPIGatewayId"
  action        = "lambda:InvokeFunction"
  function_name = "${data.terraform_remote_state.onica_lambda.outputs.getIdsFromOnicatest_function_name}"
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${var.AWS_REGION}:${var.AWS_ACCOUNT}:${aws_api_gateway_rest_api.onicaTestAPI.id}/*/${aws_api_gateway_method.idGetMethod.http_method}${aws_api_gateway_resource.id-api-resource.path}"
}

#creating api gateway permissions for lambda_fuction "getIdsItemFromOnicatest"
resource "aws_lambda_permission" "apigw_lambda_idItems" {
  statement_id  = "AllowExecutionFromAPIGatewayIdItems"
  action        = "lambda:InvokeFunction"
  function_name = "${data.terraform_remote_state.onica_lambda.outputs.getIdItemsFromOnicatest_function_name}"
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${var.AWS_REGION}:${var.AWS_ACCOUNT}:${aws_api_gateway_rest_api.onicaTestAPI.id}/*/${aws_api_gateway_method.idnoGetMethod.http_method}${aws_api_gateway_resource.idno-api-resource.path}"
}

resource "aws_lambda_permission" "apigw_lambda_postit" {
  statement_id  = "AllowExecutionFromAPIGatewayPostit"
  action        = "lambda:InvokeFunction"
  function_name = "${data.terraform_remote_state.onica_lambda.outputs.postItemsToOnicatest_function_name}"
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${var.AWS_REGION}:${var.AWS_ACCOUNT}:${aws_api_gateway_rest_api.onicaTestAPI.id}/*/${aws_api_gateway_method.postitPostMethod.http_method}${aws_api_gateway_resource.postit-api-resource.path}"
}

#creating api gateway integration for resource "id" GET method 
resource "aws_api_gateway_integration" "id-lambda-api-integration" {
  rest_api_id = "${aws_api_gateway_rest_api.onicaTestAPI.id}"
  resource_id = "${aws_api_gateway_resource.id-api-resource.id}"
  http_method = "${aws_api_gateway_method.idGetMethod.http_method}"
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "${data.terraform_remote_state.onica_lambda.outputs.getIdsFromOnicatest_invoke_arn}"
  credentials             = "${data.terraform_remote_state.onica_iam_role.outputs.arn}"
}

#creating method response for resource "id" GET method
resource "aws_api_gateway_method_response" "id-lambda-api-method-response" {
  rest_api_id = "${aws_api_gateway_rest_api.onicaTestAPI.id}"
  resource_id = "${aws_api_gateway_resource.id-api-resource.id}"
  http_method = "${aws_api_gateway_method.idGetMethod.http_method}"
  status_code = "200"
}

#creating integration response for resource "id" GET method
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

#creating api gateway integration for resource "{idno}" GET method 
resource "aws_api_gateway_integration" "idno-lambda-api-integration" {
  rest_api_id = "${aws_api_gateway_rest_api.onicaTestAPI.id}"
  resource_id = "${aws_api_gateway_resource.idno-api-resource.id}"
  http_method = "${aws_api_gateway_method.idnoGetMethod.http_method}"
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "${data.terraform_remote_state.onica_lambda.outputs.getIdItemsFromOnicatest_invoke_arn}"
  credentials             = "${data.terraform_remote_state.onica_iam_role.outputs.arn}"

  request_templates = {
      "application/json" = <<EOF
{
    "idno":  "$input.params('idno')" 
}
EOF
  }
}

#creating method response for resource "{idno}" GET method
resource "aws_api_gateway_method_response" "idno-lambda-api-method-response" {
  rest_api_id = "${aws_api_gateway_rest_api.onicaTestAPI.id}"
  resource_id = "${aws_api_gateway_resource.idno-api-resource.id}"
  http_method = "${aws_api_gateway_method.idnoGetMethod.http_method}"
  status_code = "200"

}

#creating integration response for resource "{idno}" GET method
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

#creating api gateway integration for resource "postit" GET method 
resource "aws_api_gateway_integration" "postit-lambda-api-integration" {
  rest_api_id = "${aws_api_gateway_rest_api.onicaTestAPI.id}"
  resource_id = "${aws_api_gateway_resource.postit-api-resource.id}"
  http_method = "${aws_api_gateway_method.postitPostMethod.http_method}"
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "${data.terraform_remote_state.onica_lambda.outputs.postItemsToOnicatest_invoke_arn}"
  credentials             = "${data.terraform_remote_state.onica_iam_role.outputs.arn}"
}

#creating method response for resource "postit" GET method
resource "aws_api_gateway_method_response" "postit-lambda-api-method-response" {
  rest_api_id = "${aws_api_gateway_rest_api.onicaTestAPI.id}"
  resource_id = "${aws_api_gateway_resource.postit-api-resource.id}"
  http_method = "${aws_api_gateway_method.postitPostMethod.http_method}"
  status_code = "200"

}

#creating integration response for resource "postit" GET method
resource "aws_api_gateway_integration_response" "postit-lambda-api-integration-response" {
  rest_api_id = "${aws_api_gateway_rest_api.onicaTestAPI.id}"
  resource_id = "${aws_api_gateway_resource.postit-api-resource.id}"
  http_method = "${aws_api_gateway_method.postitPostMethod.http_method}"

  status_code = "${aws_api_gateway_method_response.postit-lambda-api-method-response.status_code}"

  # Configure the Velocity response template for the application/json MIME type
  response_templates = {
    "application/json" = <<EOF
    EOF
  }
  depends_on = [
      "aws_api_gateway_integration.postit-lambda-api-integration"
  ]
}

#deploying API
resource "aws_api_gateway_deployment" "dev" {
  depends_on = ["aws_api_gateway_integration.id-lambda-api-integration","aws_api_gateway_integration.idno-lambda-api-integration"]

  rest_api_id = "${aws_api_gateway_rest_api.onicaTestAPI.id}"
  stage_name  = "dev"

}

resource "aws_api_gateway_deployment" "prod" {
  depends_on = ["aws_api_gateway_integration.id-lambda-api-integration","aws_api_gateway_integration.idno-lambda-api-integration","aws_api_gateway_deployment.dev"]

  rest_api_id = "${aws_api_gateway_rest_api.onicaTestAPI.id}"
  stage_name  = "prod"

}
