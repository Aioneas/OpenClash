#!/bin/sh
. /usr/share/openclash/log.sh

LOG_OUT "Tip: Start Running Aioneas OpenClash Custom Overwrite..."
LOG_FILE="/tmp/openclash.log"
CONFIG_FILE="$1"
RUBY_SCRIPT="/etc/openclash/custom/aioneas_openclash_overwrite.rb"

[ -f "$CONFIG_FILE" ] || exit 0

if [ ! -f "$RUBY_SCRIPT" ]; then
  LOG_OUT "Error: Missing custom overwrite Ruby script: $RUBY_SCRIPT"
  exit 0
fi

ruby "$RUBY_SCRIPT" "$CONFIG_FILE" >> "$LOG_FILE" 2>&1
exit 0
