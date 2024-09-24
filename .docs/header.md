# Static site distribution with AWS

This repository contains the terraform configuration required to start distributing a static site in AWS. The module will provision,

1. S3 bucket - for static site and the Lambda@Edge code package.
2. Cloudfront distribution for serving the static site
3. Lambda function running Lambda@Edge to correctly render index pages from sub folders.
4. Route53 domain and records - Optional.
5. ACM certificate for the Route53 domain - Optional.
