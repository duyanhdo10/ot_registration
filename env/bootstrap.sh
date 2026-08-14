#!/usr/bin/env bash
# Dựng thư mục môi trường Odoo 17 từ các file trong repo.
#
# Dùng:
#   ./env/bootstrap.sh /duong/dan/toi/odoo17
#
# Script chỉ COPY, không ghi đè file đã tồn tại và không chạy docker.
# Xem docs/SETUP.md để biết các bước tiếp theo.

set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "Dùng: $0 <ODOO_ROOT>" >&2
    echo "Ví dụ: $0 ~/projects/odoo17" >&2
    exit 2
fi

ODOO_ROOT="$1"
ENV_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$ENV_DIR")"
REPO_NAME="$(basename "$REPO_DIR")"

copy_if_absent() {
    local src="$1" dst="$2"
    if [[ -e "$dst" ]]; then
        echo "  bỏ qua (đã có): ${dst#"$ODOO_ROOT"/}"
    else
        mkdir -p "$(dirname "$dst")"
        cp "$src" "$dst"
        echo "  tạo:            ${dst#"$ODOO_ROOT"/}"
    fi
}

echo "ODOO_ROOT = $ODOO_ROOT"
mkdir -p "$ODOO_ROOT/custom_addons"

copy_if_absent "$ENV_DIR/compose.yml"                  "$ODOO_ROOT/compose.yml"
copy_if_absent "$ENV_DIR/compose.debug.yml"            "$ODOO_ROOT/compose.debug.yml"
copy_if_absent "$ENV_DIR/config/odoo.conf"             "$ODOO_ROOT/config/odoo.conf"
copy_if_absent "$ENV_DIR/docker/odoo-debug.Dockerfile" "$ODOO_ROOT/docker/odoo-debug.Dockerfile"

echo
if [[ ! -e "$ODOO_ROOT/custom_addons/$REPO_NAME" ]]; then
    echo "Repo chưa nằm trong custom_addons/. Chạy một trong hai:"
    echo "  ln -s '$REPO_DIR' '$ODOO_ROOT/custom_addons/$REPO_NAME'"
    echo "  # hoặc clone thẳng repo vào $ODOO_ROOT/custom_addons/"
else
    echo "custom_addons/$REPO_NAME đã có."
fi

echo
echo "Tiếp theo:"
echo "  cd '$ODOO_ROOT'"
echo "  docker compose -f compose.yml up -d"
echo "  # xem docs/SETUP.md phần kiểm chứng"
