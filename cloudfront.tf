resource "aws_cloudfront_origin_access_identity" "s3" {
  comment = "${var.resource_prefix}-s3"
}

resource "aws_cloudfront_origin_access_identity" "api" {
  comment = "${var.resource_prefix}-api"
}

resource "aws_cloudfront_distribution" "domain_name" {
  depends_on = [aws_acm_certificate_validation.domain_name]

  enabled             = true
  comment             = "${var.domain_name}"
  default_root_object = "index.html"
  price_class         = "PriceClass_200"
  aliases             = ["${var.domain_name}"]

  origin {
    domain_name = "${aws_api_gateway_deployment.prod.rest_api_id}.execute-api.${var.region}.amazonaws.com"
    origin_id   = "${aws_cloudfront_origin_access_identity.api.id}"
    origin_path = "/${aws_api_gateway_deployment.prod.stage_name}"

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_protocol_policy   = "https-only"
      origin_ssl_protocols     = ["TLSv1.2"]
      origin_keepalive_timeout = 60
      origin_read_timeout      = 60
    }
  }

  origin {
    domain_name = "${aws_s3_bucket.content.bucket_regional_domain_name}"
    origin_id   = "${aws_cloudfront_origin_access_identity.s3.id}"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.s3.cloudfront_access_identity_path}"
    }
  }

  logging_config {
    include_cookies = false
    bucket          = "${aws_s3_bucket.content_log.bucket_domain_name}"
    prefix          = "access_log/cloudfront/"
  }

  custom_error_response {
    error_code            = "403"
    response_code         = "200"
    response_page_path    = "/"
    error_caching_min_ttl = "300"
  }

  ordered_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "POST", "PUT", "PATCH", "DELETE"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${aws_cloudfront_origin_access_identity.api.id}"
    path_pattern     = "/api/*"

    forwarded_values {
      query_string            = true
      headers                 = ["Authorization", "Origin"]
      query_string_cache_keys = ["Authorization"]

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 1
    default_ttl            = 1
    max_ttl                = 1
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "${aws_cloudfront_origin_access_identity.s3.id}"
    compress         = true

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 1
    default_ttl            = 86400
    max_ttl                = 604800
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = split(",", "${var.cloudfront_geo_restriction_locations}")
    }
  }

  viewer_certificate {
    acm_certificate_arn      = "${aws_acm_certificate.domain_name.arn}"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }
}
