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
        [Password(StripValue = $true)]$ApiKey
    )
    Write-Host "Initializing Agent Smith"
    $IntegrationContext.SmithApiKey = $ApiKey
    $IntegrationContext.SmithHealthWebhook = $HealthWebhook
    $IntegrationContext.SmithOrgWebhook = $OrgWebhook

    [OpResult]::Ok() 
} -HealthCheck { 
    Import-Module AgentSmithAPI
    Get-SmithAPIHealth
}

$Integration | Add-DynamicIntegrationCapability -Interface ISupportsListingClients -GetClients {
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

$Integration
