param(
    [Parameter(Mandatory = $true)]
    [string[]]
    $ip,
    [Parameter(Mandatory = $true)]
    [int]
    $port,
    [Parameter(Mandatory = $true)]
    [string]
    $webPath,
    [Parameter(Mandatory = $true)]
    [string]
    $artPath,
    [Parameter(Mandatory = $true)]
    [string]
    $pool,
    [Parameter(Mandatory = $true)]
    [string]
    $site,
    [Parameter(Mandatory = $true)]
    [string]
    $user,
    [Parameter(Mandatory = $true)]
    [string]
    $pas)

    function StartDeploySite {
        $password = convertto-securestring -AsPlainText -Force -String $pas;
        $credential = new-object -typename System.Management.Automation.PSCredential -argumentlist $user, $password;
        $session = New-PSSession -ComputerName $ip -Port $port -Credential $credential;
    
        try {
            if (Invoke-Command -ScriptBlock { Test-Path -Path $using:webPath;} -Session $session) {
                Write-Host "Folder is enable";
                DeploySite;
            }
            else {
                Write-Host "Folder is not enabled";
                Invoke-Command -ScriptBlock {New-Item -ItemType Directory -Path $using:webPath; } -Session $session;
                DeploySite;
            }
        }
        catch {
            $ErrorMessage = $_.Exception.Message;
            Write-Error $ErrorMessage;
        }
    
    }
    function DeploySite {
        Write-Host "Start deploy files";
        Invoke-Command -ScriptBlock {
            Stop-Website -Name $using:site;
            Stop-WebAppPool -Name $using:pool;
            Write-Host "Website ${$using:site} is stopped";
            Remove-Item -Path $using:webPath -Recurse;
            Write-Host "Starting deploing artefacts";
        } -Session $session;
        Copy-Item -Path $artPath -Destination $webPath -ToSession $session;
        Invoke-Command -ScriptBlock {
            Start-Website -Name $using:site;
            Start-WebAppPool -Name $using:pool;
        } -Session $session;
        Write-Host "Website ${$using:site} is working now";
    }

    StartDeploySite;