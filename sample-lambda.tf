data "archive_file" "sample_lambda_function" {
  type        = "zip"
  source_dir  = "./sample/lambda"
  output_path = "./tmp/sample_lambda_function.zip"
}

resource "aws_cloudwatch_log_group" "sample_lambda_function" {
  name              = "/aws/lambda/${var.resource_prefix}-sample_lambda_function"
  retention_in_days = 30
}

resource "aws_lambda_function" "sample_lambda_function" {
  depends_on = [
    aws_iam_role_policy_attachment.sample_lambda_function,
    aws_cloudwatch_log_group.sample_lambda_function,
  ]

  filename         = "${data.archive_file.sample_lambda_function.output_path}"
  function_name    = "${var.resource_prefix}-sample_lambda_function"
  role             = "${aws_iam_role.sample_lambda_function.arn}"
  handler          = "post_contact.lambda_handler"
  source_code_hash = "${data.archive_file.sample_lambda_function.output_base64sha256}"
  runtime          = "python3.7"

  memory_size = 128
  timeout     = 30

  environment {
    variables = {
      log_level         = "INFO"
      secrets_slack_api = "${aws_secretsmanager_secret.slack_api.name}"
      dlq_url           = "${aws_sqs_queue.sample_lambda_function_dlq.id}"
    }
  }
}

resource "aws_lambda_permission" "sample_lambda_function" {
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.sample_lambda_function.function_name}"
  principal     = "apigateway.amazonaws.com"
}
