#+TITLE: HPC utils howto
* Munge (auth for HPC - Needed by slurm)
  Follow https://moc-documents.readthedocs.io/en/latest/hpc/Slurm.html
  This script will presetup and install munge on all clients and
  server. If needed, edit =/var/yp/Makefile= to reduce the minimim UID
  to include munge uid. This is script assumes that clusterssh is
  working and is meant to be run in the server
  #+begin_src shell :tangle munge.sh
    echo "\n->Create a munge user in the server (NIS propagates this to all nodes)"
    export MUNGEUSER=991
    groupadd -g $MUNGEUSER munge
    useradd  -m -c "MUNGE Uid 'N' Gid Emporium" -d /var/lib/munge -u $MUNGEUSER -g munge  -s /sbin/nologin munge  

    echo "\n->Possibly install munge and fix permissions and startup script ..."
    BNAME=/tmp/munge_tmp00.sh
    cat <<\EOF > $BNAME
    if ! hash munge; then
       echo "Installing munge"
       source /root/.bashrc  
       sbopkg -B -i munge
    fi
    for dbase in /var/run/ /var/log/ /etc/; do
	chown munge $dbase/munge
    done
    #Maybe fix the script by using the following exec command in line 182:
    sed -i '182s/.*/ERRMSG=$(sudo -u "$USER" $DAEMON_EXEC $DAEMON_ARGS 2>\&1)/' /etc/rc.d/rc.munge   
    #=ERRMSG=$(sudo -u "$USER" $DAEMON_EXEC $DAEMON_ARGS 2>&1)=
    chmod +x /etc/rc.d/rc.munge
    EOF
    bash $BNAME
    clush -P -b -w @roles:nodes -c $BNAME 2>/dev/null 
    clush -P -b -w @roles:nodes "bash $BNAME" 2>/dev/null 

    echo "\n->Create a munge key on the server and propagate it ... "
    if [ ! -f /etc/munge/munge.key ]; then
	sudo -u munge /usr/sbin/mungekey --verbose
	clush -P -b -w @roles:nodes -c /etc/munge/munge.key
	clush -P -b -w @roles:nodes 'chown munge /etc/munge/munge.key'
    fi

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
  #+end_src

* Slurm (resource manager)
  *NOTE*: hwloc MUST BE INSTALLED *WITHOUT* opencl
  #+begin_src shell :tangle slurm.sh
    echo "-> [S] Configuring slurm user on server (propagated by nis) ..."
    export SLURMUSER=992  
    groupadd -g $SLURMUSER slurm  
    useradd  -m -c "SLURM workload manager" -d /var/lib/slurm -u $SLURMUSER -g slurm  -s /bin/bash slurm

    echo "-> [S/C] Fix some files/folders and permissions slurm"
    FNAME=/tmp/slurm_00.sh
    cat <<EOF > $FNAME
    mkdir /var/spool/slurmd
    chown slurm: /var/spool/slurmd
    mkdir /var/spool/slurm
    chown slurm: /var/spool/slurm
    chmod 755 /var/spool/slurmd
    touch /var/log/slurmd.log
    chown slurm: /var/log/slurmd.log
    EOF
    bash $FNAME
    clush -P -b -w @roles:nodes -c $FNAME  2>/dev/null
    clush -P -b -w @roles:nodes  "bash $FNAME"  2>/dev/null

    echo "-> [S] Configure slurm"
    if [ ! -f /etc/slurm.conf ]; then
	cp /etc/slurm/slurm.conf.example /etc/slurm.conf
	sed -i 's/ClusterName.*/ClusterName=salafis/' /etc/slurm.conf
	sed -i 's/ControlMachine.*/ControlMachine=serversalafis/' /etc/slurm.conf
    fi

    echo "-> [S] Extract nodes info and add to slurm config "
    if [ ! -f /etc/slurm.conf ]; then
	echo "# Node info "
	clush -N -P -b -w @roles:nodes 'slurmd -C | grep -v UpTime' >> /etc/slurm/slurm.conf
    fi

    echo "-> [S/C] Propagate slurm config to nodes"
    clush -P -b -w @roles:nodes -c /etc/slurm/slurm.conf  2>/dev/null

    echo "-> [S] Specify partitions (update as needed - 2022-02-08)"
    if [ ! -f /etc/slurm.conf ]; then
    cat <<EOF >> /etc/slurm.con
    # PARTITIONS 2022-02-08
    PartitionName=login Nodes=serversalafis Default=NO MaxTime=1 State=UP
    PartitionName=2threads Nodes=sala[15,30] Default=YES MaxTime=INFINITE State=UP
    PartitionName=4threads Nodes=sala[3,4,10,24-28] Default=NO MaxTime=INFINITE State=UP
    PartitionName=6threads Nodes=sala[41] Default=NO MaxTime=INFINITE State=UP
    PartitionName=8threads Nodes=sala[9,16,18-20,31-33] Default=NO MaxTime=INFINITE State=UP
    PartitionName=12threads Nodes=sala[37-39] Default=NO MaxTime=INFINITE State=UP
    PartitionName=16threads Nodes=sala[43] Default=NO MaxTime=INFINITE State=UP
    EOF
    fi

    echo "-> [S] Creating accounting files ..."
    touch /var/log/slurm_jobacct.log /var/log/slurm_jobcomp.log
    chown slurm: /var/log/slurm_jobacct.log /var/log/slurm_jobcomp.log

    echo "-> [S/C] Starting slurm on all machines"
    chmod +x /etc/rc.d/rc.slurm
    /etc/rc.d/rc.slurm start
    clush -P -b -w @roles:nodes "chmod +x /etc/rc.d/rc.slurm"
    clush -P -b -w @roles:nodes "/etc/rc.d/rc.slurm start"

    echo "-> -------------- DONE"
    #+end_src

* Glusterfs (To create parallel storage)
- https://docs.gluster.org/en/latest/Quick-Start-Guide/Quickstart/
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

* To check
- Node health check: https://github.com/mej/nhc
- Install all with spack
