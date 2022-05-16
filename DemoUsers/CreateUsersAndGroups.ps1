param(
  [int]$TestRun,
  [int]$Users,
  [switch]$Simulate
)

Import-Module ./DemoUsers

# Credentials for TESTDOM1
$Dom1Server = "10.0.1.101"
$Dom1Username = "TESTDOM1\Administrator"
$Dom1Password = "Kelvin2020!" | ConvertTo-SecureString -asPlainText -Force
$Dom1Credentials = New-Object System.Management.Automation.PSCredential($Dom1Username, $Dom1Password)

# Credentials for TESTDOM2
$Dom2Server = "10.0.1.102"
$Dom2Username = "TESTDOM2\Administrator"
$Dom2Password = "Kelvin2020!" | ConvertTo-SecureString -asPlainText -Force
$Dom2Credentials = New-Object System.Management.Automation.PSCredential($Dom2Username, $Dom2Password)

# Credentials for TESTDOM3
$Dom3Server = "10.0.1.103"
$Dom3Username = "TESTDOM3\Administrator"
$Dom3Password = "Kelvin2020!" | ConvertTo-SecureString -asPlainText -Force
$Dom3Credentials = New-Object System.Management.Automation.PSCredential($Dom3Username, $Dom3Password)

$NewUserPassword = "Password1"
$FirstNames = ($(. .\MarkovWords.ps1)) | Sort-Object { Get-Random }
$LastNames = ($(. .\MarkovWords.ps1)) | Sort-Object { Get-Random }

$ConflictingUsers = @(
  [PSCustomObject]@{
    FirstName = "Adam"
    LastName  = "Savage"
  }
  [PSCustomObject]@{
    FirstName = "Keanu"
    LastName  = "Reeves"
  }
  [PSCustomObject]@{
    FirstName = "Johnny"
    LastName  = "Depp"
  }
)

