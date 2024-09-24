resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = aws_s3_bucket.site.bucket
  description                       = "The OAC for cloudfront to access the s3 bucket."
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "distribution" {
  origin {
    domain_name              = aws_s3_bucket.site.bucket_domain_name
    origin_id                = aws_s3_bucket.site.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
    connection_attempts      = 3
    connection_timeout       = 10
  }

  aliases = local.aliases

  enabled             = true
  is_ipv6_enabled     = true
  comment             = var.comment
  default_root_object = var.default_root_object
  tags                = local.tags

  default_cache_behavior {
    cache_policy_id        = var.default_cache_behavior_cache_policy_id
    allowed_methods        = var.default_cache_behavior_allowed_methods
    cached_methods         = var.default_cache_behavior_cached_methods
    target_origin_id       = aws_s3_bucket.site.bucket_regional_domain_name
    viewer_protocol_policy = var.default_cache_behavior_viewer_protocol_policy
    compress               = true
    lambda_function_association {
      event_type   = "origin-request"
      lambda_arn   = local.full_lambda_arn
      include_body = false
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.ordered_cache_behavior
    content {
      path_pattern           = ordered_cache_behavior.value.path_pattern
      cache_policy_id        = ordered_cache_behavior.value.cache_policy_id
      allowed_methods        = ordered_cache_behavior.value.allowed_methods
      cached_methods         = ordered_cache_behavior.value.cached_methods
      target_origin_id       = aws_s3_bucket.site.bucket_regional_domain_name
      viewer_protocol_policy = ordered_cache_behavior.value.viewer_protocol_policy
      compress               = ordered_cache_behavior.value.compress
      lambda_function_association {
        event_type   = "origin-request"
        lambda_arn   = local.full_lambda_arn
        include_body = false
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  price_class = "PriceClass_All"

  dynamic "viewer_certificate" {
    for_each = local.should_create_route53 ? [1] : []
    content {
      acm_certificate_arn            = local.acm_certificate_arn
      cloudfront_default_certificate = false
      minimum_protocol_version       = "TLSv1.2_2021"
      ssl_support_method             = "sni-only"
    }
  }

  dynamic "viewer_certificate" {
    for_each = local.should_create_cloudfront_default_certificate ? [1] : []
    content {
      cloudfront_default_certificate = true
    }
  }

  lifecycle {
    ignore_changes = [
      origin
    ]
  }
}
