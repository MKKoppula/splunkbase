# currently must be 'runas' administrator for proper install

Param(
    [string]$deployment_server,
    [string]$splunk_home,
    [string]$splunk_password,
    [string]$management_port
)

# if splunk_home not provided, use default
if([string]::IsNullOrEmpty($splunk_home)) {
  $splunk_home = "$env:programfiles\SplunkUniversalForwarder"
}

if([string]::IsNullOrEmpty($management_port)) {
  $management_port = '8089'
}

if([string]::IsNullOrEmpty($splunk_password)) {
    $splunk_password = '$6$TaBl3gVmN2TZoCu4$LgdPPRXkmvyGMzz59s.9zLPqnNhn1ptVswsAW3nelN6yE0tZVaQI4DKNFF6b2OT8QpBLBpkWOLE5UlVxQTgQs/'
  }

$splunk_version= $splunk_home + "\etc\splunk.version"
$splunk_old_password= $splunk_home + "\etc\passwd"
$splunk_backup_passwd=$splunk_home + "\etc\passwd.old"
$deploymentserver = $deployment_server+':'+$management_port
$hashedpasswd = $splunk_password

# URI to download the install file
$insturi = 'https://download.splunk.com/products/universalforwarder/releases/8.2.7/windows/splunkforwarder-8.2.7-2e1fca123028-x64-release.msi'

# directory for file to be downloaded to:
# currently set to download in the path that the script is in:
$path = Convert-Path .
$outputdir = $path + '\splunkuniversalforwarder.msi'

# file name of .msi installation file
$install_file = 'splunkuniversalforwarder.msi'

# Installation Directory for UniversalForwarder
$installdir = $splunk_home

echo "[*] checking for previous installations of splunk>..."
#echo "[*] Verify Current Splunk UniversalForwarder $declaredVar "

# checks to see if a splunk folder already exists in Program Files
# will skip installation if it finds a splunk folder

if (Test-Path -Path $installdir -PathType Container)
{
    echo "[!] install directory already exists. Upgrade Splunk forwarder..."
	
$declaredVar = Get-Content $splunk_version | Select-String VERSION

    if($declaredVar -match 'VERSION\=8\.2\.7')
	{
        echo "[*] splunk> universal forwarder is already running with latest $declaredVar"
		exit 1
    }
    echo "[*] downloading splunk> universal forwarder..."

    (New-Object System.Net.WebClient).DownloadFile($insturi, $outputdir)

    # check if download succedded
    if (-not $?)
    {
        echo "[!] failed to download splunk> universal forwarder..."
        exit 1
    }

    echo "[*] Upgrading splunk> universal fowarder..."
    Start-Process -FilePath msiexec.exe -ArgumentList "/i $install_file INSTALLDIR=`"$installdir`" AGREETOLICENSE=Yes /quiet" -Wait

}
else{
      echo "[*] splunk> universal forwarder is not running on localhost> install universal forwarder..."
      echo "[*] downloading splunk> universal forwarder..."

    # downloads splunk install file
    (New-Object System.Net.WebClient).DownloadFile($insturi, $outputdir)

    # check if download succedded
    if (-not $?)
    {
        echo "[!] failed to download splunk> universal forwarder..."
        exit 1
    }

    echo "[*] installing splunk> universal fowarder..."

    Start-Process -FilePath msiexec.exe -ArgumentList "/i $install_file INSTALLDIR=`"$installdir`" AGREETOLICENSE=Yes /quiet" -Wait
}

# **********  Configure deploymentclient.conf file in SplunkUniversalForwarder local Dirctory  ************
# hostname or ip : port of deploymentserver
echo "[*] Configure Splunk deployment server: $deploymentserver"
# location of deploymentclient.conf file
$deploymentclient = $splunk_home + "\etc\system\local\deploymentclient.conf"
echo "[target-broker:deploymentServer]" > $deploymentclient
echo "targetUri = $deploymentserver" >> $deploymentclient

# **********  Configure user-seed.conf file in SplunkUniversalForwarder local Dirctory  ************
# **********  Create admin credentials using the --seed-passwd
# hashed Splunk UF Password
echo "[*] Set an admin passwd"

if (!(Test-Path -Path $splunk_old_password )) 
{
    echo "[!] splunk> universal fowarder passwd file doesn't exist. Proceed to configure user credentials .." 
     
	# location of user-seed.conf file
    $userseed = $splunk_home + "\etc\system\local\user-seed.conf"
    echo "[user_info]" > $userseed
    echo "USERNAME = admin" >> $userseed
    echo "HASHED_PASSWORD = $hashedpasswd" >> $userseed
	 
} 
else{
    echo "[!] splunk> universal fowarder passwd File exist. Take backup of passwd file and proceed to configure user credentials .." 

    $splunkbackup = Move-Item -Path "$splunk_old_password" -Destination "$splunk_backup_passwd" -Force
	 
      # location of user-seed.conf file
    $userseed = $splunk_home + "\etc\system\local\user-seed.conf"
    echo "[user_info]" > $userseed
    echo "USERNAME = admin" >> $userseed
    echo "HASHED_PASSWORD = $hashedpasswd" >> $userseed
}

# **********  Start Splunk and check if process started  *****************

# restart splunk universal forwarder
$splunkexe = $splunk_home + "\bin\splunk.exe"
echo "[*] Restarting splunk> universal fowarder"
& "$splunkexe" restart

$declaredVar = Get-Content $splunk_version | Select-String VERSION

if($declaredVar -match 'VERSION\=8\.2\.7')
{
    echo "[*] splunk> universal fowarder upgrade completed successfully.."
	echo "[*] Verify Splunk $declaredVar"
	 
}
else{
	echo"[!] Failed to upgrade Splunk > universal forwarder "
	echo "[!] Splunk > universal forwarder is still running with $declaredVar"
	 }
    # checks to see if splunkd is running which indicates good install
    $splunk = Get-Process -Name "splunkd" -ErrorAction SilentlyContinue

if ($splunk -ne $null)  # confirms if it restarted successfully
{
    echo "[*] splunk> successfully started."
    echo "[*] running clean up."

    if (Test-Path -Path $install_file)
    {
        Remove-Item $install_file
    }

    echo "[*] clean up complete. Exiting..."
    return
}else{
    echo '[!] splunk process not running!'
    echo '[!] check to make sure installation was successful.'
    return
}
