BASEBOX=Slack64
VIRTUALBOXNAME=Slackware64-14.2

echo "Processing virtual machine : $VIRTUALBOXNAME"

echo "Packaging the box : $BASEBOX"
rm -rf ${BASEBOX}.box ~/.vagrant.d/boxes/${BASEBOX}
vagrant package --base ${VIRTUALBOXNAME}
mv package.box ${BASEBOX}.box

echo "Testing the box"
vagrant box add ${BASEBOX} ${BASEBOX}.box
rm -f Vagrantfile 2> /dev/null
vagrant init ${BASEBOX}
vagrant up

