resource "aws_sqs_queue" "sample_lambda_function_dlq" {
  name                      = "${var.resource_prefix}-sample_lambda_function_dlq"
  max_message_size          = 262144
  message_retention_seconds = 1209600
}
