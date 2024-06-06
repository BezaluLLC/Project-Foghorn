############################
# Author: Logan@bezalu.com #
############################

$LogFile = "C:\ProgramData\RewstRemoteAgent\$Rewst_Org_Id\logs\rewst_agent.log"
$Arguments = "--config-url $Rewst_Webhook --config-secret $Rewst_Secret --org-id $Rewst_Org_Id"
Start-ProcessWithLogTail $InstallerFile -ArgumentList $Arguments -LogFilePath $LogFile
