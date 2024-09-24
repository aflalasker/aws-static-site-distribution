data "archive_file" "zip" {
  type        = "zip"
  source_file = "${path.module}/index.mjs"
  output_path = "${path.module}/index.zip"
}

resource "random_string" "random_suffix" {
  length  = 8
  special = false
  lower   = true
  upper   = false
  numeric = false
}

resource "aws_s3_bucket" "code" {
  bucket        = local.lambda_function_name
  force_destroy = true
  tags          = local.tags
}

resource "aws_s3_object" "code_package" {
  bucket      = aws_s3_bucket.code.id
  key         = "index.zip"
  source      = data.archive_file.zip.output_path
  source_hash = filebase64sha256(data.archive_file.zip.output_path)
  tags        = local.tags
}

resource "aws_lambda_function" "edge_lambda" {
  function_name    = local.lambda_function_name
  s3_bucket        = aws_s3_bucket.code.id
  s3_key           = aws_s3_object.code_package.key
  source_code_hash = aws_s3_object.code_package.source_hash
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  timeout          = 5
  memory_size      = 128
  package_type     = "Zip"
  publish          = true
  description      = "A Lambda@Edge function that modifies the origin request."
  tags             = local.tags
  logging_config {
    log_format       = "JSON"
    system_log_level = "WARN"
    log_group        = aws_cloudwatch_log_group.log_group.name
  }

  lifecycle {
    # Ignored changes to these as they are managed internally by the provider and are causing unnecessary drifts in the plan
    ignore_changes = [qualified_arn, qualified_invoke_arn, version]
  }
}

resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/aws/lambda/${local.lambda_function_name}"
  retention_in_days = var.lambda_log_retention
  tags              = local.tags
  lifecycle {
    prevent_destroy = false
  }
}

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    sid     = "LambdaServiceAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com",
        "edgelambda.amazonaws.com",
        "replicator.lambda.amazonaws.com",
      ]
    }
  }
}

data "aws_iam_policy_document" "lambda_exec_role_policy" {
  statement {
    sid = "AllowLambdaToWriteLogs"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "${aws_cloudwatch_log_group.log_group.arn}:*",
      "arn:aws:logs:*:*:log-group:/aws/cloudfront/*"
    ]
  }

  statement {
    sid    = "LambdaCreateDeletePermission"
    effect = "Allow"
    actions = [
      "lambda:CreateFunction",
      "lambda:DeleteFunction",
      "lambda:DisableReplication"
    ]
    resources = [
      "arn:aws:lambda:*:*:function:*"
    ]
  }

  statement {
    sid    = "IamPassRolePermission"
    effect = "Allow"
    actions = [
      "iam:PassRole"
    ]
    resources = ["*"]
    condition {
      test     = "StringEqualsIfExists"
      variable = "iam:PassedToService"
      values   = ["lambda.amazonaws.com"]
    }
  }

  statement {
    sid    = "CloudFrontListDistributions"
    effect = "Allow"
    actions = [
      "cloudfront:ListDistributionsByLambdaFunction"
    ]
    resources = ["*"]
  }
}


resource "aws_iam_role" "lambda_role" {
  name               = "${local.lambda_function_name}-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
  tags               = local.tags
}

resource "aws_iam_policy" "policy" {
  name   = "${local.lambda_function_name}-policy"
  policy = data.aws_iam_policy_document.lambda_exec_role_policy.json
  tags   = local.tags
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.policy.arn
}
