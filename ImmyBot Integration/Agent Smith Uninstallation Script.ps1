############################
# Author: Logan@bezalu.com #
############################

$Uninstaller = "C:\Program Files\RewstRemoteAgent\$Rewst_Org_Id\rewst_service_manager.win.exe"
$Arguments = @"
--uninstall --org-id $Rewst_Org_Id
"@
$LogFile = New-TempLogFile
Try {
    #TODO: Try: Get-Service rewst* | Remove-Service
    $Process = Start-ProcessWithLogTail $Uninstaller -ArgumentList $Arguments -LogFilePath $LogFile
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
        rm -r -fo "C:\ProgramData\RewstRemoteAgent"
    }
    Write-Host "Leftover goodies removed"
}
Catch{
        Write-Host "No leftover goodies discovered"
}
