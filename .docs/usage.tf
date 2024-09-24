# This is a very basic example of how to use the module. 
module "my_static_site" {
  source      = "git@github.com:aflalasker/aws-static-site-distribution.git?ref=v1.0.0"
  bucket_name = "my-site-bucket"
  ordered_cache_behavior = {
    "/index.html" = {
      path_pattern = "/*"
      compress     = true
    }
  }
}
