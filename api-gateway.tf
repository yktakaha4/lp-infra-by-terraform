resource "aws_api_gateway_rest_api" "api" {
  name = "${var.resource_prefix}"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "api" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  parent_id   = "${aws_api_gateway_rest_api.api.root_resource_id}"
  path_part   = "api"
}

resource "aws_api_gateway_deployment" "prod" {
  depends_on = [aws_api_gateway_integration.contact]

  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  stage_name  = "prod"
}
