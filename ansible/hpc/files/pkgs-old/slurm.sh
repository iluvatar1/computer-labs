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
		# remove the last two lines : linux node names as examples
		sed -i '$d' /etc/slurm.conf
		sed -i '$d' /etc/slurm.conf
		# Configure the custername
		sed -i 's/ClusterName.*/ClusterName=salafis/' /etc/slurm.conf
		sed -i 's/ControlMachine.*/ControlMachine=serversalafis/' /etc/slurm.conf
		echo "-> [S] Extract nodes info and add to slurm config "
		echo "# Node info "
		clush -N -P -b -w @roles:nodes 'slurmd -C | grep -v UpTime' >> /etc/slurm.conf
		cp /etc/slurm.conf /etc/slurm.conf-clients
		echo "-> [S] Specify partitions (update as needed - 2023-06-02)"

		cat <<EOF >> /etc/slurm.conf
# PARTITIONS 2023-06-02
#PartitionName=login	Nodes=serversalafis	Default=NO	MaxTime=1		State=UP
PartitionName=4threads	Nodes=sala[16-20]	Default=NO	MaxTime=INFINITE	State=UP
PartitionName=6threads	Nodes=sala[13-15]	Default=NO	MaxTime=INFINITE	State=UP
PartitionName=8threads	Nodes=sala[11,12]	Default=NO	MaxTime=INFINITE	State=UP
PartitionName=12threads Nodes=sala[7-10]	Default=YES	MaxTime=INFINITE	State=UP
PartitionName=16threads Nodes=sala[2-6]		Default=NO	MaxTime=INFINITE	State=UP
PartitionName=GPU	Nodes=sala[2]		Default=NO	MaxTime=INFINITE	State=UP

# # PARTITIONS 2022-02-08
#PartitionName=login Nodes=serversalafis Default=NO MaxTime=1 State=UP
#PartitionName=2threads Nodes=sala[15,30] Default=YES MaxTime=INFINITE State=UP
#PartitionName=4threads Nodes=sala[3,4,10,24-28] Default=NO MaxTime=INFINITE State=UP
#PartitionName=6threads Nodes=sala[41] Default=NO MaxTime=INFINITE State=UP
#PartitionName=8threads Nodes=sala[9,16,18-20,31-33] Default=NO MaxTime=INFINITE State=UP
#PartitionName=12threads Nodes=sala[37-39] Default=NO MaxTime=INFINITE State=UP
#PartitionName=16threads Nodes=sala[43] Default=NO MaxTime=INFINITE State=UP
EOF
	fi

	echo "-> [S/C] Propagate slurm config to nodes"
	clush -P -b -w @roles:nodes -c /etc/slurm.conf-clients --dest /etc/slurm.conf  2>/dev/null

	echo "-> [S] Creating accounting files ..."
	touch /var/log/slurm_jobacct.log /var/log/slurm_jobcomp.log
	chown slurm: /var/log/slurm_jobacct.log /var/log/slurm_jobcomp.log

	echo "-> [S/C] Restarting munge on all machines"
	/etc/rc.d/rc.munge restart
	clush -P -b -w @roles:nodes "/etc/rc.d/rc.munge restart"

	echo "-> [S/C] Starting slurm on all machines"
	chmod +x /etc/rc.d/rc.slurm
	/etc/rc.d/rc.slurm start
	clush -P -b -w @roles:nodes "chmod +x /etc/rc.d/rc.slurm"
	clush -P -b -w @roles:nodes "/etc/rc.d/rc.slurm start"

	echo "-> -------------- DONE"
