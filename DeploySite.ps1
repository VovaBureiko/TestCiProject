param(
    [Parameter(Mandatory = $true)]
    [string]
    $ip,
    [Parameter(Mandatory = $true)]
    [string]
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
    $pasw)

    function StartDeploySite {
        $password = convertto-securestring -AsPlainText -Force -String $pasw;
        $credential = new-object -typename System.Management.Automation.PSCredential -argumentlist $user $password;
        $session = New-PSSession -ComputerName $ip -port $port -Credential $credential;
    
        try {
            if (Invoke-Command -ScriptBlock { Test-Path -Path $using:webPath} -Session $session) {
                Write "Folder is enable";
                DeploySite;
            }
            else {
                Write "Folder is not enabled";
                Invoke-Command -ScriptBlock {New-Item -ItemType Directory -Path ${$using:webPath;} } -Session $session;
                DeploySite;
            }
        }
        catch {
            $ErrorMessage = $_.Exception.Message;
        }
    
    }
    function DeploySite {
        Write "Start deploy files";
        Invoke-Command -ScriptBlock {
            Stop-WebAppPool -Name $using:pool;
            Stop-Website -Name $using:site;
            Write "Website ${$using:site} is stopped";
            Remove-Item -Path $using:webPath; -Recurse;
            Write "Starting deploing artefacts";
        } -Session $session;
        Copy-Item -Path $artPath -Destination $webPath; -ToSession $session;
        Invoke-Command -ScriptBlock {
            Start-Website -Name $using:site;
            Start-WebAppPool -Name $using:pool;
        } -Session $session;
        Write "Website ${$using:site} is working now";
    }

    StartDeploySite;