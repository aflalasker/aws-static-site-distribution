resource "aws_s3_bucket" "site" {
  bucket        = local.site_bucket_name
  force_destroy = true
  tags          = local.tags
}

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    sid    = "AllowCloudFrontToGetObjects"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.site.arn}/*"]

    condition {
      test     = "StringEquals"
      values   = [aws_cloudfront_distribution.distribution.arn]
      variable = "AWS:SourceArn"
    }
  }
  version = "2012-10-17"
}

resource "aws_s3_bucket_policy" "policy_attachment" {
  bucket = aws_s3_bucket.site.bucket
  policy = data.aws_iam_policy_document.bucket_policy.json
}
