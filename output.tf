output "name_servers" {
  value = aws_route53_zone.domain_name.name_servers
}
