#!/bin/bash

FIRMWARE_TYPES=("bios" "efi") # firmware
HARDDISK_NAMES=("sda" "nvme0n1")
#FIRMWARE_TYPES=("efi") # firmware
#HARDDISK_NAMES=("nvme0n1")
declare -A HARDDISK_P1
HARDDISK_P1["sda"]="sda1"
HARDDISK_P1["nvme0n1"]="nvme0n1p1"

ISO_URL="/opt/slackware64-current-install-dvd.iso"


# ##############################################################
# Create vbox base machines
function create_vbox_machines() {
    for fw in ${FIRMWARE_TYPES[@]}; do
	for hdn in ${HARDDISK_NAMES[@]}; do
	    LOG_FILE="create_vbox_machines-$fw-$hdn.log"
	    FIRMWARE=$fw HARDDISK_NAME=$hdn bash scripts/create_vbox_machine.sh | tee $LOG_FILE
	    sleep 2
	done
    done
}

function wait_for_process() {
  local process_pattern="$1"
  echo "Waiting for process: $1"
  
  while pgrep -f "$process_pattern" &>/dev/null; do
    sleep 5
  done
}


# ##############################################################
# Install base system
function install_base_systems() {
    echo
    echo "Installing base system:"
    LOG_FILE=${2:-install_base_systems}
    for fw in ${FIRMWARE_TYPES[@]}; do
	for hdn in ${HARDDISK_NAMES[@]}; do
	    if [[ "$fw" == "bios" ]] && [[ "$hdn" == "nvme0n1" ]]; then continue; fi
	    LOG_FILE="create_vbox_machines-${fw}-${hdn}.log"
	    CONFIG_NAME=config/cfg-A-install-${fw}-${hdn}.json
	    machine_name="base_slack_machine_${fw}_${hdn}"
	    snapshot="After slackware package install"
	    echo "Processing: $machine_name"
	    # create config
	    if VBoxManage snapshot "${machine_name}" list | grep -q "${snapshot}"; then
		echo "Snapshot \"${snapshot}\" already exists in machine, continuing ..."
		continue
	    fi
	    EXTRA_STEP=""
	    if [[ "$fw" == "efi" ]]; then EXTRA_STEP="<wait><enter>"; fi # TODO Check it
	    cat <<EOF > $CONFIG_NAME
{
    "ISO_URL" : "$ISO_URL",
    "MACHINENAME" : "base_slack_machine_{{user \`FIRMWARE\`}}_{{user \`HARDDISK_NAME\`}}",
    "CPUS" : "2",
    "HEADLESS" : "false",
    "HARDDISK" : "${hdn}",
    "HARDDISKP1" : "${HARDDISK_P1[$hdn]}",
    "EXTRA_STEP" : "{EXTRA_STEP}"
}
EOF
	    # run packer
	    PACKER_LOG=1 packer build -var FIRMWARE=$fw -var HARDDISK_NAME=$hdn -var-file $CONFIG_NAME slackware64-current-A-install.json | tee $LOG_FILE &
	    sleep 10
	done
    done
    wait_for_process "packer"
}


# ##############################################################
# Finish installation
function finish_install() {
    echo
    echo "Finishing base system installation:"
    for fw in ${FIRMWARE_TYPES[@]}; do
	for hdn in ${HARDDISK_NAMES[@]}; do
	    if [[ "$fw" == "bios" ]] && [[ "$hdn" == "nvme0n1" ]]; then continue; fi
	    LOG_FILE="finish_install-${fw}-${hdn}.log"
	    CONFIG_NAME=config/cfg-B-finish_install-${fw}-${hdn}.json
	    machine_name="base_slack_machine_${fw}_${hdn}"
	    snapshot="After finished install"
	    echo "Processing: $machine_name"
	    # Check if snapshot is already built
	    if VBoxManage snapshot "${machine_name}" list | grep -q "${snapshot}"; then
		echo "Snapshot \"${snapshot}\" already exists in machine, continuing ..."
		continue
	    fi
	    # create config
	    cat <<EOF > $CONFIG_NAME
{
    "MACHINENAME" : "base_slack_machine_{{user \`FIRMWARE\`}}_{{user \`HARDDISK_NAME\`}}"
}
EOF
	    # run packer
	    PACKER_LOG=1 packer build -var FIRMWARE=$fw -var HARDDISK_NAME=$hdn -var-file $CONFIG_NAME slackware64-current-B-finish_install.json | tee $LOG_FILE &
	    sleep 10
	done
    done
    wait_for_process "packer"
}


# ##############################################################
# Initial setup to get a ready slackware system
# TODO: Add github auth to clone private repo
function initial_setup() {
    echo
    echo "Performing initial setup:"
    for fw in ${FIRMWARE_TYPES[@]}; do
	for hdn in ${HARDDISK_NAMES[@]}; do
	    if [[ "$fw" == "bios" ]] && [[ "$hdn" == "nvme0n1" ]]; then continue; fi
	    LOG_FILE="initial_setup-${fw}-${hdn}.log"
	    CONFIG_NAME=config/cfg-C-initial_setup-${fw}-${hdn}.json
	    machine_name="base_slack_machine_${fw}_${hdn}"
	    snapshot="After initial config"
	    echo "Processing: $machine_name"
	    # Check if snapshot is already built
	    if VBoxManage snapshot "${machine_name}" list | grep -q "${snapshot}"; then
		echo "Snapshot \"${snapshot}\" already exists in machine, continuing ..."
		continue
	    fi
	    # create config
	    cat <<EOF > $CONFIG_NAME
{
    "MACHINENAME" : "base_slack_machine_{{user \`FIRMWARE\`}}_{{user \`HARDDISK_NAME\`}}",
    "PROXY" : "",
    "HEADLESS" : "false"    
}
EOF
	    # run packer
	    PACKER_LOG=1 packer build -var FIRMWARE=$fw -var HARDDISK_NAME=$hdn -var-file $CONFIG_NAME slackware64-current-C-initial_setup.json | tee $LOG_FILE &
	    sleep 10
	done
    done
    wait_for_process "packer"
}


