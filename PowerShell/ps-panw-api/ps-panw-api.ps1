param (
    [Parameter(Mandatory=$True)]
    [String] $Hostname
)

# Pause function
function Invoke-Pause() {
    Write-Host -NoNewLine 'Press any key to continue...';
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
}

# Function to generate and return API key
function Get-APIKey($credObject) {
    $User = $credObject.GetNetworkCredential().UserName
    $Pass = $credObject.GetNetworkCredential().Password
    $URL = "https://$Hostname/api/?type=keygen&user=$User&password=$Pass"
    $User = ""
    $Pass = ""
    [XML]$api_key = Invoke-WebRequest -SkipCertificateCheck -Uri $URL
    return $api_key.response.result.key
}

function Get-MenuChoice() {
    do {
        # Display menu
        write-host "PANW Powershell Firewall Manager"
        write-host "Written by Josh Levine (SE-DOD1 - Army/USSOCOM/SOF)"
        write-host "---------------------------------------------------"
        write-host "Main Menu (Please select category)`n`n"
        write-host "1. Generate API Key"
        write-host "2. Operational Commands"
        write-host "3. Configuration Commands"
        write-host "4. Reporting Commands"
        write-host "5. Logging Commands"
        write-host "6. Import/Export Commands"
        write-host "7. Generate Tech-Support File (TSF)"
        write-host "8. COMMIT Configuration"
        write-host "9. Version Information`n`n"
        write-host "0. Exit Script"
        $selection = Read-Host "Enter your selection: "
    
        switch($selection) {
            "1" {
                write-host "Generating API Key"
                $key = Get-APIKey($Credential)
                write-host $key
                Invoke-Pause
            }
            "2" {
                write-host "`nImplementation Pending"
                Invoke-Pause
            }
            "3" {
                write-host "`nImplementation Pending"
                Invoke-Pause
            }
            "4" {
                write-host "`nImplementation Pending"
                Invoke-Pause
            }
            "5" {
                write-host "`nImplementation Pending"
                Invoke-Pause
            }
            "6" {
                write-host "`nImplementation Pending"
                Invoke-Pause
            }
            "7" {
                write-host "`nGenerating a TSF file requires superuser permissions"
                $admin_creds = Get-Credential -Message "Please enter details for superuser account: "
                write-host "Generating superuser API Key"
                $admin_key = Get-APIKey($admin_creds)
                $URL = "https://$hostname/api/?type=export&category=tech-support&key=$admin_key"
                write-host "Generating TSF - Please stand by"
                [XML]$tsf_gen_results = Invoke-WebRequest -Uri $URL -SkipCertificateCheck
                write-host $tsf_gen_results
                Invoke-Pause
                if ($tsf_gen_results.response.status -eq "success") {
                    write-host "TSF generated successfully"
                    Invoke-Pause
                }
            }
            "8" {
                write-host "`nImplementation Pending"
                Invoke-Pause
            }
            "9" {
                write-host "`nImplementation Pending"
                Invoke-Pause
            }
        }
    } While ($selection -ne 0)
}

# Read XML API Administrator account info
$Credential = Get-Credential -Message "Enter username and password for administrator with XML API permissions: "
Get-MenuChoice
