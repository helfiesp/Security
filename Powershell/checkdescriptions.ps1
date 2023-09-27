# Define a filter to find users with specific criteria
$UserFilter = {enabled -eq 'True'}
$Users = Get-ADUser -Filter $UserFilter -Properties SamAccountName | Sort | Select -ExpandProperty SamAccountName

foreach ($User in $Users) {
    # Fetch required properties for the user
    $Description = (Get-Aduser $User -Properties Description).Description
    $Name = (Get-Aduser $User -Properties DisplayName).DisplayName

    if ($Description -and ($Description.ToLower() -like "*pass*") -and ($Description.ToLower() -notlike "*kompass*")) {
        Write-Host "$User,$Name,$Description"
    }
}
