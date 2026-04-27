# codedeploy.tf

resource "aws_codedeploy_app" "kombot" {
  name             = "kombot"
  compute_platform = "Server"
}

resource "aws_codedeploy_deployment_group" "kombot" {
  app_name              = aws_codedeploy_app.kombot.name
  deployment_group_name = "kombot-prod"
  service_role_arn      = aws_iam_role.codedeploy_role.arn

  ec2_tag_set {
    ec2_tag_filter {
      key   = "App"
      type  = "KEY_AND_VALUE"
      value = "kombot"
    }
  }

  deployment_config_name = "CodeDeployDefault.OneAtATime"
}