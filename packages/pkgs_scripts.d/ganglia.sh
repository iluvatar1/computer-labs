echo "Installing ganglia (gmond and gmetad)"
echo "WARNING: CPPFLAGS might not be used ... "
wget -c https://slackbuilds.org/slackbuilds/14.2/network/ganglia.tar.gz
tar -xf ganglia.tar.gz
cd ganglia
wget http://downloads.sourceforge.net/ganglia/ganglia-3.7.2.tar.gz
VERSION=3.7.2 MAKEFLAGS="-j$(nproc)" CPPFLAGS=-I/usr/include/tirpc/ LDFLAGS=-ltirpc OPT=gmetad ./ganglia.SlackBuild

