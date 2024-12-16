echo "\n->Create a munge user in the server (NIS propagates this to all nodes)"
export MUNGEUSER=991
groupadd -g $MUNGEUSER munge
useradd  -m -c "MUNGE Uid 'N' Gid Emporium" -d /var/lib/munge -u $MUNGEUSER -g munge  -s /sbin/nologin munge

printf "\n->Possibly install munge and fix permissions and startup script ..."
BNAME=/tmp/munge_tmp00.sh
cat <<EOF > $BNAME
    if ! hash munge; then
       echo "Installing munge"
       source /root/.bashrc
       sbopkg -B -i munge
    fi
    for dbase in /var/run/ /var/log/ /etc/; do
        chown munge \$dbase/munge
    done
    chmod +x /etc/rc.d/rc.munge
EOF
#cat $BNAME
#exit
bash $BNAME
clush -P -b -w @roles:nodes -c $BNAME 2>/dev/null
clush -P -b -w @roles:nodes "bash $BNAME" 2>/dev/null

# Fix config
#Maybe fix the script by using the following exec command in line 182:
sed -i '182s/.*/ERRMSG=$(sudo -u "$USER" $DAEMON_EXEC $DAEMON_ARGS 2>\&1)/' /etc/rc.d/rc.munge
#=ERRMSG=$(sudo -u "$USER" $DAEMON_EXEC $DAEMON_ARGS 2>&1)=
#chmod +x /etc/rc.d/rc.munge
clush -P -b -w @roles:nodes -c /etc/rc.d/rc.munge 2>/dev/null

echo "\n->Create a munge key on the server and propagate it ... "
if [ ! -f /etc/munge/munge.key ]; then
	sudo -u munge /usr/sbin/mungekey --verbose
fi
clush -P -b -w @roles:nodes -c /etc/munge/munge.key
clush -P -b -w @roles:nodes 'chown munge /etc/munge/munge.key'


echo "\n->Activate and start the service on both server and client "
chmod +x /etc/rc.d/rc.munge
/etc/rc.d/rc.munge start
clush -P -b -w @roles:nodes "chmod +x /etc/rc.d/rc.munge" 2>/dev/null
clush -P -b -w @roles:nodes "/etc/rc.d/rc.munge start" 2>/dev/null
echo  "\n->Testing on server ..."
munge -n
munge -n | unmunge
#munge -n | ssh sala43 unmunge
remunge # for performance check
