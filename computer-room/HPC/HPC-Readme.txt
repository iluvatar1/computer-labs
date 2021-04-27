#+TITLE: HPC utils howto
* Glusterfs (To create parallel storage)
- https://www.howtoforge.com/tutorial/high-availability-storage-with-glusterfs-on-ubuntu-1804/#step-configure-glusterfs-servers
- https://docs.gluster.org/en/latest/Administrator%20Guide/Setting%20Up%20Volumes/
- https://microdevsys.com/wp/mount-failed-please-check-the-log-file-for-more-details/
- https://sysadmins.co.za/setup-a-distributed-storage-volume-with-glusterfs/
1. Create a trusted storage pool (all this is supposed to run in =192.168.10.1=)
	- Get the storage servers :
	  #+BEGIN_SRC shell
	  pssh -i -h /home/oquendo/INFO/MYHOSTS   'df -h | grep /opt'
	  #+END_SRC
	  From here I will use ~4,5,8,19,33,34~ since they have more than 300Gb in opt, each one.
	  I have saved this names in ~/home/oquendo/INFO/HOSTSSTORAGE~
	  #+BEGIN_SRC shell
	  pssh -i  -h /home/oquendo/INFO/HOSTSSTORAGE   'mkdir /opt/glusterbrick'
	  #+END_SRC
	- Now really create the storage pool:
	  #+BEGIN_SRC shell
pssh -i  -h /home/oquendo/INFO/HOSTSSTORAGE   'chmod +x /etc/rc.d/rc.glusterd '
pssh -i  -h /home/oquendo/INFO/HOSTSSTORAGE   '/etc/rc.d/rc.glusterd start '
for IP in $(cat /home/oquendo/INFO/HOSTSSTORAGE); do
    gluster peer probe ${IP%:22};
done
gluster peer status
gluster pool list
for IP in $(cat /home/oquendo/INFO/HOSTSSTORAGE); do
    gluster volume create gfsdist ${IP%:22}:/opt/glusterbrick ;
done
	  #+END_SRC
2. Start the volume
	#+BEGIN_SRC shell
	gluster volume start gfsdist
	#+END_SRC
3. Then mount it on a client
	#+BEGIN_SRC shell
	mount.glusterfs 192.168.10.1:/gfsdist /mnt/tmp/
	#+END_SRC
	To mount it on many clients:
	#+BEGIN_SRC shell
	pssh -i -h /home/oquendo/INFO/MYHOSTS 'echo "# GLUSTER" >> /etc/fstab '
	pssh -i -h /home/oquendo/INFO/MYHOSTS 'echo "192.168.10.1:/gfsdist  /mnt/scratch glusterfs defaults,_netdev 0 0" >> /etc/fstab '
	pssh -i -h /home/oquendo/INFO/MYHOSTS 'mkdir /mnt/scratch '
	pssh -i -h /home/oquendo/INFO/MYHOSTS 'mount -a '
	pssh -i -h /home/oquendo/INFO/MYHOSTS 'df -h '
	#+END_SRC
