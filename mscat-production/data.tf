data "aws_caller_identity" "current" {}

data "aws_ec2_instance_type" "asg" {
  instance_type = var.ec2_instance_type
}

data "aws_ecr_image" "solr" {
  for_each        = var.solr_ecr_repositories
  repository_name = each.key
  image_digest    = each.value
}

data "aws_ssm_parameter" "cudl_viewer_cloudfront_username" {
  name = "/Environments/${title(local.environment)}/CUDL/Viewer/CloudFront/Username"
}

data "aws_ssm_parameter" "cudl_viewer_cloudfront_password" {
  name = "/Environments/${title(local.environment)}/CUDL/Viewer/CloudFront/Password"
}

data "aws_ssm_parameter" "cudl_viewer_cloudfront_secret" {
  name = "/Environments/${title(local.environment)}/CUDL/Viewer/CloudFront/Secret"
}

data "aws_ssm_parameter" "cudl_viewer_cloudfront_jwt_duration" {
  name = "/Environments/${title(local.environment)}/CUDL/Viewer/CloudFront/Jwt_duration"
}
