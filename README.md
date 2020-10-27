Refresh Azure Automation Source Control AutoSync webhooks
=========================================================

            

This sample automation runbook resets the auto sync webhook for configured source controls in the automation account. It is designed to be run on a schedule every few months as the webhooks configured by the source control service will expire after 12 months.


It will enumerate all configured source controls that have AutoSync enabled and then disable / enable them to get a new webhook created.


**Note:**


It requires Az.Accounts, Az.Resources and Az.Automation modules be imported into the automation account.


 




 




        
    
TechNet gallery is retiring! This script was migrated from TechNet script center to GitHub by Microsoft Azure Automation product group. All the Script Center fields like Rating, RatingCount and DownloadCount have been carried over to Github as-is for the migrated scripts only. Note : The Script Center fields will not be applicable for the new repositories created in Github & hence those fields will not show up for new Github repositories.
