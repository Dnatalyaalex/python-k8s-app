resource "aws_acm_certificate" "names_app_cert" {
    domain_name       = "names-app.click"
    validation_method = "DNS"

    lifecycle {
        create_before_destroy = true
    }
}


resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.names_app_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }
  zone_id =  data.terraform_remote_state.dns.outputs.dns_zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "names_app" {
    certificate_arn    = aws_acm_certificate.names_app_cert.arn
    validation_record_fqdns = [for r in aws_route53_record.cert_validation : r.fqdn]
}