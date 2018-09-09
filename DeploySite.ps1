$password = convertto-securestring -AsPlainText -Force -String $pasw;
$credential = new-object -typename System.Management.Automation.PSCredential -argumentlist $user $password;
$session = New-PSSession -ComputerName $ip -port $port -Credential $credential;
$websitePath = $webPath;
$artefactPath = $artPath;
$webSitePool = $pool;
$websiteName = $site;

function DeploySite {
    Write "Start deploy files";
    Invoke-Command -ScriptBlock {
        Stop-WebAppPool -Name $using:webSitePool;
        Stop-Website -Name $using:websiteName;
        Write "Website ${$using:websiteName} is stopped";
        Remove-Item -Path $using:websitePath -Recurse;
        Write "Starting deploing artefacts";
    } -Session $session;
    Copy-Item -Path $artefactPath -Destination $websitePath -ToSession $session;
    Invoke-Command -ScriptBlock {
        Start-Website -Name $using:websiteName;
        Start-WebAppPool -Name $using:webSitePool;
    } -Session $session;
    Write "Website ${$using:websiteName} is working now";
}

try {
    if (Invoke-Command -ScriptBlock { Test-Path -Path $using:websitePath} -Session $session) {
        Write "Folder is enable";
        DeploySite;
    }
    else {
        Write "Folder is not enabled";
        Invoke-Command -ScriptBlock {New-Item -ItemType Directory -Path ${$using:websitePath;} } -Session $session;
        DeploySite;
    }
}
catch {
    $ErrorMessage = $_.Exception.Message;
    Write-Error -Message $ErrorMessage;
}