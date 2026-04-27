#!/bin/bash
set -e

AWS_REGION="sa-east-1"

GEMINI_API_KEY=$(aws ssm get-parameter \
  --name "/kombot/prod/GEMINI_API_KEY" \
  --with-decryption \
  --region "$AWS_REGION" \
  --query "Parameter.Value" \
  --output text)

cat > /opt/kombot/.env <<EOF
AWS_REGION=sa-east-1
APP_ENV=prod
PROJECT_NAME=kombot
GEMINI_API_KEY=${GEMINI_API_KEY}
EOF

chown kombot:kombot /opt/kombot/.env
chmod 600 /opt/kombot/.env

systemctl daemon-reload
systemctl enable kombot
systemctl restart kombot