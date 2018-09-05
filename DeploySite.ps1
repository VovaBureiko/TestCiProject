winrm set winrm/config/client '@{TrustedHosts="40.87.135.119"}'

$password = convertto-securestring -AsPlainText -Force -String "1234QazWsxEdc";
$credential = new-object -typename System.Management.Automation.PSCredential -argumentlist "Domain\upingskills", $password;
$session = New-PSSession -ComputerName 40.87.135.119 -port 5985 -Credential $credential;
$websitePath = 'C:\TestCISite\';
$artefactPath = 'C:\TeamCity\buildAgent\work\cfb7413927a8802c\publish\*';
$webSitePool = 'DefaultAppPool';
$websiteName = 'TestCISyte';

function DeploySite {
    Write-Information -Message "Start deploy files";
    Invoke-Command -ScriptBlock {
        Stop-Website -Name $using:websiteName;
        Stop-WebAppPool -Name $using:webSitePool;
        Write-Information -Message "Website ${$using:websiteName} is stopped";
        Remove-Item -Path $using:websitePath -Recurse;
        Write-Information -Message "Starting deploing artefacts";
    } -Session $session;
    Copy-Item -Path $artefactPath -Destination $websitePath -ToSession $session;
    Invoke-Command -ScriptBlock {
        Start-Website -Name $using:websiteName;
        Start-WebAppPool -Name $using:webSitePool;
    } -Session $session;
    Write-Information -Message "Website ${$using:websiteName} is working now";
}


try {
    if (Invoke-Command -ScriptBlock { Test-Path -Path $using:websitePath} -Session $session) {
        Write-Information -Message "Folder is enable";
        DeploySite;
    }
    else {
        Write-Information -Message "Folder is not enabled";
        Invoke-Command -ScriptBlock {New-Item -ItemType Directory -Path ${$using:websitePath;} } -Session $session;
        DeploySite;
    }
}
catch {
    $ErrorMessage = $_.Exception.Message;
    Write-Error -Message $ErrorMessage;
}