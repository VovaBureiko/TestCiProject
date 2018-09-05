$password = convertto-securestring -AsPlainText -Force -String "1234QazWsxEdc";
$credential = new-object -typename System.Management.Automation.PSCredential -argumentlist "upingskills",$password;
$session = New-PSSession -ComputerName 40.87.135.119 -port 5985 -Credential @credential;
$websitePath = 'C:\TestCISite\';
$artefactPath = 'C:\TeamCity\buildAgent\work\e55ca005f8c3e807\publish\*';
$webSitePool = 'DefaultAppPool';
$websiteName = 'TestCISyte';


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

function DeploySite {
    Write-Information -Message "Start deploy files";
    Invoke-Command -ScriptBlock {
        Stop-Website -Name $using:websiteName;
        Stop-WebAppPool -Name $using:webSitePool;
        Write-Information -Message "Website ${$using:websiteName} is stopped";
        Remove-Item -Path $using:websitePath -Recurse;
                                } -Session $session;
    Write-Information -Message "Starting deploing artefacts";
    Copy-Item -Path $artefactPath -Destination $websitePath -ToSession $session;
    Write-Information -Message "Starting are deployed";
    Invoke-Command -ScriptBlock {
        Start-Website -Name $using:websiteName;
        Start-WebAppPool -Name $using:webSitePool;
    } -Session $session;
    Write-Information -Message "Website ${$using:websiteName} is working now";
}