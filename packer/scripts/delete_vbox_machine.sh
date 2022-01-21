MACHINENAME=${MACHINENAME:-base_slack_machineTEST}
echo "Deleting MACHINENAME: ${MACHINENAME}"
VBoxManage controlvm $MACHINENAME poweroff
VBoxManage unregistervm --delete $MACHINENAME
