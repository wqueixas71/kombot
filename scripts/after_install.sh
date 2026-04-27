#!/bin/bash
set -e

cd /opt/kombot

python3 -m venv venv
source venv/bin/activate

pip install --upgrade pip
pip install -r requirements.txt

chown -R kombot:kombot /opt/kombot