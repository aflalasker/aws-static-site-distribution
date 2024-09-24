output "site_bucket_config" {
  value       = aws_s3_bucket.site
  description = "The site bucket configuration"
}

output "cloudfront_distribution_config" {
  value       = aws_cloudfront_distribution.distribution
  description = "The Cloudfront distribution configuration"
}