4. If you want to add more bricks (execute on =192.168.10.1=, and
        see
        https://docs.gluster.org/en/latest/Administrator%20Guide/Managing%20Volumes/#expanding-volumes)
* Munge (auth for HPC - Needed by slurm)
Follow https://moc-documents.readthedocs.io/en/latest/hpc/Slurm.html

- Create a munge user
  #+begin_src shell
groupadd -g 310 munge
useradd -u 310 -d /var/lib/munge -s /bin/false -g munge munge
  #+end_src
  If needed, edit =/var/yp/Makefile= to reduce the minimim UID to include munge
  uid.

- Install munge using sbo:
  - Create munge package
    #+begin_src shell
  TEMPDIR=$(mktemp -d)
  cd $TEMPDIR
  wget https://slackbuilds.org/slackbuilds/14.2/network/munge.tar.gz
  wget https://github.com/dun/munge/releases/download/munge-0.5.14/munge-0.5.14.tar.xz
  export VERSION=0.5.14
  slpkg -a munge.tar.gz munge-0.5.14.tar.xz
  unset VERSION
      #+end_src
  - Install munge package
    #+begin_src  shell
installpkg /tmp/munge-0.5.14-x86_64-1_SBo.tgz
for dbase in /var/run/ /var/log/ /etc/; do
    chown munge $dbase/munge
done
    #+end_src
    Do this install and config *on all nodes*
  - On the server, create a munge-key
    #+begin_src shell
sudo -u munge /usr/sbin/mungekey --verbose
    #+end_src
  - Propagate the key to all clients =cp /etc/munge/munge.key
    toremote:/etc/munge/munge.key= . Just in case, chown it to munge user.
  - On both the server and client, enable and start the service:
    =chmod +x /etc/rc.d/rc.munge=
    =/etc/rc.d/rc.munge start=
    Maybe fix the script by using the following exec command in line 182:
    =ERRMSG=$(sudo -u "$USER" $DAEMON_EXEC $DAEMON_ARGS 2>&1)=
  - TESTING:
    - Server:
      - munge -n
      - munge -n | unmunge
      - munge -n | ssh somehost unmunge
      - remunge # for performance check

* Slurm and openmpi (resource manager)
- Software Deps PRE:
  + numactl rrdtool:
    #+begin_src shell
slpkg -s sbo rrdtool numactl
    #+end_src
  + hwloc
    #+begin_src shell
  cd ~/Downloads
  # hwloc
  wget https://slackbuilds.org/slackbuilds/14.2/system/hwloc.tar.gz
  wget https://download.open-mpi.org/release/hwloc/v2.3/hwloc-2.3.0.tar.bz2
  export VERSION=2.3.0
  slpkg -a hwloc.tar.gz hwloc-2.3.0.tar.bz2
  unset VERSION
  installpkg /tmp/hwloc*tgz
  # TODO: maybe add numjobs to make
  #+end_src

  #+RESULTS:

  + openpmix
    #+begin_src shell
# openpmix : TODO Test with version 4
cd ~/Downloads
mkdir 01-openpmix
cd 01-openpmix
wget https://github.com/openpmix/openpmix/archive/v3.2.2.tar.gz
# The follwing is generated with alien slackbuild generator
cat <<EOF > slack-desc
# HOW TO EDIT THIS FILE:
# The "handy ruler" below makes it easier to edit a package description.  Line
# up the first '|' above the ':' following the base package name, and the '|'
# on the right side marks the last column you can put a character in.  You must
# make exactly 11 lines for the formatting to be correct.  It's also
# customary to leave one space after the ':'.

        |-----handy-ruler------------------------------------------------------|
openpmix: openpmix (The Process Management Interface (PMI))
openpmix:
openpmix: The Process Management Interface (PMI) has been used for quite
openpmix: some time as a means of exchanging wireup information needed for
openpmix: interprocess communication. Two versions (PMI-1 and PMI-2) have
openpmix: been released as part of the MPICH effort. While PMI-2 demonstrates
openpmix: better scaling properties than its PMI-1 predecessor, attaining
openpmix: rapid launch and wireup of the roughly 1M processes executing across
openpmix: 100k nodes expected for exascale operations remains challenging.
openpmix: PMI Exascale (PMIx) represents an attempt to resolve these questions
openpmix: by providing an extended version of the PMI standard specifically
EOF

cat <<EOF > openpmix.SlackBuild
#!/bin/sh
# Generated by Alien's SlackBuild Toolkit: http://slackware.com/~alien/AST
# Copyright 2009, 2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020  Eric Hameleers, Eindhoven, Netherlands
# Copyright 2020  William Oquendo <woquendo@gmail.com>
# All rights reserved.
#
#   Permission to use, copy, modify, and distribute this software for
#   any purpose with or without fee is hereby granted, provided that
#   the above copyright notice and this permission notice appear in all
#   copies.
#
#   THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESSED OR IMPLIED
#   WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
#   MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
#   IN NO EVENT SHALL THE AUTHORS AND COPYRIGHT HOLDERS AND THEIR
#   CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
#   LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
#   USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#   ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
#   OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
#   OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
#   SUCH DAMAGE.
# -----------------------------------------------------------------------------
#
# Slackware SlackBuild script
# ===========================
# By:          William Oquendo <woquendo@gmail.com>
# For:         openpmix
# Descr:       The Process Management Interface (PMI)
# URL:         https://github.com/openpmix/openpmix
# Build needs:
# Needs:
# Changelog:
# 3.2.2-1:     29/Dec/2020 by William Oquendo <woquendo@gmail.com>
#              * Initial build.
#
# Run 'sh openpmix.SlackBuild' to build a Slackware package.
# The package (.t?z) and .txt file as well as build logs are created in /tmp .
# Install the package using 'installpkg' or 'upgradepkg --install-new'.
#
# -----------------------------------------------------------------------------

PRGNAM=openpmix
VERSION=${VERSION:-3.2.2}
BUILD=${BUILD:-1}
# 'make' can run jobs in parallel for added speed. The number should be higher
# than the number of cores/virtual CPU's in your system:
NUMJOBS=${NUMJOBS:-" -j$(nproc) "}
# The TAG is a unique identifier for all your Slackware packages.
# Use your initials as the value for TAG for instance.
TAG=${TAG:-_ast}

# This covers most filenames you'd want as documentation. Change if needed.
#DOCS="ABOUT* AUTHORS BUGS ChangeLog* COPYING CREDITS FAQ GPL* HACKING \
#      LICENSE MAINTAINERS NEWS README* TODO"
DOCS="AUTHORS HACKING LICENSE NEWS README*"

# Where do we look for sources?
SRCDIR=$(cd $(dirname $0); pwd)

# Place to build (TMP) package (PKG) and output (OUTPUT) the program:
TMP=${TMP:-/tmp/build}
PKG=$TMP/package-$PRGNAM
OUTPUT=${OUTPUT:-/tmp}

# Input URL: https://github.com/openpmix/openpmix/archive/v3.2.2.tar.gz
SOURCE="$SRCDIR/${PRGNAM}-${VERSION}.tar.gz"
SRCURL="https://github.com/${PRGNAM}/${PRGNAM}/archive/v${VERSION}.tar.gz"


##
## --- with a little luck, you won't have to edit below this point --- ##
##

# You can use your own private machine.conf file to overrule machine defaults:
if [ -e $SRCDIR/machine.conf ]; then
  . $SRCDIR/machine.conf
elif [ -e /etc/slackbuild/machine.conf ]; then
  . /etc/slackbuild/machine.conf
else
  # Automatically determine the architecture we're building on:
  if [ -z "$ARCH" ]; then
    case "$(uname -m)" in
      i?86) ARCH=i586 ;;
      arm*) readelf /usr/bin/file -A | egrep -q "Tag_CPU.*[4,5]" && ARCH=arm || ARCH=armv7hl ;;
      # Unless $ARCH is already set, use uname -m for all other archs:
      ,*) ARCH=$(uname -m) ;;
    esac
    export ARCH
  fi
  # Set CFLAGS/CXXFLAGS and LIBDIRSUFFIX:
  case "$ARCH" in
    i?86)      SLKCFLAGS="-O2 -march=${ARCH} -mtune=i686"
               SLKLDFLAGS=""; LIBDIRSUFFIX=""
               ;;
    x86_64)    SLKCFLAGS="-O2 -fPIC"
               SLKLDFLAGS="-L/usr/lib64"; LIBDIRSUFFIX="64"
               ;;
    armv7hl)   SLKCFLAGS="-O2 -march=armv7-a -mfpu=vfpv3-d16"
               SLKLDFLAGS=""; LIBDIRSUFFIX=""
               ;;
    ,*)         SLKCFLAGS=${SLKCFLAGS:-"-O2"}
               SLKLDFLAGS=${SLKLDFLAGS:-""}; LIBDIRSUFFIX=${LIBDIRSUFFIX:-""}
               ;;
  esac
