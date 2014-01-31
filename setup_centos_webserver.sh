#!/bin/bash

# Creation of a CA and of a self-signed certificate for localhost to be used by mod_ssl
DOMAIN_NAME=localhost
CA_ROOT="/etc/pki/CA"
TLS_ROOT="/etc/pki/tls"
IPTABLE_SAVE_FILE="/etc/sysconfig/iptables"

/vagrant/vagrantme/setup_ca_and_certificate.sh $CA_ROOT $DOMAIN_NAME
echo "Copying Certificate and Private Key to the TLS folder for later use by mod_ssl"
cp $CA_ROOT/private/$DOMAIN_NAME.key  $TLS_ROOT/private/$DOMAIN_NAME.key
cp $CA_ROOT/certs/$DOMAIN_NAME.crt  $TLS_ROOT/certs/$DOMAIN_NAME.crt

# install the Apache server
echo "Installing Apache, PHP, mod_ssl, Varnish"
yum -y -q install http php varnish mod_ssl
# set the Apache server to start at login
echo "Activating Apache"
chkconfig --levels 235 httpd on
echo "Activating Varnish, VarnishLog"
chkconfig --levels 235 varnish on
chkconfig --levels 235 varnishlog on

echo "Installing mod_pagespeed repository"
#### install mod_pagespeed #####
NEW_REPO="/etc/yum.repos.d/mod-pagespeed.repo"
touch $NEW_REPO

cat <<'EOF' > $NEW_REPO
[mod-pagespeed]
name=mod-pagespeed
baseurl=http://dl.google.com/linux/mod-pagespeed/rpm/stable/x86_64
#baseurl=http://dl.google.com/linux/mod-pagespeed/rpm/stable/i386
enabled=1
gpgcheck=0
EOF
echo "Installing mod_pagespeed"
yum -y -q --enablerepo=mod-pagespeed install mod-pagespeed

echo "Enabling mod_pagespeed"
# Enables the 'collapse_whitespace' of Pagespeed
sed -i 's/.*ModPagespeedEnableFilters collapse_whitespace.*/    ModPagespeedEnableFilters collapse_whitespace,elide_attributes/' /etc/httpd/conf.d/pagespeed.conf


echo "Setting $DOMAIN_NAME as ServerName in Apache and mod_ssl"
# setup the ServerName for Apache
sed -i "s/#ServerName.*/ServerName $DOMAIN_NAME:80/" /etc/httpd/conf/httpd.conf
# setup the ServerName for mod_ssl
sed -i "s/#ServerName.*/ServerName $DOMAIN_NAME:443/" /etc/httpd/conf.d/ssl.conf


# start Apache now
/etc/init.d/httpd restart
/etc/init.d/varnish restart
/etc/init.d/varnishlog restart
# Varnish is listening on the local port 6081
# Vagrant is configured to forward that port to port localhost:8081
# it's possible to test the Varnish cash using curl and monitoring the /etc/log/varnish/varnish.log file
# curl http://localhost:8081 # run this from the host machine

echo "Testing mod_pagespeed"
# set up the PHP test page from which we will check that Apache is actualy loading the modules we require 
DOCUMENT_ROOT=`grep DocumentRoot /etc/httpd/conf/httpd.conf | sed "/^#/d" | cut -d'"' -f2`
PHP_INFO=$DOCUMENT_ROOT/phpinfo.php
touch $PHP_INFO
cat <<'EOF' > $PHP_INFO
<?php phpinfo (); ?>
EOF

# verifies that X-Mod-Pagespeed is properly installed
if curl -# http://localhost/phpinfo.php 2>/dev/null |grep Pagespeed 
then
    echo "X-Mod-Pagespeed installed and activated"
else
    echo "X-Mod-Pagespeed not installed or not activated"
fi
##########

# verifies that X-Mod-Pagespeed is properly working

MULTISPACE_TEST=$DOCUMENT_ROOT/multispace_test.html
touch $MULTISPACE_TEST
cat <<'EOF' > $MULTISPACE_TEST
<html>
        <head>                <title>Title</title> </head>
        <body>  <p>Paragraph with m  a  n  y       contiguous     spaces      !</p>        </body>
</html>
EOF

echo "Original content of $MULTISPACE_TEST:"
cat $MULTISPACE_TEST

echo "Requesting $MULTISPACE_TEST from the webserver"
if curl -# http://localhost/multispace_test.html 2> /dev/null |grep "  "
then
    echo "X-Mod-Pagespeed is NOT working, double white spaces have been found"
else
    curl -# http://localhost/multispace_test.html 2> /dev/null
    echo "X-Mod-Pagespeed is removing space properly"
fi

# IPTABLES Firewall setupt
echo "Enabling IPTABLES to accept connection exclusively for SSH, HTTP, HTTPS and CacheProxy"

cat <<'EOF' > $IPTABLE_SAVE_FILE
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
-A INPUT -p icmp -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 443 -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 6081 -j ACCEPT
-A INPUT -j REJECT --reject-with icmp-host-prohibited
-A FORWARD -j REJECT --reject-with icmp-host-prohibited
COMMIT
EOF

/etc/init.d/iptables restart
echo "Webserver Configuration completed!"

