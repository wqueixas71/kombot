resource "aws_instance" "kombot" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.kombot.id]
  iam_instance_profile        = aws_iam_instance_profile.kombot.name
  key_name                    = var.key_name
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/user_data.sh.tftpl", {
    aws_region   = var.aws_region
    app_env      = var.app_env
    project_name = var.project_name
  })

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    volume_size = 16
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name = "${local.name_prefix}-ec2"
    App  = "kombot"
  }

}

resource "aws_iam_role_policy" "ec2_read_artifacts" {
  name = "kombot-ec2-read-artifacts"
  role = aws_iam_role.kombot_ec2.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.kombot_artifacts.arn,
          "${aws_s3_bucket.kombot_artifacts.arn}/*"
        ]
      }
    ]
  })
}