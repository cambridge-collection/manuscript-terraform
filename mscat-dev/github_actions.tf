locals {
  destination_bucket_prefix_normalized = trim(var.destination-bucket-prefix, "/")
  destination_bucket_prefix_condition_values = local.destination_bucket_prefix_normalized == "" ? [] : [
    "${local.destination_bucket_prefix_normalized}/*",
    local.destination_bucket_prefix_normalized
  ]
  destination_bucket_name_effective = module.cudl-data-processing.destination_bucket
  destination_bucket_prefix_object_arn = local.destination_bucket_prefix_normalized == "" ? format(
    "arn:aws:s3:::%s/*",
    local.destination_bucket_name_effective
    ) : format(
    "arn:aws:s3:::%s/%s/*",
    local.destination_bucket_name_effective,
    local.destination_bucket_prefix_normalized
  )

  github_oidc_issuer_url = "https://token.actions.githubusercontent.com"

  github_oidc_thumbprint = var.github_oidc_provider_arn != null ? null : try(
    data.tls_certificate.github_oidc[0].certificates[
      length(data.tls_certificate.github_oidc[0].certificates) - 1
    ].sha1_fingerprint,
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  )

  github_oidc_provider_identifiers = var.github_oidc_provider_arn != null ? [var.github_oidc_provider_arn] : aws_iam_openid_connect_provider.github_oidc[*].arn
}

data "tls_certificate" "github_oidc" {
  count = var.github_oidc_provider_arn == null ? 1 : 0
  url   = local.github_oidc_issuer_url
}

resource "aws_iam_openid_connect_provider" "github_oidc" {
  count = var.github_oidc_provider_arn == null ? 1 : 0

  url             = local.github_oidc_issuer_url
  client_id_list  = var.github_oidc_client_ids
  thumbprint_list = [local.github_oidc_thumbprint]

  tags = local.default_tags
}

data "aws_iam_policy_document" "github_build_artifacts" {
  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [format("arn:aws:s3:::%s", local.destination_bucket_name_effective)]

    dynamic "condition" {
      for_each = length(local.destination_bucket_prefix_condition_values) == 0 ? [] : [true]
      content {
        test     = "StringLike"
        variable = "s3:prefix"
        values   = local.destination_bucket_prefix_condition_values
      }
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = [local.destination_bucket_prefix_object_arn]
  }
}

resource "aws_iam_policy" "github_build_artifacts" {
  name        = "${local.environment}-github-build-artifacts"
  description = "Allow GitHub Actions to manage build outputs for ${local.environment}"
  policy      = data.aws_iam_policy_document.github_build_artifacts.json
}

data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = local.github_oidc_provider_identifiers
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = var.github_oidc_client_ids
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = var.github_oidc_subjects
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name               = "${local.environment}-github-actions"
  description        = "Assumable by GitHub Actions via OIDC for ${local.environment}"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json

  tags = local.default_tags
}

resource "aws_iam_role_policy_attachment" "github_actions_build_artifacts" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_build_artifacts.arn
}
