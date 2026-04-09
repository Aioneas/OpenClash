#!/bin/sh
set -eu

if [ "$#" -lt 3 ]; then
  echo "Usage: $0 <router_ip> <ssh_user> <ssh_password>"
  exit 1
fi

ROUTER_IP="$1"
SSH_USER="$2"
SSH_PASS="$3"
ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || { echo "missing command: $1"; exit 1; }
}

need_cmd sshpass
need_cmd scp
need_cmd ssh

cd "$ROOT_DIR"
./scripts/validate_repo.sh

echo "[sync] upload files"
for f in \
  openclash/custom/openclash_custom_overwrite.sh \
  openclash/custom/aioneas_openclash_overwrite.rb \
  openclash/custom/openclash_custom_rules.list \
  openclash/custom/openclash_custom_rules_2.list
 do
  sshpass -p "$SSH_PASS" scp -O -o StrictHostKeyChecking=no -o ConnectTimeout=8 \
    "$f" "$SSH_USER@$ROUTER_IP:/etc/openclash/custom/$(basename "$f")"
done

echo "[sync] verify and restart openclash"
sshpass -p "$SSH_PASS" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=8 "$SSH_USER@$ROUTER_IP" '
set -e
chmod +x /etc/openclash/custom/openclash_custom_overwrite.sh
ruby -c /etc/openclash/custom/aioneas_openclash_overwrite.rb
/etc/openclash/custom/openclash_custom_overwrite.sh /etc/openclash/config/clash.yaml
/etc/openclash/core/clash_meta -t -d /etc/openclash -f /etc/openclash/config/clash.yaml
/etc/init.d/openclash restart >/tmp/openclash_restart.out 2>&1 || cat /tmp/openclash_restart.out
tail -n 80 /tmp/openclash.log
'

echo "OK: sync finished"
