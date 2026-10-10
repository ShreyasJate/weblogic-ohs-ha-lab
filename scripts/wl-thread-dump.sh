#!/bin/bash

#---------wl-thread-dump.sh--------------
#---------to generate thread dumps-------
#---------By Shreyas Jate----------------
set -eou pipefail
JSTACK="/middleware_home/java/jdk-11.0.32.1/bin/jstack"
DUMP_DIR="/middleware_logs/threaddumps"
servers=("MyMS1" "MyMS2")

find_pid() {
local server_name="$1"
local pid
pid=$(pgrep -f "weblogic.Name=$server_name" || true)
if [[ -n "$pid" ]]; then
   echo "$pid"
fi
}

dump_threads() {
   local server_name="$1"
   local pid
   pid=$(find_pid "$server_name")

   if [[ -z "$pid" ]]; then
      echo "$(date '+%Y-%m-%d %H:%M:%S') FAIL $server_name: not running"
      return
   fi

local ts
ts=$(date +%Y%m%d_%H%M%S)
local dump_file="${DUMP_DIR}/${server_name}_threaddump_${ts}.txt"

"$JSTACK" "$pid" > "$dump_file" 2>&1 || true

echo "$(date '+%Y-%m-%d %H:%M:%S') OK $server_name: dump written to $dump_file"

}
mkdir -p "$DUMP_DIR"
for s in "${servers[@]}"; do
    dump_threads "$s"
done
