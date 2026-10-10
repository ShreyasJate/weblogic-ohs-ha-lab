#!/bin/bash

set -eou pipefail

LOG_DIR="/middleware_domain/oracle/middleware/servers/MyMS1/logs"

output=("ERROR" "STUCK" "OutOfMemory" "JDBC")

scan_file() {
local filepath="$1"
for pattern in "${output[@]}"; do
    count=$(grep -c "$pattern" "$filepath" || true)
    echo "$filepath - $pattern: $count matches"
done
}
echo "Scanning logs in $LOG_DIR"
for file in "$LOG_DIR"/*.log; do
    if [[ -f "$file" ]]; then
       scan_file "$file"
    fi
done
