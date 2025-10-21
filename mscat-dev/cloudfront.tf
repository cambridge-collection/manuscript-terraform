resource "aws_cloudfront_function" "mscat" {
  name                         = "${local.environment}-clean_urls"
  runtime                      = "cloudfront-js-2.0"
  comment                      = "clean-and-redirect"
  publish                      = true
  key_value_store_associations = [aws_cloudfront_key_value_store.viewer.arn]
  code                         = file("${path.module}/templates/mscat/cloudfront-function.js.ttfpl")
}

resource "aws_cloudfront_function" "search" {
  name                         = "${local.environment}-search-api"
  runtime                      = "cloudfront-js-2.0"
  comment                      = "search api frontend"
  publish                      = true
  key_value_store_associations = [aws_cloudfront_key_value_store.viewer.arn]
  code                         = file("${path.module}/templates/mscat/search-frontend.js.ttfpl")
}

resource "aws_cloudfront_key_value_store" "viewer" {
  name = "${local.environment}-cudl-viewer"
}

resource "aws_cloudfrontkeyvaluestore_key" "username" {
  key_value_store_arn = aws_cloudfront_key_value_store.viewer.arn
  key                 = "username"
  value               = data.aws_ssm_parameter.cudl_viewer_cloudfront_username.value
}

resource "aws_cloudfrontkeyvaluestore_key" "password" {
  key_value_store_arn = aws_cloudfront_key_value_store.viewer.arn
  key                 = "password"
  value               = data.aws_ssm_parameter.cudl_viewer_cloudfront_password.value
}

resource "aws_cloudfrontkeyvaluestore_key" "domain" {
  key_value_store_arn = aws_cloudfront_key_value_store.viewer.arn
  key                 = "domain"
  value               = "cudl-sandbox.net"
  # The value should be generated from registered_domain_name (with a replace to remove trailing period)
}

resource "aws_cloudfrontkeyvaluestore_key" "privateSite" {
  key_value_store_arn = aws_cloudfront_key_value_store.viewer.arn
  key                 = "privateSite"
  value               = true
}

resource "aws_cloudfrontkeyvaluestore_key" "secret" {
  key_value_store_arn = aws_cloudfront_key_value_store.viewer.arn
  key                 = "secret"
  value               = data.aws_ssm_parameter.cudl_viewer_cloudfront_secret.value
}

resource "aws_cloudfrontkeyvaluestore_key" "jwtDuration" {
  key_value_store_arn = aws_cloudfront_key_value_store.viewer.arn
  key                 = "jwtDuration"
  value               = data.aws_ssm_parameter.cudl_viewer_cloudfront_jwt_duration.value
}