# ##############################################################
# NOTE: Skipping install software


# ##############################################################
# Provision: Configuring as client or server
# TODO Actual ansible configuration
function provision() {
    MYTYPE=${1:-client}
    echo
    echo "Provisioning $MYTYPE: ..."
    for fw in ${FIRMWARE_TYPES[@]}; do
	for hdn in ${HARDDISK_NAMES[@]}; do
	    if [[ "$fw" == "bios" ]] && [[ "$hdn" == "nvme0n1" ]]; then continue; fi
	    LOG_FILE="provision-${fw}-${hdn}.log"
	    CONFIG_NAME=config/cfg-E-provision-${fw}-${hdn}-${MYTYPE}.json
	    machine_name="base_slack_machine_${fw}_${hdn}"
	    snapshot="$MYTYPE configured"
	    echo "Processing: $machine_name"
	    # Check if snapshot is already built
	    if VBoxManage snapshot "${machine_name}" list | grep -q "${snapshot}"; then
		echo "Snapshot \"${snapshot}\" already exists in machine, continuing ..."
		continue
	    fi
	    # create config
    #"provision_script":"{{env `HOME`}}/repos/computer-labs/configurations/config_computer_room_box.sh", # now is ansible
	    source .env_$MYTYPE
	    cat <<EOF > $CONFIG_NAME
{
    "TYPE":"$MYTYPE",
    "MACHINENAME" : "base_slack_machine_{{user \`FIRMWARE\`}}_{{user \`HARDDISK_NAME\`}}",
    "PROXY" : "",
    "HEADLESS" : "false",
    "attach_snapshot": "After initial config",
    "snapshot_name": "{{user \`TYPE\`}} configured",
    "output_dir": "/opt/box_{{user \`TYPE\`}}_{{user \`FIRMWARE\`}}_{{user \`HARDDISK_NAME\`}}",
    "ROOT_PASSWORD": "$ROOT_PASSWORD",
    "SKIP_EXPORT" : "true"
}
EOF
	    # run packer
	    PACKER_LOG=1 packer build -var FIRMWARE=$fw -var HARDDISK_NAME=$hdn -var-file $CONFIG_NAME slackware64-current-E-provision.json | tee $LOG_FILE &
	    sleep 10
	done
    done
    wait_for_process "packer"
}



# ##############################################################
# Exporting with clonezila
function vbox_to_img() {
    declare -A MACADDRESS
    MACADDRESS["efinvme0n1"]="080027D4CA14"
    MACADDRESS["biossda"]="080027D4CA20"
    MACADDRESS["efisda"]="080027D4CA21"
    
    MYTYPE=${1:-client}
    echo
    echo "Exporting to clonezilla img -> $MYTYPE: ..."
    for fw in ${FIRMWARE_TYPES[@]}; do
	for hdn in ${HARDDISK_NAMES[@]}; do
	    if [[ "$fw" == "bios" ]] && [[ "$hdn" == "nvme0n1" ]]; then continue; fi
	    LOG_FILE="vbox_to_img-${fw}-${hdn}.log"
	    CONFIG_NAME=config/cfg-clonezilla-vbox-to-img-${fw}-${hdn}-${MYTYPE}.json
	    machine_name="base_slack_machine_${fw}_${hdn}"
	    echo "Processing: $machine_name"
	    # create config
	    source .env_$MYTYPE
	    source .env_server
	    cat <<EOF > $CONFIG_NAME
{
    "TYPE":"$MYTYPE",
    "MACHINENAME" : "base_slack_machine_{{user \`FIRMWARE\`}}_{{user \`HARDDISK_NAME\`}}",
    "CLONEZILLA_ISO": "/opt/Clonezilla/clonezilla-live-3.2.0-5-amd64.iso",
    "BRIDGE_INTERFACE": "eth1",
    "SSH_SERVER_IP": "192.168.10.1",
    "SSH_SERVER_PORT": "443",
    "SSH_DIR": "partimag",
    "SSH_USER": "root",
    "SSH_PASSWORD": "${ROOT_SERVER_PASSWORD}",
    "HEADLESS" : "false",
    "PROXY" : "",
    "ATTACH_SNAPSHOT": "${MYTYPE} configured",
    "MACADDRESS" : "${MACADDRESS[$fw$hdn]}"
}
EOF
	    # run packer
	    PACKER_LOG=1 packer build -var FIRMWARE=$fw -var HARDDISK_NAME=$hdn -var-file $CONFIG_NAME clonezilla-vbox-to-img.json | tee $LOG_FILE &
	    sleep 10
	done
    done
    wait_for_process "packer"
}




# ##############################################################
# MAIN
#create_vbox_machines

install_base_systems

finish_install

initial_setup

#install_packages

provision

vbox_to_img
