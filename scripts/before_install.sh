#!/bin/bash
set -e

systemctl stop kombot || true
mkdir -p /opt/kombot
mkdir -p /opt/kombot/logs
touch /opt/kombot/logs/app.log

chown -R kombot:kombot /opt/kombot
chmod -R 775 /opt/kombot