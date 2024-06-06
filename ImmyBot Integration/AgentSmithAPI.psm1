function Get-SmithOrgID {
    try {
        $headers = @{
            'x-rewst-secret' = $IntegrationContext.SmithApiKey
        }
        $Orgs = Invoke-RestMethod -Uri $IntegrationContext.SmithOrgWebhook -Method Get -Headers $headers
        if ($Orgs.Response) {
            return $Orgs.Response
        } else {
            Write-Error "Response was null."
        }
    } catch {
        Write-Error "Error occurred while Getting Orgs: $_"
    }
}

function Get-SmithAgent {

}

function Invoke-SmithCommand {

}

function Get-SmithAPIHealth {
    try {
        $headers = @{
            'x-rewst-secret' = $IntegrationContext.SmithApiKey
        }
        $response = Invoke-RestMethod -Uri $IntegrationContext.SmithHealthWebhook -Method Get -Headers $headers
        if ($response -match 'healthy') {
            return New-HealthyResult
        } else {
            return New-UnhealthyResult -Message "Error occurred while checking API health: $response"
        }
    } catch {
        Write-Error "Error occurred while checking API health: $_"
        New-UnhealthyResult -Message "Error occurred while checking API health: $_"
    }
}

Export-ModuleMember -Function @(
    'Get-SmithOrgID',
    'Get-SmithAgent',
    'Invoke-SmithCommand',
    'Get-SmithAPIHealth'
)
