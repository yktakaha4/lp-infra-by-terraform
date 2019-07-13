resource "aws_s3_bucket_object" "index" {
  bucket       = "${aws_s3_bucket.content.id}"
  key          = "index.html"
  source       = "./sample/s3/index.html"
  content_type = "text/html"

  etag = "${filemd5("./sample/s3/index.html")}"
}

resource "aws_s3_bucket_object" "robots" {
  bucket       = "${aws_s3_bucket.content.id}"
  key          = "robots.txt"
  source       = "./sample/s3/robots.txt"
  content_type = "text/plain"

  etag = "${filemd5("./sample/s3/robots.txt")}"
}
