locals {
  should_create_route53                        = var.route53_domain_name != null ? true : false
  random_string                                = random_string.random_suffix.result
  route53_zone_id                              = local.should_create_route53 ? aws_route53_zone.primary[0].zone_id : null
  registerd_domain_name                        = local.should_create_route53 ? aws_route53domains_registered_domain.main[0].domain_name : null
  www_record                                   = local.should_create_route53 ? "www.${local.registerd_domain_name}" : null
  zone_name                                    = local.registerd_domain_name != null ? local.registerd_domain_name : null
  aliases                                      = var.route53_domain_name != null ? [var.route53_domain_name, local.www_record] : []
  acm_certificate_arn                          = local.should_create_route53 ? aws_acm_certificate.cert[0].arn : null
  should_create_cloudfront_default_certificate = local.acm_certificate_arn == null ? true : false
  full_lambda_arn                              = "${aws_lambda_function.edge_lambda.arn}:${aws_lambda_function.edge_lambda.version}"
  site_bucket_name                             = var.bucket_name != null ? var.bucket_name : "static-site-${local.random_string}"
  lambda_function_name                         = "distribution-origin-request-edge-lambda-${local.random_string}"
  tags                                         = merge(var.tags, tomap({ "ModuleReporisoty" : "https://github.com/aflalasker/aws-static-site-hosting" }), tomap({ "Terraform" : "true" }))
}
