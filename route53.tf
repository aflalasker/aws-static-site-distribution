resource "aws_route53domains_registered_domain" "main" {
  count         = local.should_create_route53 ? 1 : 0
  domain_name   = var.route53_domain_name
  transfer_lock = var.transfer_lock
  auto_renew    = var.auto_renew
  tags          = local.tags
}

resource "aws_route53_zone" "primary" {
  count = local.should_create_route53 ? 1 : 0
  name  = local.zone_name
  tags  = local.tags
}

resource "aws_acm_certificate" "cert" {
  count             = local.should_create_route53 ? 1 : 0
  domain_name       = local.zone_name
  validation_method = "DNS"

  subject_alternative_names = var.subject_alternative_names

  lifecycle {
    create_before_destroy = true
  }
  tags = local.tags
}

resource "aws_route53_record" "records" {
  for_each = local.should_create_route53 ? {
    for dvo in aws_acm_certificate.cert[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = local.route53_zone_id
}

resource "aws_acm_certificate_validation" "cert_validation" {
  count                   = local.should_create_route53 ? 1 : 0
  certificate_arn         = local.acm_certificate_arn
  validation_record_fqdns = [for record in aws_route53_record.records : record.fqdn]
}

resource "aws_route53_record" "www" {
  count   = local.should_create_route53 ? 1 : 0
  zone_id = local.route53_zone_id
  name    = local.www_record
  type    = "A"

  alias {
    name                   = local.registerd_domain_name
    zone_id                = local.route53_zone_id
    evaluate_target_health = true
  }
}
