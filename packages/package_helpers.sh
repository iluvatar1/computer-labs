function install_pkg {
    echo "Installing package : ${1} ..."
    TDIR="tmp/downloads/${1}"
    mkdir -p ${TDIR} &&
	cd ${TDIR} &&
	wget -c "${3}" && 
	tar xf "${1}".tar.gz &&
	cd "${1}" && 
	wget -c "${4}" && 
	bash "${1}".SlackBuild &&
	/sbin/installpkg /tmp/"${1}"-"${5}"-x86_64-1_SBo.tgz &&
	cd ../../../ 
}


