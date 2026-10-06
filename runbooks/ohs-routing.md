# OHS Routing to WebLogic Cluster

## Purpose
Route HTTP traffic from OHS 14c to a WebLogic 14c cluster using mod_wl_ohs.

## Component Layout
- OHS 14c on VM3 (localhost), listening on port 7777
- WebLogic cluster `MyCluster` with:
  - MyMS1 -> 192.168.0.109:7003
  - MyMS2 -> 192.168.0.110:7004

## Config File Location
/middleware_domain/ohs/oracle/middleware/domain_home/config/fmwconfig/components/OHS/instances/ohs1/mod_wl_ohs.conf

## mod_wl_ohs.conf — Relevant Section

LoadModule weblogic_module "${PRODUCT_HOME}/modules/mod_wl_ohs.so"

<Location /testapp>
    SetHandler weblogic-handler
    WebLogicCluster 192.168.0.109:7003,192.168.0.110:7004
    WLLogFile /tmp/wl_proxy.log
    Debug ON
</Location>

## Key Points
- `WebLogicCluster` lists ALL managed servers in the cluster (comma-separated)
- `<Location>` block scopes the routing to URLs under /testapp
- `WLLogFile` is essential for troubleshooting (shows proxied requests + errors)
- OHS load-balances between the listed managed servers (round-robin by default)
- Sticky sessions keep each browser tied to one server until failover

## Restart OHS
/middleware_domain/ohs/oracle/middleware/domain_home/bin/stopComponent.sh ohs1
/middleware_domain/ohs/oracle/middleware/domain_home/bin/startComponent.sh ohs1

## Verify
curl -I http://localhost:7777/testapp/      # Expect 200 OK
curl -I http://192.168.0.109:7003/testapp/  # Direct to MyMS1
curl -I http://192.168.0.110:7004/testapp/  # Direct to MyMS2

## Common Errors
- **404 Not Found** from OHS -> missing or wrong <Location> block
- **Failure of Web Server Bridge** -> WebLogic cluster members are down
- **Connection refused** on OHS port -> OHS not started or firewalld blocking
- **Permission denied** when startComponent.sh runs -> Node Manager auth mismatch

