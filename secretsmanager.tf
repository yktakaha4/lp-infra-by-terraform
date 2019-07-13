resource "aws_secretsmanager_secret" "slack_api" {
  name                    = "${var.resource_prefix}-slack_api"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "slack_api" {
  secret_id     = "${aws_secretsmanager_secret.slack_api.id}"
  secret_string = "${file("./templates/secretsmanager_slack_api.json")}"

  lifecycle {
    ignore_changes = ["secret_string"]
  }
}
