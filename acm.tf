resource "aws_acm_certificate" "domain_name" {
  domain_name               = "${var.domain_name}"
  subject_alternative_names = ["www.${var.domain_name}"]
  validation_method         = "DNS"
  provider                  = "aws.global_certificate"
}
