#!/bin/bash

##########

# install the Apache server
yum -y -q install http php
# set the Apache server to start at login
chkconfig --levels 235 httpd on

# start Apache now
/etc/init.d/httpd restart

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
