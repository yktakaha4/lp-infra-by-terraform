resource "aws_route53_zone" "domain_name" {
  name = "${var.domain_name}"
}

resource "aws_route53_record" "domain_name" {
  zone_id = "${aws_route53_zone.domain_name.zone_id}"
  name    = "${var.domain_name}"
  type    = "A"

  alias {
    zone_id                = "${aws_cloudfront_distribution.domain_name.hosted_zone_id}"
    name                   = "${aws_cloudfront_distribution.domain_name.domain_name}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www" {
  zone_id = "${aws_route53_zone.domain_name.zone_id}"
  name    = "www"
  type    = "A"

  alias {
    zone_id                = "${aws_s3_bucket.redirect_www.hosted_zone_id}"
    name                   = "${aws_s3_bucket.redirect_www.website_endpoint}"
    evaluate_target_health = false
  }
}
