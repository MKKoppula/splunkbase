#!/bin/bash
# # Install and Update Splunk Universal Forwarder with specified configurations
# Run this script as root

# Detect OS / Distribution
KNOWN_DISTRIBUTION="(Debian|Ubuntu|RedHat|CentOS)"
DISTRIBUTION=$(lsb_release -d 2>/dev/null | grep -Eo $KNOWN_DISTRIBUTION)

if [ -f /etc/debian_version -o "$DISTRIBUTION" == "Debian" -o "$DISTRIBUTION" == "Ubuntu" ]; then
    OS="Debian"
elif [ -f /etc/redhat-release -o "$DISTRIBUTION" == "RedHat" -o "$DISTRIBUTION" == "CentOS" ]; then
    OS="RedHat"
else
    OS="$(uname -s)"
fi

function fail_with_message {
    echo "$@"
    exit 1
}

# Detect root user
if [ $(echo "$UID") = "0" ]; then
    _sudo=''
else
    _sudo='sudo'
    # ask for password & abort script if incorrect:
    sudo -v || fail_with_message 'Will not install Splunk Forwarder. Incorrect administrator password provided.'
fi

# assign splunk_home based on where user wants from the UI
splunk_home="${INSTALL_LOCATION}/splunkforwarder"
splunk_version_regex="[5-8]\\.[1-9]\\.[0-9]"
#splunk_version=`grep -Eo "$splunk_version_regex" $splunk_home/etc/splunk.version | head -1`
splunk_expected_version="8.2.7"
splunk_old_password="$splunk_home/etc/passwd"
splunk_backup_passwd="$splunk_home/etc/passwd.old"
splunk_password='$6$TaBl3gVmN2TZoCu4$LgdPPRXkmvyGMzz59s.9zLPqnNhn1ptVswsAW3nelN6yE0tZVaQI4DKNFF6b2OT8QpBLBpkWOLE5UlVxQTgQs/'

function install_uf_debian {

    echo -e "\033[32m\nStep:Checking for previous installation of Splunk...."

    if [ -d "$splunk_home" ] ; then
        echo -e "\033[32m\nsplunk> universal forwarder already exists. Upgrade Splunk forwarder...\n\033[0m"
    
    splunk_version=`grep -Eo "$splunk_version_regex" $splunk_home/etc/splunk.version | head -1`

    if [ "$splunk_version" = "$splunk_expected_version" ]; then
        echo -e "\033[32m\nsplunk> universal forwarder is already running with latest version...\n\033[0m"
        exit 0;
    fi

    if [ "$splunk_version" != "$splunk_expected_version" ]; then
        echo -e "\033[32m\nsplunk> downloading splunk universal forwarder...\n\033[0m"
             
        if ! hash wget 2>/dev/null; then
            $_sudo apt-get install -y wget
        fi
#        $_sudo mkdir -p "$INSTALL_LOCATION"
        $_sudo wget -O splunkforwarder-8.2.7-2e1fca123028-Linux-x86_64.tgz 'https://download.splunk.com/products/universalforwarder/releases/8.2.7/linux/splunkforwarder-8.2.7-2e1fca123028-Linux-x86_64.tgz'
        $_sudo tar xvzf splunkforwarder-8.2.7-2e1fca123028-Linux-x86_64.tgz -C $INSTALL_LOCATION
        if [ $? -ne 0 ] ; then
            echo "Failed to install Splunk Universal Forwarder."
            exit 1
        fi
    fi
    else 
        echo -e "\033[32m\nsplunk> universal forwarder is not running on localhost> install latest version...\n\033[0m"
        echo -e "\033[32m\nsplunk> downloading splunk universal forwarder...\n\033[0m"
    
        if ! hash wget 2>/dev/null; then
            $_sudo apt-get install -y wget
        fi
        $_sudo mkdir -p "$INSTALL_LOCATION"
        $_sudo wget -O splunkforwarder-8.2.7-2e1fca123028-Linux-x86_64.tgz 'https://download.splunk.com/products/universalforwarder/releases/8.2.7/linux/splunkforwarder-8.2.7-2e1fca123028-Linux-x86_64.tgz'
        $_sudo tar xvzf splunkforwarder-8.2.7-2e1fca123028-Linux-x86_64.tgz -C $INSTALL_LOCATION
        if [ $? -ne 0 ] ; then
            echo "Failed to install Splunk Universal Forwarder."
            exit 1
        fi
        
    fi
}

