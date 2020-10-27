<#
.SYNOPSIS 
    This sample automation runbook resets the auto sync webhook for configured source controls in the automation account.
    It is designed to be run on a schedule every few months as the webhooks configured by the source control service will expire after 12 months.

.DESCRIPTION
    This sample automation runbook resets the auto sync webhook for configured source controls in the automation account.
    It is designed to be run on a schedule every few months as the webhooks configured by the source control service will expire after 12 months.
    
    It will enumerate all configured source controls that have AutoSync enabled and then disable / enable them to get a new webhook created.

    It requires Az.Accounts, Az.Resources and Az.Automation modules be imported into the automation account.

.Example
    .\Refresh-SourceControlAutoSyncWebhook

.NOTES
    AUTHOR: Eamon O'Reilly
    LASTEDIT: July 9th 2019
#>
Param
() 

$ErrorActionPreference = 'stop'

# Get RunAsConnection
$RunAsConnection = Get-AutomationConnection -Name "AzureRunAsConnection"

# Authenticate to Azure resources to find resource group and account name
Connect-AzAccount `
    -ServicePrincipal `
    -TenantId $RunAsConnection.TenantId `
    -ApplicationId $RunAsConnection.ApplicationId `
    -CertificateThumbprint $RunAsConnection.CertificateThumbprint | Write-Verbose

$Context = Set-AzContext -SubscriptionId $RunAsConnection.SubscriptionID  | Write-Verbose 

# Find out the resource group and account name
$AutomationResource = Get-AzResource -ResourceType Microsoft.Automation/AutomationAccounts -AzContext $Context
foreach ($Automation in $AutomationResource)
{
    $Job = Get-AzAutomationJob -ResourceGroupName $Automation.ResourceGroupName -AutomationAccountName $Automation.Name `
                                    -Id $PSPrivateMetadata.JobId.Guid -AzContext $Context -ErrorAction SilentlyContinue
    if (!([string]::IsNullOrEmpty($Job)))
    {
        $AutomationResourceGroup = $Job.ResourceGroupName
        $AutomationAccount = $Job.AutomationAccountName
        break;
    }
} 

# Get the list of configured source control objects that have AutoSync enabled
$SCAutoSync = Get-AzAutomationSourceControl -ResourceGroupName $AutomationResourceGroup `
                                            -AutomationAccountName $AutomationAccount -AzContext $Context | where {$_.AutoSync -eq $True}

# Disable and then enable AutoSync on configured source control objects to create a new webhook.
foreach ($SC in $SCAutoSync)
{
    Write-Output "Refreshing webhook for $($SC.Name)"
    Update-AzAutomationSourceControl -ResourceGroupName $SC.ResourceGroupName -AutomationAccountName $SC.AutomationAccountName `
                                     -Name $SC.Name -AutoSync $False -AzContext $Context | Write-Verbose

    Update-AzAutomationSourceControl -ResourceGroupName $SC.ResourceGroupName -AutomationAccountName $SC.AutomationAccountName `
                                     -Name $SC.Name -AutoSync $True -AzContext $Context | Write-Verbose
}