switch ($TestRun) {
  1 {
    Write-Host "Test Run #1 - TESTDOM1 -> TESTDOM3"
    try {
      Write-Host "Adding Test OU for users" -NoNewline
      New-ADOrganizationalUnit `
        -Name "Test" `
        -Path "DC=TESTDOM1,DC=local" `
        -Credential $Dom1Credentials `
        -Server $Dom1Server `
        -ErrorAction SilentlyContinue `
        -ErrorVariable err
      Write-Host " - Added!"
    }
    catch {
      Write-Host " - Already exists!"
    }
    Write-RandomADUsers `
      -Simulate $Simulate `
      -Credential $Dom1Credentials `
      -Server $Dom1Server `
      -NumberOfUsers ($Users - $($ConflictingUsers.Count)) `
      -Path "OU=Test,DC=TESTDOM1,DC=local" `
      -NewPassword "Password1" `
      -FirstName $FirstNames `
      -LastNames $LastNames
    $ConflictingUsers | ForEach-Object {
      Write-Host "Adding specified conflicting user" -NoNewline
      $samAccountName = $_.FirstName.Substring(0, 1) + $_.LastName
      $password = ConvertTo-SecureString $NewUserPassword -AsPlainText -Force
      $name = $_.FirstName + " " + $_.LastName
      $description = $NewUserPassword
      New-ADUser -Credential $Dom1Credentials -Server $Dom1Server `
        -SamAccountName $samAccountName `
        -Name $name `
        -GivenName $fname `
        -Surname $lname `
        -AccountPassword $password `
        -Description $description `
        -Path "OU=Test,DC=TESTDOM1,DC=local" `
        -Enabled $true `
        -ErrorAction SilentlyContinue `
        -ErrorVariable err
      Write-Host " - Added!"
    }
    Break
  }
  2 {
    Write-Host "Test Run #2 - TESTDOM1+TESTDOM2 -> TESTDOM3"
    try {
      Write-Host "Adding Test OU for users" -NoNewline
      New-ADOrganizationalUnit `
        -Name "Test" `
        -Path "DC=TESTDOM1,DC=local" `
        -Credential $Dom1Credentials `
        -Server $Dom1Server `
        -ErrorAction SilentlyContinue `
        -ErrorVariable err
      Write-Host " - Added!"
    }
    catch {
      Write-Host " - Already exists!"
    }
    try {
      Write-Host "Adding Test OU for users" -NoNewline
      New-ADOrganizationalUnit `
        -Name "Test" `
        -Path "DC=TESTDOM2,DC=local" `
        -Credential $Dom2Credentials `
        -Server $Dom2Server `
        -ErrorAction SilentlyContinue `
        -ErrorVariable err
      Write-Host " - Added!"
    }
    catch {
      Write-Host " - Already exists!"
    }
    Write-RandomADUsers `
      -Simulate $Simulate `
      -Credential $Dom1Credentials `
      -Server $Dom1Server `
      -NumberOfUsers ($Users - $($ConflictingUsers.Count)) `
      -Path "OU=Test,DC=TESTDOM1,DC=local" `
      -NewPassword "Password1" `
      -FirstName $FirstNames `
      -LastNames $LastNames
    Write-RandomADUsers `
      -Simulate $Simulate `
      -Credential $Dom2Credentials `
      -Server $Dom2Server `
      -NumberOfUsers ($Users - $($ConflictingUsers.Count)) `
      -Path "OU=Test,DC=TESTDOM2,DC=local" `
      -NewPassword "Password1" `
      -FirstName $FirstNames `
      -LastNames $LastNames
    Break
  }
  3 {
    Write-Host "Test Run #3 - TESTDOM1+TESTDOM2 -> TESTDOM3 - With Target data"
    try {
      Write-Host "Adding Test OU for users" -NoNewline
      New-ADOrganizationalUnit `
        -Name "Test" `
        -Path "DC=TESTDOM1,DC=local" `
        -Credential $Dom1Credentials `
        -Server $Dom1Server `
        -ErrorAction SilentlyContinue `
        -ErrorVariable err
      Write-Host " - Added!"
    }
    catch {
      Write-Host " - Already exists!"
    }
    try {
      Write-Host "Adding Test OU for users" -NoNewline
      New-ADOrganizationalUnit `
        -Name "Test" `
        -Path "DC=TESTDOM2,DC=local" `
        -Credential $Dom2Credentials `
        -Server $Dom2Server `
        -ErrorAction SilentlyContinue `
        -ErrorVariable err
      Write-Host " - Added!"
    }
    catch {
      Write-Host " - Already exists!"
    }
    try {
      Write-Host "Adding Test OU for users" -NoNewline
      New-ADOrganizationalUnit `
        -Name "Test" `
        -Path "DC=TESTDOM3,DC=local" `
        -Credential $Dom3Credentials `
        -Server $Dom3Server `
        -ErrorAction SilentlyContinue `
        -ErrorVariable err
      Write-Host " - Added!"
    }
    catch {
      Write-Host " - Already exists!"
    }
    Write-RandomADUsers `
      -Simulate $Simulate `
      -Credential $Dom1Credentials `
      -Server $Dom1Server `
      -NumberOfUsers ($Users - $($ConflictingUsers.Count)) `
      -Path "OU=Test,DC=TESTDOM1,DC=local" `
      -NewPassword "Password1" `
      -FirstName $FirstNames `
      -LastNames $LastNames
    Write-RandomADUsers `
      -Simulate $Simulate `
      -Credential $Dom2Credentials `
      -Server $Dom2Server `
      -NumberOfUsers ($Users - $($ConflictingUsers.Count)) `
      -Path "OU=Test,DC=TESTDOM2,DC=local" `
      -NewPassword "Password1" `
      -FirstName $FirstNames `
      -LastNames $LastNames
    Write-RandomADUsers `
      -Simulate $Simulate `
      -Credential $Dom3Credentials `
      -Server $Dom3Server `
      -NumberOfUsers ($Users - $($ConflictingUsers.Count)) `
      -Path "OU=Test,DC=TESTDOM3,DC=local" `
      -NewPassword "Password1" `
      -FirstName $FirstNames `
      -LastNames $LastNames
    Break
  }
  default {
    Write-Warning "No testrun defined!"
  }
}
Write-Host "Completed!"
Remove-Module DemoUsers
