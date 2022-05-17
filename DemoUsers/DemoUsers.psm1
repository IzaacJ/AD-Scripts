function Write-RandomADUsers {
  <#
    .SYNOPSIS
            This function provisions random AD users.
    .DESCRIPTION
            This function uses Get-Random and New-ADUser to provision users with random names.

            Modified by Izaac Brånn.
    .PARAMETER  NumberOfUsers
            The number of users to provision.
    .PARAMETER  Path
            The Active Directory OU to store the users.
    .PARAMETER NewPassword
            The password to set on new users.
            Added by Izaac Brånn
    .PARAMETER Credential
            Pass credentials that will be used to communicate with the Active Directory.
            Added by Izaac Brånn
    .PARAMETER Server
            IP-address or FQDN for the Active Directory domain.
            Added by Izaac Brånn
    .PARAMETER Simulate
            Simulate the addition without actually connecting to the Active Directory.
            Added by Izaac Brånn
    .PARAMETER RandomAttribute
            Name of an attribute that randomly will have a value.
            Added by Izaac Brånn
    .PARAMETER RandomAttributeValue
            The value to put in the RandomAttribute.
            Added by Izaac Brånn
    .EXAMPLE
            PS C:\>Write-RandomADUsers -NumberOfUsers 50 -Path "OU=Demo Users,DC=contoso,DC=com"
    .LINK
            www.sharepointryan.com
            http://twitter.com/sharepointryan
    #>
  Param(
    [int]$NumberOfUsers,
    $Path,
    [string]$NewPassword,
    [System.Management.Automation.PSCredential]$Credential,
    [string]$Server,
    [bool]$Simulate,
    [string]$RandomAttribute = "none",
    $RandomAttributeValue = $null,
    [string[]]$FirstNames,
    [string[]]$LastNames
  )
  #import the AD module
  Import-Module ActiveDirectory -ErrorAction SilentlyContinue
  #top first names and last names of 2011
  #$FirstNames = "Jacob", "Isabella", "Ethan", "Sophia", "Michael", "Emma", "Jayden", "Olivia", "William", "Ava", "Alexander", "Emily", "Noah", "Abigail", "Daniel", "Madison", "Aiden", "Chloe", "Anthony", "Mia", "Ryan", "Gregory", "Kyle", "Deron", "Josey", "Joseph", "Kevin", "Robert", "Michelle", "Mandi", "Amanda", "Ella"
  #$LastNames = "Smith", "Johnson", "Williams", "Jones", "Brown", "Davis", "Miller", "Wilson", "Moore", "Taylor", "Anderson", "Thomas", "Jackson", "White", "Harris", "Martin", "Thompson", "Garcia", "Martinez", "Robinson", "Clark", "Rodriguez", "Lewis", "Lee", "Dennis"

  #get current error preferences
  $currentErrorPref = $ErrorActionPreference
  #set error preferences to silentlycontinue
  $ErrorActionPreference = "SilentlyContinue"

  $CreatedUsers = New-Object System.Collections.ArrayList # Stores new users when simulating. // Izaac Brånn
  #start at 1
  $i = 1
  #tell us what it's doing
  Write-Host (& { if ($Simulate) { "[SIMULATING]" } }) "Creating $($NumberOfUsers) users..." # Added a tag when simulating. // Izaac Brånn
  #run until the number of accounts provided via the numberofusers param are created
  do {
    $fname = $FirstNames | Sort-Object { Get-Random } | Get-Random
    $lname = $LastNames | Sort-Object { Get-Random } | Get-Random
    $samAccountName = $fname.Substring(0, 1) + $lname
    $password = ConvertTo-SecureString $NewPassword -AsPlainText -Force # Replaced the string p@ssword with $NewPassword. // Izaac Brånn
    $name = $fname + " " + $lname
    $description = $NewPassword # Replaced $password with $NewPassword. // Izaac Brånn
    $RNDActiveValue = " ", "  ", "$RandomAttributeValue" | Get-Random

    # Stores the user when simulating. // Izaac Brånn
    $err = $null
    if ($Simulate) {
      $User = @{
        "First Name"  = $fname
        "Last Name"   = $lname
        "SAMAccount"  = $samAccountName
        "Password"    = $password
        "Description" = "$description $RNDActiveValue"
      }
      if ($RandomAttribute -ne "none") {
        $User.Add($RandomAttribute, $RNDActiveValue)
      }
      $CreatedUsers += $User
    }
    else {
      # Added check for credentials and server address and added appropriate commands. // Izaac Brånn
      if ($null -eq $Credential) {
        Write-Host "[$i]`tUsing computers domain and credentials" -NoNewline
        New-ADUser `
          -SamAccountName $samAccountName `
          -Name $name `
          -GivenName $fname `
          -Surname $lname `
          -AccountPassword $password `
          -Description $description `
          -Path $path `
          -Enabled $true `
          -ErrorAction SilentlyContinue `
          -ErrorVariable err
      }
      else {
        Write-Host "[$i]`tUsing credentials" -NoNewline
        if ($null -eq $Server) {
          Write-Host " and computers domain" -NoNewline
          New-ADUser `
            -Credential $Credential `
            -SamAccountName $samAccountName `
            -Name $name `
            -GivenName $fname `
            -Surname $lname `
            -AccountPassword $password `
            -Description $description `
            -Path $path `
            -Enabled $true `
            -ErrorAction SilentlyContinue `
            -ErrorVariable err
        }
        else {
          Write-Host " and server" -NoNewline
          New-ADUser `
            -Credential $Credential `
            -Server $Server `
            -SamAccountName $samAccountName `
            -Name $name `
            -GivenName $fname `
            -Surname $lname `
            -AccountPassword $password `
            -Description $description `
            -Path $path `
            -Enabled $true `
            -ErrorAction SilentlyContinue `
            -ErrorVariable err
        }
      }
      if ($err.Count -eq 0) {
        Write-Host " - Added!"
      }
      elseif ($err -match "already in use") {
        Write-Host "Duplicate. Redoing."
        $i--
        $err = ""
      }
      else {
        Write-Host " - Failed!"
        Write-Host $err
        Break
      }
    }
    $i++
  }
  #run until numberofusers are created
  while ($i -le $NumberOfUsers)

  # Output the stored users when simulating. // Izaac Brånn
  if ($Simulate) {
    $CreatedUsers.ForEach({ [PSCustomObject]$_ }) | Format-Table "First Name", "Last Name", SAMAccount, Description, Password, $RandomAttribute
  }
  #set erroractionprefs back to what they were
  $ErrorActionPreference = $currentErrorPref
}