param (
    [Parameter(Mandatory=$True)]
    [String] $Hostname
)

# Pause function
function Invoke-Pause() {
    Write-Host -NoNewLine 'Press any key to continue...';
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
}

function Invoke-CLICommand() {
    $command = Read-Host "Enter CLI command to execute: "
    $fw_url = "https://$hostname/api/?type=op&cmd="
    
    # Split the command string into individual tags
    foreach($item in $command.Split(" ")) {
        $fw_url += "<" + $item + ">"
    }
    
    # Reverse the order of the command string to terminate the individual command tags
    $reverse_command = @($command.split(" "))
    [array]::reverse($reverse_command)
    foreach($item in $reverse_command) {
        $fw_url += "</" + $item + ">"
    }
    
    # Finish terminating the URL with the API Key
    $fw_url += "&key=$api_key"
    $XML_Response = Invoke-WebRequest -SkipCertificateCheck -Uri $fw_url
    
    # Invalid command
    if ($XML_Response -like "*error*") {
        write-host "Invalid command entered"
    }
    
    # Raw content response
    elseif ($XML_Response -like "*CDATA*") {
        write-host $XML_Response.Content
        Invoke-Pause
    }
    
    # Standard XML response
    else {
        # Convert raw Invoke-WebRequest response to XML for parsing by Get-XMLTree
        $XML_Response = [XML]$XML_Response
        Get-XMLTree($XML_Response)    
        Invoke-Pause
    }
}

function Get-XMLTree($xml) {
    $nodesWithText = $xml.SelectNodes("//*[text()]")
    $count = 0
    $response = "P"
    foreach($node in $nodesWithText) {
        #Start with end of path (element-name of the node with text-value)
        $path = $node.LocalName
        
        #Get parentnode
        $parentnode = $node.ParentNode

        #Loop until document-node (parent of root-node)
        while($parentnode.LocalName -ne '#document') {

            #Add LocalName (element-name) for parent to path
            $path = "$($parentnode.LocalName)\$path"

            #Go to next parent node
            $parentnode = $parentnode.ParentNode
        }

        #Output "path = text-value"
        $count += 1
        "$path = $(($node.'#text').Trim())"
        if ($count % 10 -eq 0 -and $response -ne "A") {
            $response = read-host "Pausing...Press (a) to display remaining output or any other key for next page"
            $response = $response.ToUpper()
        }
    }
}

# Function to generate and return API key
function Get-APIKey($cred) {
    write-host "Retrieving API key..."
    $User = $cred.GetNetworkCredential().UserName
    $Pass = $cred.GetNetworkCredential().Password
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
        write-host "8. Perform Firewall Commit"
        write-host "9. Version Information"
        write-host "10. Execute Manual Command`n"
        write-host "0. Exit Script"
        $selection = Read-Host "Enter your selection: "
    
        switch($selection) {
            "1" {
                write-host "Generating API Key"
                $user_credential = Get-Credential -Message "Enter username and password to get API credential for"
                $key = Get-APIKey($user_credential)
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
            "10" {
                Invoke-CLICommand
            }
        }
    } While ($selection -ne 0)
}

# Read XML API Administrator account info
$XML_Credential = Get-Credential -Message "Enter username and password for administrator with XML API permissions: "
try {$api_key = Get-APIKey($XML_Credential)}
catch { 
    "Invalid credential entered..."
    break
}
Get-MenuChoice
