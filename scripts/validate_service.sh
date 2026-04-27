#!/bin/bash
set -e

systemctl is-active --quiet kombot
curl -f http://localhost:8501/_stcore/health
