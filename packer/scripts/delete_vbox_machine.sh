MACHINENAME=${MACHINENAME:-base_slack_machine}
VBoxManage controlvm $MACHINENAME poweroff
VBoxManage unregistervm --delete $MACHINENAME
