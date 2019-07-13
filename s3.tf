resource "aws_s3_bucket" "content" {
  bucket = "${var.resource_prefix}-content"
  acl    = "private"

  website {
    index_document = "index.html"
  }

  logging {
    target_bucket = "${aws_s3_bucket.content_log.id}"
    target_prefix = "access_log/s3/"
  }
}

resource "aws_s3_bucket" "redirect_www" {
  bucket = "${var.resource_prefix}-www"

  website {
    redirect_all_requests_to = "${var.domain_name}"
  }
}


resource "aws_s3_bucket" "content_log" {
  bucket = "${var.resource_prefix}-log"
  acl    = "log-delivery-write"

  lifecycle_rule {
    id      = "access_log"
    enabled = true
    prefix  = "access_log/"

    transition {
      days          = 35
      storage_class = "ONEZONE_IA"
    }

    expiration {
      days = 100
    }
  }
}

data "template_file" "s3_content_bucket_policy" {
  template = "${file("./templates/s3_content_bucket_policy.json")}"

  vars = {
    s3_arn  = "${aws_s3_bucket.content.arn}"
    iam_arn = "${aws_cloudfront_origin_access_identity.s3.iam_arn}"
  }
}

resource "aws_s3_bucket_policy" "content" {
  bucket = "${aws_s3_bucket.content.id}"
  policy = "${data.template_file.s3_content_bucket_policy.rendered}"
}
