###################################### Modules ######################################
Import-Module SwisPowerShell
  
###################################### Variables ######################################
$timestamp = Get-Date -f MM-dd-yyy_HH_mm_ss

###################################### Get SW Auth ######################################
$credentials = Get-Credential
$hostname = Read-Host "Enter the host name of the SolarWinds Server you want to connect to"
$swis = connect-swis -host $hostname -Credential $credentials


###################################### Get stats on a poller basis ######################################

Write-Host "Running poller checks"
$getSystemStats = Get-SwisData $swis "SELECT GETDATE() AS [Queried At], E.ServerName, E.ServerType, E.WindowsVersion, E.EngineVersion, E.IP, E.PollingCompletion, 
                                        (SELECT PU.CurrentUsage
                                                FROM Orion.PollingUsage AS PU
                                                WHERE PU.EngineID = E.EngineID AND PU.ScaleFactor = 'Orion.Standard.Polling') AS [POLLING RATE %],
                                        (SELECT COUNT (N.ObjectSubType) AS [ICMP Polling Method]
                                                FROM Orion.Nodes AS N
                                                WHERE N.EngineID = E.EngineID AND  ObjectSubType = 'ICMP') AS [ICMP Polling Method],
                                        (SELECT COUNT (N.ObjectSubType) AS [SNMP Polling Method]
                                                FROM Orion.Nodes AS N
                                                WHERE N.EngineID = E.EngineID AND  ObjectSubType = 'SNMP') AS [SNMP Polling Method],
                                        (SELECT COUNT (N.ObjectSubType) AS [WMI Polling Method]
                                                FROM Orion.Nodes AS N
                                                WHERE N.EngineID = E.EngineID AND  ObjectSubType = 'WMI') AS [WMI Polling Method],
                                        (SELECT COUNT (N.ObjectSubType) AS [Agent Polling Method]
                                                FROM Orion.Nodes AS N
                                                WHERE N.EngineID = E.EngineID AND  ObjectSubType = 'Agent') AS [Agent Polling Method],
                                        E.Elements, E.Nodes, E.Volumes, E.Interfaces, 
                                            (SELECT PU.CurrentUsage
                                                FROM Orion.PollingUsage AS PU
                                                WHERE PU.EngineID = E.EngineID AND PU.ScaleFactor = 'APM.Components.Polling') AS [SAM APPLICATION POLLING RATE],
                                            (SELECT COUNT (APM.NodeID) as templates FROM Orion.APM.Application AS APM LEFT JOIN Orion.Nodes AS N ON N.NodeID = APM.NodeID WHERE APM.NodeID = N.NodeID AND N.EngineID = E.EngineID) AS [Total SAM Templates], 
                                            (SELECT COUNT (comp.ComponentID) as comp FROM Orion.APM.Component AS comp LEFT JOIN Orion.APM.Application AS APM ON APM.ApplicationID = comp.ApplicationID LEFT JOIN Orion.Nodes AS N ON N.NodeID = APM.NodeID WHERE APM.NodeID = N.NodeID AND N.EngineID = E.EngineID AND comp.Status != 27) AS [Total Active Components Per SAM Template], 
                                            (SELECT COUNT (comp.ComponentID) as comp FROM Orion.APM.Component AS comp LEFT JOIN Orion.APM.Application AS APM ON APM.ApplicationID = comp.ApplicationID LEFT JOIN Orion.Nodes AS N ON N.NodeID = APM.NodeID WHERE APM.NodeID = N.NodeID AND N.EngineID = E.EngineID) AS [Total Components Per SAM Template], 
                                            (SELECT PU.CurrentUsage
                                                FROM Orion.PollingUsage AS PU
                                                WHERE PU.EngineID = E.EngineID AND PU.ScaleFactor = 'APM.Wstm.Polling') AS [SAM WINDOWS SCHEDULED TASKS POLLING RATE],
                                            (SELECT PU.CurrentUsage
                                                FROM Orion.PollingUsage AS PU
                                                WHERE PU.EngineID = E.EngineID AND PU.ScaleFactor = 'HardwareHealth.Polling') AS [HARDWARE HEALTH POLLING RATE],
                                            (SELECT PU.CurrentUsage
                                                FROM Orion.PollingUsage AS PU
                                                WHERE PU.EngineID = E.EngineID AND PU.ScaleFactor = 'IPAM.Dhcp.Subnet.Polling') AS [FIBRE CHANNEL POLLING RATE],
                                            (SELECT PU.CurrentUsage
                                                FROM Orion.PollingUsage AS PU
                                                WHERE PU.EngineID = E.EngineID AND PU.ScaleFactor = 'Orion.NPM.Routing') AS [ROUTING POLLING RATE],
                                            (SELECT PU.CurrentUsage
                                                FROM Orion.PollingUsage AS PU
                                                WHERE PU.EngineID = E.EngineID AND PU.ScaleFactor = 'Orion.Packages.Wireless') AS [WIRELESS POLLING RATE],
                                            (SELECT PU.CurrentUsage
                                                FROM Orion.PollingUsage AS PU
                                                WHERE PU.EngineID = E.EngineID AND PU.ScaleFactor = 'VIM.VMware.Polling') AS [VIM HYPER-V POLLING RATE],
                                            (SELECT PU.CurrentUsage
                                                FROM Orion.PollingUsage AS PU
                                                WHERE PU.EngineID = E.EngineID AND PU.ScaleFactor = 'VIM.HyperV.Polling') AS [VIM VMWARE POLLING RATE],
                                            (SELECT EP.PropertyValue
                                                FROM Orion.EngineProperties AS EP
                                                WHERE EP.PropertyName = 'Total Job Weight' AND EP.EngineID = E.EngineID) AS [Total Job Weight],
                                            (SELECT COUNT (HI.NodeID) AS HWD 
                                                FROM Orion.HardwareHealth.HardwareInfo AS HI 
                                                LEFT JOIN Orion.Nodes AS N ON N.NodeID = HI.NodeID 
                                                WHERE N.EngineID = E.EngineID) AS [NUMBER OF HW HEALTH MONITORS]
                                        FROM ORion.Engines AS E"

#Export query to desired loction with a time stamp to keep seperate
$getSystemStats | Export-Csv "C:\Scripts\Automation\logs\system checks $timestamp.csv"
Write-Host "Poller checks complete, this has been exported to C:\Scripts\Automation\logs\system checks $timestamp.csv"

###################################### Get Detailed View ######################################

Write-Host "Running node detailed checks"
$getDetailedNode = Get-SwisData $swis "SELECT N.NodeID, N.ObjectSubType, N.IPAddress, N.Caption, EN.ServerName, APM.Name AS TemplateName, (SELECT COUNT (ComponentID) AS ComponentID FROM Orion.APM.Component WHERE ApplicationID = APM.ApplicationID AND Disabled = 'false') AS ComponentCount
                                        FROM Orion.Nodes AS N
                                        LEFT JOIN Orion.APM.Application AS APM ON APM.NodeID = N.NodeID
                                        LEFT JOIN Orion.Engines AS EN ON EN.EngineID = N.EngineID
                                        WHERE APM.Name IS NOT NULL
                                        ORDER BY N.EngineID"

#Export query to desired loction with a time stamp to keep seperate
$getDetailedNode | export-csv "C:\Scripts\Automation\logs\Node checks.csv $timestamp.csv"
Write-Host "Poller checks complete, this has been exported to C:\Scripts\Automation\logs\Node checks.csv $timestamp.csv"
