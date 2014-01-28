#!/bin/bash

##########
CA_ROOT="/root/CA/"
# install the Apache server
yum -y -q install http php varnish
# set the Apache server to start at login
chkconfig --levels 235 httpd on
chkconfig --levels 235 varnish on
chkconfig --levels 235 varnishlog on
# start Apache now
/etc/init.d/httpd start
sleep 2

/etc/init.d/varnish start
/etc/init.d/varnishlog start
# Varnish is listening on the local port 6081
# Vagrant is configured to forward that port to port localhost:8081
# it's possible to test the Varnish cash using curl and monitoring the /etc/log/varnish/varnish.log file
# curl http://localhost:8081 # run this from the host machine


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

yum -y -q --enablerepo=mod-pagespeed install mod-pagespeed

# Enables the 'collapse_whitespace' of Pagespeed
sed -i 's/.*ModPagespeedEnableFilters collapse_whitespace.*/    ModPagespeedEnableFilters collapse_whitespace,elide_attributes/' /etc/httpd/conf.d/pagespeed.conf

/etc/init.d/httpd restart
/etc/init.d/varnish restart

# set up the PHP test page from which we will check that Apache is actualy loading the modules we require 
DOCUMENT_ROOT=`grep DocumentRoot /etc/httpd/conf/httpd.conf | sed "/^#/d" | cut -d'"' -f2`
PHP_INFO=$DOCUMENT_ROOT/phpinfo.php
touch $PHP_INFO
cat <<'EOF' > $PHP_INFO
<?php
    phpinfo ();
?>
EOF

# verifies that X-Mod-Pagespeed is properly installed
if curl -# http://localhost/phpinfo.php 2>/dev/null |grep Pagespeed 2>&1 > /dev/null 
then
    echo "X-Mod-Pagespeed installed and activated"
    curl -# http://localhost/phpinfo.php 2>/dev/null |grep Pagespeed
else
    echo "X-Mod-Pagespeed not installed or not activated"
fi
##########
# verifies that X-Mod-Pagespeed is properly working
if curl -# localhost 2> /dev/null |grep "  " 2>&1  > /dev/null 
then
    echo "X-Mod-Pagespeed is NOT working, double white spaces have been found"
    curl -#curl localhost 2> /dev/null
else
    echo "X-Mod-Pagespeed is removing space properly"
    curl -#curl localhost 2> /dev/null
fi


