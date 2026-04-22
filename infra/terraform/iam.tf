data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "kombot_ec2" {
  name               = "${local.name_prefix}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_instance_profile" "kombot" {
  name = "${local.name_prefix}-instance-profile"
  role = aws_iam_role.kombot_ec2.name
}

data "aws_iam_policy_document" "ssm_access" {
  statement {
    sid    = "ReadKombotParameters"
    effect = "Allow"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath"
    ]
    resources = [
      "arn:aws:ssm:${var.aws_region}:*:parameter/${var.project_name}/${var.environment}",
      "arn:aws:ssm:${var.aws_region}:*:parameter/${var.project_name}/${var.environment}/*"
    ]
  }

  statement {
    sid       = "DecryptSecureString"
    effect    = "Allow"
    actions   = ["kms:Decrypt"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "ssm_access" {
  name   = "${local.name_prefix}-ssm-access"
  role   = aws_iam_role.kombot_ec2.id
  policy = data.aws_iam_policy_document.ssm_access.json
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = aws_iam_role.kombot_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}