resource "aws_route53_record" "validation_domain_name" {
  zone_id = "${aws_route53_zone.domain_name.zone_id}"
  ttl     = "${var.route53_record_ttl}"

  name    = "${aws_acm_certificate.domain_name.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.domain_name.domain_validation_options.0.resource_record_type}"
  records = ["${aws_acm_certificate.domain_name.domain_validation_options.0.resource_record_value}"]
}

resource "aws_route53_record" "validation_www" {
  zone_id = "${aws_route53_zone.domain_name.zone_id}"
  ttl     = "${var.route53_record_ttl}"

  name    = "${aws_acm_certificate.domain_name.domain_validation_options.1.resource_record_name}"
  type    = "${aws_acm_certificate.domain_name.domain_validation_options.1.resource_record_type}"
  records = ["${aws_acm_certificate.domain_name.domain_validation_options.1.resource_record_value}"]
}

resource "aws_acm_certificate_validation" "domain_name" {
  certificate_arn = "${aws_acm_certificate.domain_name.arn}"
  validation_record_fqdns = [
    "${aws_route53_record.validation_domain_name.fqdn}",
    "${aws_route53_record.validation_www.fqdn}"
  ]

  provider = "aws.global_certificate"
}