fi

case "$ARCH" in
    arm*)    TARGET=$ARCH-slackware-linux-gnueabi ;;
    ,*)       TARGET=$ARCH-slackware-linux ;;
esac

# Exit the script on errors:
set -e
trap 'echo "$0 FAILED at line ${LINENO}" | tee $OUTPUT/error-${PRGNAM}.log' ERR
# Catch unitialized variables:
set -u
P1=${1:-1}

# Save old umask and set to 0022:
_UMASK_=$(umask)
umask 0022

# Create working directories:
mkdir -p $OUTPUT          # place for the package to be saved
mkdir -p $TMP/tmp-$PRGNAM # location to build the source
mkdir -p $PKG             # place for the package to be built
rm -rf $PKG/*             # always erase old package's contents
rm -rf $TMP/tmp-$PRGNAM/* # remove the remnants of previous build
rm -rf $OUTPUT/{checkout,configure,make,install,error,makepkg,patch}-$PRGNAM.log
                          # remove old log files

# Source file availability:
if ! [ -f ${SOURCE} ]; then
  echo "Source '$(basename ${SOURCE})' not available yet..."
  # Check if the $SRCDIR is writable at all - if not, download to $OUTPUT
  [ -w "$SRCDIR" ] || SOURCE="$OUTPUT/$(basename $SOURCE)"
  if [ -f ${SOURCE} ]; then echo "Ah, found it!"; continue; fi
  if ! [ "x${SRCURL}" == "x" ]; then
    echo "Will download file to $(dirname $SOURCE)"
    wget --no-check-certificate -nv -T 20 -O "${SOURCE}" "${SRCURL}" || true
    if [ $? -ne 0 -o ! -s "${SOURCE}" ]; then
      echo "Downloading '$(basename ${SOURCE})' failed... aborting the build."
      mv -f "${SOURCE}" "${SOURCE}".FAIL
      exit 1
    fi
  else
    echo "File '$(basename ${SOURCE})' not available... aborting the build."
    exit 1
  fi
fi

if [ "$P1" == "--download" ]; then
  echo "Download complete."
  exit 0
fi

# --- PACKAGE BUILDING ---

echo "++"
echo "|| $PRGNAM-$VERSION"
echo "++"

# Explode the package framework:
if [ -f $SRCDIR/_$PRGNAM.tar.gz ]; then
  cd $PKG
  explodepkg $SRCDIR/_$PRGNAM.tar.gz
  cd -
fi

cd $TMP/tmp-$PRGNAM
echo "Extracting the source archive(s) for $PRGNAM..."
if $(file ${SOURCE} | grep -qi ": 7-zip"); then
  7za x ${SOURCE}
elif $(file ${SOURCE} | grep -qi ": zip"); then
  unzip ${SOURCE}
else
  tar -xvf ${SOURCE}
fi
cd ${PRGNAM}-${VERSION}
chown -R root:root .
chmod -R u+w,go+r-w,a+rX-st .

echo Building ...
./autogen.pl

LDFLAGS="$SLKLDFLAGS" \
CXXFLAGS="$SLKCFLAGS" \
CFLAGS="$SLKCFLAGS" \
./configure \
  --prefix=/usr \
  --libdir=/usr/lib${LIBDIRSUFFIX} \
  --localstatedir=/var \
  --sysconfdir=/etc \
  --mandir=/usr/man \
  --docdir=/usr/doc/$PRGNAM-$VERSION \
  --enable-shared \
  --disable-static \
  --program-prefix= \
  --program-suffix= \
  --build=$TARGET \
  2>&1 | tee $OUTPUT/configure-${PRGNAM}.log

make $NUMJOBS 2>&1 | tee $OUTPUT/make-${PRGNAM}.log
make DESTDIR=$PKG install 2>&1 | tee $OUTPUT/install-${PRGNAM}.log

# Add documentation:
mkdir -p $PKG/usr/doc/$PRGNAM-$VERSION
cp -a $DOCS $PKG/usr/doc/$PRGNAM-$VERSION || true
cat $SRCDIR/$(basename $0) > $PKG/usr/doc/$PRGNAM-$VERSION/$PRGNAM.SlackBuild
chown -R root:root $PKG/usr/doc/$PRGNAM-$VERSION
find $PKG/usr/doc -type f -exec chmod 644 {} \;

# Compress the man page(s):
if [ -d $PKG/usr/man ]; then
  find $PKG/usr/man -type f -name "*.?" -exec gzip -9f {} \;
  for i in $(find $PKG/usr/man -type l -name "*.?") ; do ln -s $( readlink $i ).gz $i.gz ; rm $i ; done
fi

# Compress info pages and remove the package's dir file:
if [ -d $PKG/usr/info ]; then
  rm -f $PKG/usr/info/dir
  gzip -9f $PKG/usr/info/*.info*
  # If any info files are present, consider adding this to a doinst.sh
  # (replacing XXXXX with whatever files you find):
  # chroot . install-info /usr/info/XXXXX.info.gz /usr/info/dir 2> /dev/null
fi

# Strip binaries (if any):
find $PKG | xargs file | grep -e "executable" -e "shared object" | grep ELF \
  | cut -f 1 -d : | xargs strip --strip-unneeded 2> /dev/null || true

# Add a package description:
mkdir -p $PKG/install
cat $SRCDIR/slack-desc > $PKG/install/slack-desc
if [ -f $SRCDIR/doinst.sh ]; then
  cat $SRCDIR/doinst.sh >> $PKG/install/doinst.sh
elif [ -f $SRCDIR/doinst.sh.gz ]; then
  zcat $SRCDIR/doinst.sh.gz >> $PKG/install/doinst.sh
fi
if [ -f $SRCDIR/slack-required ]; then
  cat $SRCDIR/slack-required > $PKG/install/slack-required
fi

# Build the package:
cd $PKG
makepkg --linkadd y --chown n $OUTPUT/${PRGNAM}-${VERSION}-${ARCH}-${BUILD}${TAG}.${PKGTYPE:-tgz} 2>&1 | tee $OUTPUT/makepkg-${PRGNAM}.log
cd $OUTPUT
md5sum ${PRGNAM}-${VERSION}-${ARCH}-${BUILD}${TAG}.${PKGTYPE:-tgz} > ${PRGNAM}-${VERSION}-${ARCH}-${BUILD}${TAG}.${PKGTYPE:-tgz}.md5
cd -
cat $PKG/install/slack-desc | grep "^${PRGNAM}" > $OUTPUT/${PRGNAM}-${VERSION}-${ARCH}-${BUILD}${TAG}.txt
if [ -f $PKG/install/slack-required ]; then
  cat $PKG/install/slack-required > $OUTPUT/${PRGNAM}-${VERSION}-${ARCH}-${BUILD}${TAG}.dep
fi

# Restore the original umask:
umask ${_UMASK_}

EOF

bash openpmix.SlackBuild
installpkg /tmp/openpmix-3.2.2-x86_64-1_ast.tgz
#+end_src
- Create a slurm user
  #+begin_src shell
groupadd -g 311 slurm
useradd -u 311 -d /var/lib/slurm -s /bin/false -g slurm slurm
  #+end_src
  If needed, edit =/var/yp/Makefile= to reduce the minimim UID to include slurm
  uid.
- Install slurm
  #+begin_src shell
cd ~/Downloads
wget https://slackbuilds.org/slackbuilds/14.2/network/slurm.tar.gz
wget https://download.schedmd.com/slurm/slurm-20.11.2.tar.bz2
export VERSION=20.11.2
export HWLOC=yes
export RRDTOOL=yes
slpkg -a slurm.tar.gz slurm-20.11.2.tar.bz2
installpkg /tmp/slurm-20.11.2-x86_64-1_SBo.tgz
unset VERSION HWLOC RRDTOOL
#+end_src
- Install openmpi to play nice with slurm
  #+begin_src shell
cd ~/Downloads
wget https://slackbuilds.org/slackbuilds/14.2/system/openmpi.tar.gz
wget https://download.open-mpi.org/release/open-mpi/v4.1/openmpi-4.1.0.tar.bz2
export VERSION=4.1.0
export PMI=yes
slpkg -a openmpi.tar.gz openmpi-4.1.0.tar.bz2
installpkg /tmp/openmpi-4.1.0-x86_64-2_SBo.tgz
  #+end_src
- On each node and master:
  #+begin_src shell
    prsync  -t 3 -h /home/oquendo/INFO/MYHOSTS /etc/slurm/slurm.conf /etc/slurm/slurm.conf
    mkdir /var/spool/slurmd
    chown slurm: /var/spool/slurmd
    mkdir /var/spool/slurm
    chown slurm: /var/spool/slurm
    chmod 755 /var/spool/slurmd
    touch /var/log/slurmd.log
    chown slurm: /var/log/slurmd.log
  #+end_src
- Use =slurmd -C= to extract the config on each node, and add it to the server
  slurm.conf:
#+begin_src shell
for ii in $(seq 2 35); do
    ssh -o ConnectTimeout=1 192.168.10.$ii 'slurmd -C'  2>/dev/null | grep -v UpTime | sed 's/valinor/sala'$ii'/';
done >> /etc/slurm/slurm.conf
#+end_src
- Specify partitions
  #+begin_src shell
# PARTITIONS
PartitionName=login Nodes=serversalafis Default=NO MaxTime=5 State=UP
PartitionName=8threads Nodes=sala[2,6,7,13,15,33,32,34] Default=NO MaxTime=INFINITE State=UP
PartitionName=4threads Nodes=sala[4,5,8,12,14,17,19,21,31] Default=NO MaxTime=INFINITE State=UP
PartitionName=2threads Nodes=sala[3,10,24,26,28,29] Default=YES MaxTime=INFINITE State=UP
  #+end_src
- Accounting files on MASTER
  #+begin_src shell
touch /var/log/slurm_jobacct.log /var/log/slurm_jobcomp.log
chown slurm: /var/log/slurm_jobacct.log /var/log/slurm_jobcomp.log
  #+end_src
- Maybe fix the hostnames
  #+begin_src shell
for ii in $(seq 2 35); do
    ssh -o ConnectTimeout=1 192.168.10.$ii "cp /etc/HOSTNAME{,-OLD}; echo sala$ii /etc/HOSTNAME"
done

  #+end_src
- Start the service on all
  #+begin_src shell
chmod +x /etc/rc.d/rc.slurm
/etc/rc.d/rc.slurm start
  #+end_src

