
<!-- BEGIN_TF_DOCS -->
# Static site distribution with AWS

This repository contains the terraform configuration required to start distributing a static site in AWS. The module will provision,

1. S3 bucket - for static site and the Lambda@Edge code package.
2. Cloudfront distribution for serving the static site
3. Lambda function running Lambda@Edge to correctly render index pages from sub folders.
4. Route53 domain and records - Optional.
5. ACM certificate for the Route53 domain - Optional.

# Usage
```hcl
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
```

# Module documentation
Below is the documentation for the module generated using Terraform-docs.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~>1.9.5 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | ~>2.6.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~>5.66.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~>3.6.3 |
## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | ~>2.6.0 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~>5.66.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~>3.6.3 |
## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.cert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate_validation.cert_validation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |
| [aws_cloudfront_distribution.distribution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_origin_access_control.oac](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_control) | resource |
| [aws_cloudwatch_log_group.log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_policy.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.lambda_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.lambda_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function.edge_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_route53_record.records](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.www](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_zone.primary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_route53domains_registered_domain.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53domains_registered_domain) | resource |
| [aws_s3_bucket.code](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.site](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_policy.policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_object.code_package](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [random_string.random_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [archive_file.zip](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_iam_policy_document.bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.lambda_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.lambda_exec_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_auto_renew"></a> [auto\_renew](#input\_auto\_renew) | Whether to automatically renew the domain registration. | `bool` | `true` | no |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | The name of the S3 bucket where the site contents will be published to. | `string` | `null` | no |
| <a name="input_comment"></a> [comment](#input\_comment) | The comment for the Cloudfront distribution. | `string` | `"Distributes the site content."` | no |
| <a name="input_default_cache_behavior_allowed_methods"></a> [default\_cache\_behavior\_allowed\_methods](#input\_default\_cache\_behavior\_allowed\_methods) | The allowed methods for the default cache behavior. | `list(string)` | <pre>[<br/>  "GET",<br/>  "HEAD",<br/>  "OPTIONS"<br/>]</pre> | no |
| <a name="input_default_cache_behavior_cache_policy_id"></a> [default\_cache\_behavior\_cache\_policy\_id](#input\_default\_cache\_behavior\_cache\_policy\_id) | The ID of the cache policy to associate with the default cache behavior. | `string` | `"658327ea-f89d-4fab-a63d-7e88639e58f6"` | no |
| <a name="input_default_cache_behavior_cached_methods"></a> [default\_cache\_behavior\_cached\_methods](#input\_default\_cache\_behavior\_cached\_methods) | The cached methods for the default cache behavior. | `list(string)` | <pre>[<br/>  "GET",<br/>  "HEAD"<br/>]</pre> | no |
| <a name="input_default_cache_behavior_viewer_protocol_policy"></a> [default\_cache\_behavior\_viewer\_protocol\_policy](#input\_default\_cache\_behavior\_viewer\_protocol\_policy) | The viewer protocol policy for the default cache behavior. | `string` | `"redirect-to-https"` | no |
| <a name="input_default_root_object"></a> [default\_root\_object](#input\_default\_root\_object) | The default root object for the Cloudfront distribution. | `string` | `"index.html"` | no |
| <a name="input_lambda_log_retention"></a> [lambda\_log\_retention](#input\_lambda\_log\_retention) | The number of days to retain the logs for the Lambda function. | `number` | `1` | no |
| <a name="input_ordered_cache_behavior"></a> [ordered\_cache\_behavior](#input\_ordered\_cache\_behavior) | values for ordered cache behavior | <pre>map(object({<br/>    path_pattern           = string<br/>    cache_policy_id        = optional(string, "658327ea-f89d-4fab-a63d-7e88639e58f6")<br/>    allowed_methods        = optional(list(string), ["GET", "HEAD"])<br/>    cached_methods         = optional(list(string), ["GET", "HEAD"])<br/>    viewer_protocol_policy = optional(string, "redirect-to-https")<br/>    compress               = optional(bool, true)<br/>  }))</pre> | n/a | yes |
| <a name="input_route53_domain_name"></a> [route53\_domain\_name](#input\_route53\_domain\_name) | The domain name to register with Route53. | `string` | `null` | no |
| <a name="input_subject_alternative_names"></a> [subject\_alternative\_names](#input\_subject\_alternative\_names) | A list of additional domain names to include in the certificate. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to apply to the resources. | `map(string)` | `{}` | no |
| <a name="input_transfer_lock"></a> [transfer\_lock](#input\_transfer\_lock) | Whether to lock the domain registration to prevent transfer. | `bool` | `false` | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudfront_distribution_config"></a> [cloudfront\_distribution\_config](#output\_cloudfront\_distribution\_config) | The Cloudfront distribution configuration |
| <a name="output_site_bucket_config"></a> [site\_bucket\_config](#output\_site\_bucket\_config) | The site bucket configuration |
### Contributions

If you find any issues or have suggestions for improvements, please open an issue or submit a pull request on our [GitHub repository](https://github.com/aflalasker/aws-static-site-distribution).

### License

This project is licensed under the Apache 2.0 License. See the [LICENSE](../LICENSE) file for more details.
<!-- END_TF_DOCS -->

