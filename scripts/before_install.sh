#!/bin/bash
set -e

systemctl stop kombot || true
mkdir -p /opt/kombot
chown -R kombot:kombot /opt/kombot
chmod -R 775 /opt/kombot