#!/usr/bin/env bash
set -euo pipefail

APP_DIR="/opt/kombot"
SERVICE_NAME="kombot"
BRANCH="aws"

echo "==> Executando como usuário: $(whoami)"

echo "==> Indo para ${APP_DIR}"
cd "${APP_DIR}"

echo "==> Atualizando código"
git fetch origin
git checkout "${BRANCH}"
git pull origin "${BRANCH}"

echo "==> Ativando virtualenv"
source venv/bin/activate

echo "==> Atualizando dependências"
pip install --upgrade pip
pip install -r requirements.txt

echo "==> Reiniciando serviço"
sudo systemctl restart "${SERVICE_NAME}"

echo "==> Status do serviço"
sudo systemctl --no-pager --full status "${SERVICE_NAME}"

echo "==> Últimos logs"
journalctl -u "${SERVICE_NAME}" -n 30 --no-pager