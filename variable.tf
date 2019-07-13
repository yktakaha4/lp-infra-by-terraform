variable "resource_prefix" {}
variable "domain_name" {}
variable "s3_state_bucket_name" {}

variable "region" { default = "ap-northeast-1" }
variable "cloudfront_geo_restriction_locations" { default = "JP,US" }
variable "route53_record_ttl" { default = "86400" }
