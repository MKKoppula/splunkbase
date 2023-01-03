# emr_install_uf.ps1 - install Splunk Univeral forwarder script.

Param(
    [string]$HostFile
)

if (!$HostFile) {
    Write-Host '[*] Install Splunk Universal Forwarder on localhost'
    $params = @{deployment_server=$env:SPLUNK_DEPLOYMENT_URL;splunk_home=$env:SPLUNK_HOME;management_port=$env:MANAGEMENT_PORT}
	& ".\emr_install_uf_script.ps1" @params
} else {
    # if $HostFile is not specified, then
    if (!(Test-Path $HostFile)) {
        echo "file: $HostFile does not exist"
        exit(0)
    }

    # read host list from $HostFile
    [array]$host_list = Get-Content $HostFile

    # remote execute the installation script
    foreach ($h in $host_list) {
        Write-Host '[*] Install Splunk Universal Forwarder remotely on' $h
        Invoke-Command -FilePath emr_install_uf_script.ps1 -ArgumentList $env:SPLUNK_DEPLOYMENT_URL,$env:SPLUNK_HOME,$env:MANAGEMENT_PORT -ComputerName $h

        Write-Host '[*] ----------------------------------------'
    }
}