function install_uf_redhat {

    echo -e "\033[32m\nStep:Checking for previous installation of Splunk...."

    if [ -d "$splunk_home" ] ; then
        echo -e "\033[32m\nsplunk> universal forwarder already exists. Upgrade Splunk forwarder...\n\033[0m"

    splunk_version=`grep -Eo "$splunk_version_regex" $splunk_home/etc/splunk.version | head -1`

    if [ "$splunk_version" = "$splunk_expected_version" ]; then
        echo -e "\033[32m\nsplunk> universal forwarder is already running with latest version...\n\033[0m"
        exit 0;
    fi

    if [ "$splunk_version" != "$splunk_expected_version" ]; then
        echo -e "\033[32m\nsplunk> downloading splunk universal forwarder...\n\033[0m"
             
        if ! hash wget 2>/dev/null; then
            $_sudo yum install -y wget
        fi
#        $_sudo mkdir -p "$INSTALL_LOCATION"
        $_sudo wget -O splunkforwarder-8.2.7-2e1fca123028-Linux-x86_64.tgz 'https://download.splunk.com/products/universalforwarder/releases/8.2.7/linux/splunkforwarder-8.2.7-2e1fca123028-Linux-x86_64.tgz'
        $_sudo tar xvzf splunkforwarder-8.2.7-2e1fca123028-Linux-x86_64.tgz -C $INSTALL_LOCATION
        if [ $? -ne 0 ] ; then
            echo "Failed to install Splunk Universal Forwarder."
            exit 1
        fi
    fi
    else 
        echo -e "\033[32m\nsplunk> universal forwarder is not running on localhost> install latest version...\n\033[0m"
        echo -e "\033[32m\nsplunk> downloading splunk universal forwarder...\n\033[0m"
    
        if ! hash wget 2>/dev/null; then
            $_sudo yum install -y wget
        fi
        $_sudo mkdir -p "$INSTALL_LOCATION"
        $_sudo wget -O splunkforwarder-8.2.7-2e1fca123028-Linux-x86_64.tgz 'https://download.splunk.com/products/universalforwarder/releases/8.2.7/linux/splunkforwarder-8.2.7-2e1fca123028-Linux-x86_64.tgz'
        $_sudo tar xvzf splunkforwarder-8.2.7-2e1fca123028-Linux-x86_64.tgz -C $INSTALL_LOCATION
        if [ $? -ne 0 ] ; then
            echo "Failed to install Splunk Universal Forwarder."
            exit 1
        fi
        
    fi
}

function install_uf_solaris {
    echo -e "\033[32m\nStep:Checking for previous installation of Splunk...."

    if [ -d "$splunk_home" ] ; then
        echo -e "\033[32m\nsplunk> universal forwarder already exists. Upgrade Splunk forwarder...\n\033[0m"

    if [ "$splunk_version" = "$splunk_expected_version" ]; then
        echo -e "\033[32m\nsplunk> universal forwarder is already running with latest version...\n\033[0m"
        exit 0;
    fi

    if [ "$splunk_version" != "$splunk_expected_version" ]; then
        echo -e "\033[32m\nsplunk> downloading splunk universal forwarder...\n\033[0m"
        echo -e "\033[32m\nStep:Installing Splunk Universal Forwarder on Solaris x86...\n\033[0m"
             
        $_sudo mkdir -p "$INSTALL_LOCATION"
        $_sudo wget -O splunkforwarder-8.2.7-2e1fca123028-SunOS-x86_64.tar.Z 'https://download.splunk.com/products/universalforwarder/releases/8.2.7/solaris/splunkforwarder-8.2.7-2e1fca123028-SunOS-x86_64.tar.Z'
        $_sudo gunzip -c splunkforwarder-8.2.7-2e1fca123028-SunOS-x86_64.tar.Z | (cd $INSTALL_LOCATION && $_sudo tar -xvf -)
        if [ $? -ne 0 ] ; then
            echo "Failed to install Splunk Universal Forwarder."
            exit 1
        fi
    fi
    else 
        echo -e "\033[32m\nsplunk> universal forwarder is not running on localhost> install latest version...\n\033[0m"
        echo -e "\033[32m\nsplunk> downloading splunk universal forwarder...\n\033[0m"
        echo -e "\033[32m\nStep:Installing Splunk Universal Forwarder on Solaris x86...\n\033[0m"
    
        $_sudo mkdir -p "$INSTALL_LOCATION"
        $_sudo wget -O splunkforwarder-8.2.7-2e1fca123028-SunOS-x86_64.tar.Z 'https://download.splunk.com/products/universalforwarder/releases/8.2.7/solaris/splunkforwarder-8.2.7-2e1fca123028-SunOS-x86_64.tar.Z'
        $_sudo gunzip -c splunkforwarder-8.2.7-2e1fca123028-SunOS-x86_64.tar.Z | (cd $INSTALL_LOCATION && $_sudo tar -xvf -)
        if [ $? -ne 0 ] ; then
            echo "Failed to install Splunk Universal Forwarder."
            exit 1
        fi
        
    fi
}


