#OUTPUT of basr url of the stages
output "dev_base_url" {
  value = "${aws_api_gateway_deployment.dev.invoke_url}"
}

output "prod_base_url" {
  value = "${aws_api_gateway_deployment.prod.invoke_url}"
}

output "onica_rest_api_id" {
  value = "${aws_api_gateway_rest_api.onicaTestAPI.id}"
}