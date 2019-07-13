resource "aws_iam_role" "sample_lambda_function" {
  name               = "${var.resource_prefix}-sample_lambda_function"
  assume_role_policy = "${file("./sample/templates/iam_role_sample_lambda_function.json")}"
}

resource "aws_iam_policy" "sample_lambda_function" {
  name   = "${var.resource_prefix}-sample_lambda_function"
  policy = "${file("./sample/templates/iam_policy_sample_lambda_function.json")}"
}

resource "aws_iam_role_policy_attachment" "sample_lambda_function" {
  role       = "${aws_iam_role.sample_lambda_function.name}"
  policy_arn = "${aws_iam_policy.sample_lambda_function.arn}"
}
