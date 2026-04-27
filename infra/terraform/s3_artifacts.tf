# s3_artifacts.tf

resource "aws_s3_bucket" "kombot_artifacts" {
  bucket = "kombot-artifacts-${data.aws_caller_identity.current.account_id}"
}