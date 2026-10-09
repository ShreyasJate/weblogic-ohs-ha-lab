#!/bin/bash


#wl-health-check.sh
#Checks WebLogic Admin, Managed Servers, and OHS health
#Auther: Shreyas Jate
#usage: ./wl-health-check.sh



set -euo pipefail
ADMIN_URL="http://192.168.0.109:7001/console/login/LoginForm.jsp"
MS1_URL="http://192.168.0.109:7003/testapp/"
MS2_URL="http://192.168.0.110:7004/testapp/"
OHS_URL="http://localhost:7777/testapp/"
LOG_DIR="/middleware_logs/wl-health-check"
mkdir -p "$LOG_DIR"
LOG_FILE="${LOG_DIR}/health_$(date +%Y%m%d_%H%M%S).log"

log() {
   local ts
   ts=$(date '+%Y-%m-%d %H:%M:%S')
   echo "[$ts] $*" | tee -a "$LOG_FILE"
}
#-------------------health check ----------------

check_url() {

local name="$1"
local url="$2"
local code
code=$(curl -s -o /dev/null/ -w "%{http_code}" -m 5 "$url" || true)
if [[ $code = "200" ]]; then
   log "OK [$name] $url -> $code"
   return 0
else
   log "FAIL [$name] $url -> $code"
   return 1
fi
}
#-------------------------------Main--------------------------

main() {
  log "=== WebLogic + OHS Health Check Start ==="
  local rc=0

  check_url "Admin Server" "$ADMIN_URL" || rc=1
  check_url "MyMS1" "$MS1_URL"          || rc=1
  check_url "MyMS2" "$MS2_URL"          || rc=1
  check_url "OHS" "$OHS_URL"            || rc=1

  if [[ "$rc" -eq 0 ]]; then
     log "=== RESULT: ALL HEALTHY ==="
  else
     log "=== RESULT: ONE OR MORE UNHEALTHY ==="
  fi

  log " Log file: $LOG_FILE"
  return "$rc"
}

main "$@"
