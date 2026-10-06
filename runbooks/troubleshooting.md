# Troubleshooting Log — WebLogic + OHS Lab

Real issues encountered while building this lab and the fix for each.

## 1. Node Manager: Access to domain denied
**Symptom:** startComponent.sh fails with
`[Access to domain 'domain_home' for user 'weblogic' denied]`
**Cause:** nm_password.properties missing or username mismatch
**Fix:** Set correct username/password in
`<domain>/nodemanager/nm_password.properties`. Restart Node Manager.

## 2. HTTP 404 from OHS on /testapp
**Symptom:** Browser shows 404 at http://localhost:7777/testapp/
**Cause:** No <Location> block in mod_wl_ohs.conf routing /testapp
**Fix:** Add
<Location /testapp>
  SetHandler weblogic-handler
  WebLogicCluster <ms1>:<port>,<ms2>:<port>
</Location>
Then restart OHS.

## 3. Failure of Web Server Bridge
**Symptom:** OHS returns "Failure of Web Server Bridge"
**Cause:** All managed servers in the cluster are down
**Fix:** Start managed servers via Admin Console or Node Manager.
This is OHS correctly detecting the backend is unreachable.

## 4. HTTP 404 directly on WebLogic managed server
**Symptom:** curl http://<ms>:<port>/ returns 404
**Cause:** No application deployed at root context
**Fix:** Deploy a WAR (testapp.war) targeted to the cluster.

## 5. XML parsing errors when deploying WAR
**Symptom:** Install Application fails with
`Error at line:X col:Y '<' expected a valid beginning name character`
**Cause:** Malformed XML in web.xml or weblogic.xml (missing >,
wrong namespace, unclosed attribute)
**Fix:** Validate with `xmllint --noout web.xml weblogic.xml`
before deploying.

## 6. Session ID changes on failover
**Symptom:** Server name switches after shutdown, but session ID changes
**Cause:** Session replication not active
**Fixes applied:**
- Add `<distributable/>` to WEB-INF/web.xml
- Add weblogic.xml with `<persistent-store-type>replicated_if_clustered</persistent-store-type>`
- Set cluster Replication Type = MAN (Synchronous)
- Remove any custom channel named ReplicationChannel
  - WebLogic BEA-000198 requires cluster replication over Default[t3]
- Verify both managed servers in same cluster with unicast messaging

## 7. WEB_INF vs WEB-INF (underscore vs hyphen)
**Symptom:** Deployed WAR has no effect; session replication still fails
**Cause:** Directory named WEB_INF (underscore) instead of WEB-INF
**Fix:** `mv WEB_INF WEB-INF` and rebuild the WAR. WAR spec is strict.

## 8. ReplicationChannel readonly in WLST
**Symptom:** `cmo.setReplicationChannel('')` fails with
"attribute is not exposed through JMX"
**Cause:** Auto-derived attribute, cannot be set manually
**Fix:** Delete the custom channel from BOTH servers; restart Admin +
managed servers. WebLogic falls back to Default[t3].

## 9. Missing testapp.war after rebuild
**Symptom:** find shows the WAR only in
`.../config/deployments/testapp.war`
**Cause:** Original WAR deleted from source directory
**Fix:** Rebuild from source: `jar -cvf testapp.war index.jsp WEB-INF`
in the app source directory.