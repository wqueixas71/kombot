#!/bin/bash
set -e

systemctl daemon-reload
systemctl enable kombot
systemctl restart kombot