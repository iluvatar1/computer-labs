MAJOR_VERSION=1.8
VERSION=${MAJOR_VERSION}.3

cd /tmp
wget -c https://slackbuilds.org/slackbuilds/15.0/development/julia.tar.gz
tar xf julia.tar.gz
cd julia
wget https://julialang-s3.julialang.org/bin/linux/x64/${MAJOR_VERSION}/julia-${VERSION}-linux-x86_64.tar.gz
VERSION=$VERSION bash julia.SlackBuild

installpkg /tmp/julia-${VERSION}-x86_64-1_SBo.tgz
