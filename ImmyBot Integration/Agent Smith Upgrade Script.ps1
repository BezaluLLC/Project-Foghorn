$Uninstaller = "C:\Program Files\RewstRemoteAgent\7b4d5183-b1f5-4aa5-9ee9-8fd486e05287\rewst_service_manager.win.exe"
$Arguments = @"
--uninstall --org-id $Rewst_Org_Id
"@
$LogFile = New-TempLogFile
Try {
    $process = Start-ProcessWithLogTail $Uninstaller -ArgumentList $Arguments -LogFilePath $LogFile
}
Catch {
    Throw "The Service Manager was not found."
}
If ( $Process.ExitCode -ne 0 ){
    Throw "The uninstall failed."
}
Try {
    Invoke-ImmyCommand -ScriptBlock {
        rm -r -fo "C:\Program Files*\RewstRemoteAgent"
    }
    Write-Host "Leftover goodies removed"

}
Catch{
        Write-Host "No leftover goodies discovered"
}

$LogFile = "C:\ProgramData\RewstRemoteAgent\$Rewst_Org_Id\logs\rewst_agent.log"
$Arguments = "--config-url $Rewst_Webhook --config-secret $Rewst_Secret --org-id $Rewst_Org_Id"
Start-ProcessWithLogTail $InstallerFile -ArgumentList $Arguments -LogFilePath $LogFile
