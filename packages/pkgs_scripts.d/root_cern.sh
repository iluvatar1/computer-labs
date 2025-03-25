#############################
# Using sbo
#############################
sbopkg -r
sqg -p root
printf "Q\nP\n" | MAKEFLAGS=-j$(nproc) sbopkg -i root
#mkdir /packages/SLACKWARE/root
#mv /tmp/*tgz /packages/SLACKWARE/root/

#############################
# OLD WAY
#############################

# # Config vars
# TDIR=/opt/ROOT_CERN
# FNAME=root_v6.26.06.Linux-centos8-x86_64-gcc8.5.tar.gz
# TNAME=$TDIR/$FNAME

# # Dependencies

# echo "Downloading the given release and unpacking ..."
# if [ ! -d $TDIR ]; then mkdir $TDIR; fi
# if [ ! -f $TNAME ]; then
#     wget -c https://root.cern/download/$FNAME -O $TNAME 
# fi
# if [ ! -d $TDIR/root ]; then
#     cd $TDIR/
#     tar xvf $FNAME
# fi

# echo "Configuring /etc/profile.d script"
# SCRIPTNAME=/etc/profile.d/root_cern.sh
# if [ ! -x $SCRIPTNAME ]; then
#     echo "source $TDIR/root/bin/thisroot.sh" > $SCRIPTNAME
#     chmod +x $SCRIPTNAME
# fi

# echo "Done. Open a new terminal and try the command: root"
