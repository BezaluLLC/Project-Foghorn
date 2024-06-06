############################
# Author: Logan@bezalu.com #
############################

$Integration = New-DynamicIntegration -Init {
    param(
        [Parameter(Mandatory)]
        [String]$OrgWebhook,
        [Parameter(Mandatory)]
        [String]$HealthWebhook,
        [Parameter(Mandatory)]
        [String]$AgentsWebhook,
        [Parameter(Mandatory)]
        [String]$CommandWebhook,
        [Parameter(Mandatory)]
        [Password(StripValue = $true)]$ApiKey
    )
    Write-Host "Initializing Agent Smith"
    $IntegrationContext.SmithApiKey = $ApiKey
    $IntegrationContext.SmithHealthWebhook = $HealthWebhook
    $IntegrationContext.SmithOrgWebhook = $OrgWebhook
    $IntegrationContext.SmithAgentWebhook = $AgentsWebhook
    $IntegrationContext.SmithCommandWebhook = $CommandWebhook

    [OpResult]::Ok() 
} -HealthCheck { 
    Import-Module AgentSmithAPI
    Get-SmithAPIHealth
}


$Integration | Add-DynamicIntegrationCapability -Interface ISupportsListingClients -GetClients {
    [ScriptTimeout(TimeoutSeconds = 300)]
    [CmdletBinding()]
    [OutputType([IProviderClientDetails[]])]
    param() 
    try{
        Import-Module AgentSmithAPI
        $Orgs = Get-SmithOrgID
        $Orgs | ForEach-Object {
            if ($_.OrgId -and $_.OrgName) {
                New-IntegrationClient -ClientId $_.OrgId -ClientName $_.OrgName
            } else {
                Write-Error "Not enough data for $_"
            }
        }
    }
    catch{
        $_ | Out-String | Write-Host
    }
}

$Integration | Add-DynamicIntegrationCapability -Interface ISupportsListingAgents -GetAgents {
    [CmdletBinding()]
    [OutputType([IProviderAgentDetails[]])]
    param(
        [Parameter(Mandatory)]
        [string[]]$clientIds
    )
    Import-Module AgentSmithAPI

    $currentTime = Get-Date

    Get-SmithAgent | % {
        $timestampDateTime = [DateTime]::Parse($_.Timestamp)
        $timeDifference = $currentTime - $timestampDateTime
        $online = ($timeDifference.TotalMinutes -le 5)

        New-IntegrationAgent `
            -Name $_.hostname `
            -OSName $_.license_type `
            -ClientId $_.org_id `
            -AgentId $_.device_id `
            -IsOnline $online `
            -SupportsRunningScripts $true
    }
}


$Integration | Add-DynamicIntegrationCapability -Interface ISupportsInventoryIdentification -GetInventoryScript {
    [CmdletBinding()]
    [OutputType([scriptblock])]
    param(
       
    )
    Invoke-ImmyCommand {
        # implement a script block that should retrieve the agent identifier for this integration.
        Get-Content "C:\ProgramData\RewstRemoteAgent\*\config.json" | ConvertFrom-Json | % {$_.device_id}
    }
}

$Integration | Add-DynamicIntegrationCapability -Interface IRunScriptProvider -RunScript {
    param(
        [Parameter(Mandatory)]
        [IProviderAgentDetails]$agent,
        [Parameter(Mandatory)]
        [string]$scriptCode,
        [Parameter(Mandatory)]
        [int]$timeout
    )
    Import-Module AgentSmithAPI
    Invoke-SmithCommand
} -get_DefaultTimeout { 600 }


$Integration
