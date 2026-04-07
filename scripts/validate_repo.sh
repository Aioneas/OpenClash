#!/bin/sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT_DIR"

echo "[1/4] check files"
for f in \
  README.md \
  openclash/custom/openclash_custom_overwrite.sh \
  openclash/custom/aioneas_openclash_overwrite.rb \
  openclash/custom/openclash_custom_rules.list \
  openclash/custom/openclash_custom_rules_2.list \
  ruleset/Link.yaml \
  public/openclash.public.reference.yaml
 do
  [ -f "$f" ] || { echo "missing: $f"; exit 1; }
 done

echo "[2/4] shell syntax"
sh -n openclash/custom/openclash_custom_overwrite.sh

echo "[3/4] ruby syntax"
if command -v ruby >/dev/null 2>&1; then
  ruby -c openclash/custom/aioneas_openclash_overwrite.rb
else
  echo "skip ruby syntax: ruby not installed locally"
fi

echo "[4/4] basic content checks"
grep -q 'Aioneas/OpenClash/main/ruleset/Link.yaml' openclash/custom/aioneas_openclash_overwrite.rb
grep -q 'RULE-SET,Link,Link' openclash/custom/openclash_custom_rules.list
grep -q 'payload:' ruleset/Link.yaml

echo "OK: repository validation passed"
