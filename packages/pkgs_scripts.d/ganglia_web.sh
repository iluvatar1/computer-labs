echo "Installing ganglia-web with default location at /var/www/htdocs/ganglia"
echo "WARNING: CPPFLAGS might not be used ... "
wget -c https://slackbuilds.org/slackbuilds/14.2/network/ganglia-web.tar.gz
wget -c http://downloads.sourceforge.net/ganglia/ganglia-web-3.7.2.tar.gz 
tar -xf ganglia-web.tar.gz
cd ganglia-web
ln -s ../ganglia-web-3.7.2.tar.gz ./
VERSION=3.7.2 MAKEFLAGS="-j$(nproc)" CPPFLAGS=-I/usr/include/tirpc/ LDFLAGS=-ltirpc OPT=gmetad ./ganglia-web.SlackBuild

