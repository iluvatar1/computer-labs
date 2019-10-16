function usage() 
{
    echo "USAGE: "
    echo "config_server.sh DIR LINUX_FLAVOR[=SLACKWARE]"
    echo "DIR          : Where to find the model config files"
    echo "LINUX_FLAVOR : UBUNTU or SLACKWARE , in capital"
    echo "NOTE: Ubuntu not working currently"
}

# global functions
function backup_file() 
{
    if [ -e "$1" ]; then
	cp -v "$1" "$1".orig-$(date +%F--%H-%M-%S)
    fi
}

function copy_config()
{
    mfile="$1"
    bfile="$2"
    backup_file "$bfile"
    cp -vf "$mfile" "$bfile"
}

function start_msg()
{
  echo "####################################### "
  echo "# START: $1"
}

function end_msg()
{
  echo "# DONE: $1"
  echo "#######################################\n "
}
