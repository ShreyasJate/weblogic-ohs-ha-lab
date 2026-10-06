# Failover Test — Session Replication

## Purpose
Verify that HTTP session state survives a managed server failure
in the WebLogic cluster behind OHS.

## Preconditions
- WebLogic 14c cluster `MyCluster` with MyMS1 + MyMS2 (both RUNNING)
- OHS 14c running on port 7777, routing /testapp to the cluster
- testapp.war deployed (distributable, weblogic.xml with replicated_if_clustered)
- Cluster Replication Type: MAN (Synchronous)

## Steps
1. Open a fresh browser (incognito) to:
   http://localhost:7777/testapp/
2. Note the Server name and Session ID on the page.
3. In Admin Console, shut down the managed server currently serving the request:
   Servers -> MyMSx -> Control -> Force shutdown now
4. Wait until the server shows SHUTDOWN.
5. Refresh the browser tab (F5).
6. Note the new Server name and Session ID.

## Expected Result
- Page still loads (failover works via OHS)
- Server name switches to the surviving managed server
- Session ID remains unchanged (proves session replication)

## Observed Result (lab)
- Before: Server=MyMS2, Session=0Nn7wd5F7FVYrMH2RZEWRUuCIC-Q71wbZ1IBsaCmHMbWl_dQ1ln!1159265667!...
- After:  Server=MyMS1, Session=0Nn7wd5F7FVYrMH2RZEWRUuCIC-Q71wbZ1IBsaCmHMbWl_dQ1ln!-1297649835!NONE!
- Session ID prefix identical => session replicated successfully.

## Troubleshooting notes
- If session ID changes: verify `<distributable/>` in web.xml
- Verify weblogic.xml contains `<persistent-store-type>replicated_if_clustered</persistent-store-type>`
- Verify cluster Replication Type is MAN (Synchronous)
- Confirm no custom channel named ReplicationChannel exists
  (WebLogic requires Default[t3] for cluster replication)

