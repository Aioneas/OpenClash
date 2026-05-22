#!/bin/sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT_DIR"

echo "[1/5] check required files"
for f in \
  README.md \
  docs/MAINTENANCE.md \
  docs/rule-providers.csv \
  openclash/custom/openclash_custom_overwrite.sh \
  openclash/custom/aioneas_openclash_overwrite.rb \
  openclash/custom/openclash_custom_rules.list \
  openclash/custom/openclash_custom_rules_2.list \
  public/openclash.public.reference.yaml
 do
  [ -f "$f" ] || { echo "missing: $f"; exit 1; }
 done

echo "[2/5] shell syntax"
sh -n openclash/custom/openclash_custom_overwrite.sh

echo "[3/5] ruby syntax"
if command -v ruby >/dev/null 2>&1; then
  ruby -c openclash/custom/aioneas_openclash_overwrite.rb
else
  echo "skip ruby syntax: ruby not installed locally"
fi

echo "[4/5] rule-provider and rule consistency"
required_providers="YouTube Disney HBOMax Netflix Bahamut BiliBili Spotify Steam Telegram Google Microsoft GitHub OpenAI Claude DeepSeek PayPal Link WeChat WSJ Economist NewYorkTimes Caixin Apple Speedtest Global Pixiv China Lan"

for name in $required_providers; do
  grep -q "'$name' =>" openclash/custom/aioneas_openclash_overwrite.rb || {
    echo "missing rule-provider in overwrite script: $name"
    exit 1
  }
  grep -q "RULE-SET,$name," openclash/custom/openclash_custom_rules.list || {
    echo "missing RULE-SET in custom rules: $name"
    exit 1
  }
done

required_groups="Proxies Final Google Apple OpenAI Claude DeepSeek YouTube Netflix Disney HBOMax Bahamut BiliBili Spotify Steam Telegram Microsoft GitHub PayPal Link WeChat WSJ Economist NewYorkTimes Caixin Speedtest HK JP SG TW US"
for name in $required_groups; do
  grep -q "'name' => '$name'" openclash/custom/aioneas_openclash_overwrite.rb || {
    echo "missing proxy-group in overwrite script: $name"
    exit 1
  }
done

grep -q 'GEOIP,CN,DIRECT' openclash/custom/openclash_custom_rules.list
grep -q 'MATCH,Final' openclash/custom/openclash_custom_rules.list

echo "[5/5] public config safety smoke check"
# Only block obvious secret-looking strings in executable/config files. Documentation often
# contains words like "subscription" as part of the operating instructions.
if grep -RInE 'token|password|passwd|secret|authorization|bearer|api[_-]?key|private[_-]?key' \
  openclash public scripts \
  --exclude='validate_repo.sh' \
  >/tmp/openclash_public_safety_matches.$$; then
  echo "potential sensitive terms found in public config/script files; review these matches:"
  cat /tmp/openclash_public_safety_matches.$$
  rm -f /tmp/openclash_public_safety_matches.$$
  exit 1
fi
rm -f /tmp/openclash_public_safety_matches.$$

echo "OK: repository validation passed"
