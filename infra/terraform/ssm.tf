resource "aws_ssm_parameter" "gemini_api_key" {
  name      = "/${var.project_name}/${var.environment}/GEMINI_API_KEY"
  type      = "SecureString"
  value     = var.gemini_api_key

  tags = {
    Name = "${local.name_prefix}-gemini-api-key"
  }
}

resource "aws_ssm_parameter" "log_level" {
  name  = "/${var.project_name}/${var.environment}/LOG_LEVEL"
  type  = "String"
  value = var.log_level

  tags = {
    Name = "${local.name_prefix}-log-level"
  }
}

resource "aws_ssm_parameter" "app_env" {
  name  = "/${var.project_name}/${var.environment}/APP_ENV"
  type  = "String"
  value = var.app_env

  tags = {
    Name = "${local.name_prefix}-app-env"
  }
}