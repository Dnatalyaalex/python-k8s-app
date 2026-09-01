output "name_servers" {
    value = aws_route53_zone.names_app_dns.name_servers
}

output "dns_zone_id" {
    value = aws_route53_zone.names_app_dns.zone_id
}