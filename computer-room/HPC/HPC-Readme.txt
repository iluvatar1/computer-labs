#+TITLE: HPC utils howto

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
  tar xf munge.tar.gz
  cd munge
  wget https://github.com/dun/munge/releases/download/munge-0.5.14/munge-0.5.14.tar.xz
  VERSION=0.5.14 bash munge.SlackBuild
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
* Slurm (resource manager)
- Create a slurm user
  #+begin_src shell
groupadd -g 311 slurm
useradd -u 311 -d /var/lib/slurm -s /bin/false -g slurm slurm
  #+end_src
  If needed, edit =/var/yp/Makefile= to reduce the minimim UID to include slurm
  uid.
- Install deps:
  =slpkg -s sbo numactl hwloc rrdtool=
- On each node and master:
  #+begin_src shell
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
* Glusterfs (To create parallel storage)
