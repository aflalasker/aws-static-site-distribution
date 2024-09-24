variable "bucket_name" {
  description = "The name of the S3 bucket where the site contents will be published to."
  type        = string
  default     = null
}

# Cloudfront variables
# Default cache behavior variables
variable "default_cache_behavior_cache_policy_id" {
  description = "The ID of the cache policy to associate with the default cache behavior."
  type        = string
  default     = "658327ea-f89d-4fab-a63d-7e88639e58f6"
}

variable "default_cache_behavior_allowed_methods" {
  description = "The allowed methods for the default cache behavior."
  type        = list(string)
  default     = ["GET", "HEAD", "OPTIONS"]
}

variable "default_cache_behavior_cached_methods" {
  description = "The cached methods for the default cache behavior."
  type        = list(string)
  default     = ["GET", "HEAD"]
}

variable "default_cache_behavior_viewer_protocol_policy" {
  description = "The viewer protocol policy for the default cache behavior."
  type        = string
  default     = "redirect-to-https"
}

# Ordered cache behavior variables
variable "ordered_cache_behavior" {
  type = map(object({
    path_pattern           = string
    cache_policy_id        = optional(string, "658327ea-f89d-4fab-a63d-7e88639e58f6")
    allowed_methods        = optional(list(string), ["GET", "HEAD"])
    cached_methods         = optional(list(string), ["GET", "HEAD"])
    viewer_protocol_policy = optional(string, "redirect-to-https")
    compress               = optional(bool, true)
  }))
  description = "values for ordered cache behavior"
}

variable "default_root_object" {
  description = "The default root object for the Cloudfront distribution."
  type        = string
  default     = "index.html"
}

variable "comment" {
  description = "The comment for the Cloudfront distribution."
  type        = string
  default     = "Distributes the site content."
}

# Route53 variables
variable "route53_domain_name" {
  description = "The domain name to register with Route53."
  type        = string
  default     = null
}

variable "auto_renew" {
  description = "Whether to automatically renew the domain registration."
  type        = bool
  default     = true
}

variable "transfer_lock" {
  description = "Whether to lock the domain registration to prevent transfer."
  type        = bool
  default     = false
}

# ACM variables
variable "subject_alternative_names" {
  description = "A list of additional domain names to include in the certificate."
  type        = list(string)
  default     = []
}

# Lambda variables
variable "lambda_log_retention" {
  description = "The number of days to retain the logs for the Lambda function."
  type        = number
  default     = 1
}

# Common variables
variable "tags" {
  description = "A map of tags to apply to the resources."
  type        = map(string)
  default     = {}
}
