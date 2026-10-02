# WebLogic 14c + OHS 14c HA Lab

## Architecture

| VM | Hostname | Role | IP | Ports |
|----|----------|------|----|-------|
| VM1 | Node1 | Admin Server + MyMS1 | 192.168.0.109 | 7001, 7003, 5556 |
| VM2 | Node2 | MyMS2 | 192.168.0.110 | 7004, 5556 |
| VM3 | Node3 | OHS 14c | localhost | 7777 |

Request flow:
Browser → OHS (7777) → WebLogic Cluster (7003 / 7004)

## Components
- WebLogic 14c (Admin + 2 Managed Servers in MyCluster)
- Node Manager (per-host)
- OHS 14c with mod_wl_ohs
- MAN (Synchronous) HTTP Session Replication
- testapp.war with `<distributable/>` + weblogic.xml

## Setup Steps
1. Install WebLogic 14c on VM1 and VM2
2. Install OHS 14c on VM3
3. Create domain with Admin + 2 Managed Servers
4. Configure Node Manager on both VMs
5. Create cluster MyCluster, assign MyMS1 + MyMS2
6. Set cluster Replication Type = MAN (Synchronous)
7. Configure mod_wl_ohs on VM3 to route /testapp to cluster
8. Deploy testapp.war (distributable) to cluster

## Failover Test
- Hit http://localhost:7777/testapp/ through OHS
- Shut down one managed server
- Refresh: page still loads, session ID preserved
- Confirms session replication + OHS failover

## Issues Faced & Fixed
- Node Manager auth: [Access to domain denied] → fixed nm_password.properties
- HTTP 404 from OHS → added `<Location /testapp>` block in mod_wl_ohs.conf
- Web Server Bridge failure → both managed servers were down
- Session ID changing on failover → fixed by:
  - Adding `<distributable/>` to web.xml
  - Adding weblogic.xml with replicated_if_clustered
  - Removing custom ReplicationChannel (WebLogic needs Default[t3])
  - Ensuring WEB-INF directory name (underscore vs hyphen)