function deployment_client {
    echo -e "\033[32m\nsplunk> universal forwarder> Configure Splunk deployment Server\n\033[0m"
    deploymentclient_conf=$splunk_home/etc/system/local/deploymentclient.conf

    $_sudo touch $deploymentclient_conf
    $_sudo chmod a+w $deploymentclient_conf

    echo -e "[target-broker:deploymentServer]" >> $deploymentclient_conf
    echo -e "targetUri = usstl-splunk-ds.emrsn.org:8089" >> $deploymentclient_conf
    echo -e "\n[deployment-client]" >> $deploymentclient_conf
    echo -e "phoneHomeIntervalInSecs = 600" >> $deploymentclient_conf
}

function set_up_splunk_password {

echo -e "\033[32m\nsplunk> universal forwarder> set an admin passwd\n\033[0m"

if [ ! -f "$splunk_old_password" ]; then 
    echo -e "\033[32m\nsplunk> universal fowarder> passwd file doesn't exists. Proceed to configure user credentials...\n\033[0m" 
    
    # using user-seed.conf
	# location of user-seed.conf file
    userseed_conf=$splunk_home/etc/system/local/user-seed.conf

    $_sudo touch $userseed_conf
    $_sudo chmod a+w $userseed_conf

    echo -e "[user_info]" >> $userseed_conf
    echo -e "USERNAME = admin" >> $userseed_conf
    echo -e "HASHED_PASSWORD = $splunk_password" >> $userseed_conf

else
    echo -e "\033[32m\nsplunk> universal fowarder passwd file exist. Take backup of passwd file and performing a Splunk Password Reset...\n\033[0m" 
    
    # move the existing $SPLUNK_HOME/etc passwd file to a backup location.
    splunkbackup=`mv -f $splunk_home/etc/passwd $splunk_home/etc/passwd.old`
	 
	# location of user-seed.conf file
    userseed_conf=$splunk_home/etc/system/local/user-seed.conf
    $_sudo touch $userseed_conf
    $_sudo chmod a+w $userseed_conf

    echo -e "[user_info]" >> $userseed_conf
    echo -e "USERNAME = admin" >> $userseed_conf
    echo -e "HASHED_PASSWORD = $splunk_password" >> $userseed_conf
fi

}

function configure {

    echo -e "\033[32m\nStep:Enabling boot start for Splunk Universal Forwarder...\n\033[0m"
    $_sudo "$splunk_home/bin/splunk" restart --answer-yes --auto-ports --no-prompt --accept-license

    $_sudo "$splunk_home/bin/splunk" disable boot-start
    $_sudo "$splunk_home/bin/splunk" enable boot-start
}

if [ "$OS" = "Debian" ]; then
    install_uf_debian
    set_up_splunk_password
    deployment_client
    configure
elif [ "$OS" = "RedHat" ]; then
    install_uf_redhat
    set_up_splunk_password
    deployment_client
    configure

elif [ "$OS" = "SunOS" ]; then
    install_uf_solaris
    configure
else
    echo -e "\033[31m\nNot supported operating system: $OS. Nothing is installed.\n\033[0m"
fi
