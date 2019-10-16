function usage() 
{
    echo "USAGE: "
    echo "config_server.sh DIR TARGET[SERVER|CLIENT]"
    echo "DIR    : Where to find the model config files"
    echo "TARGET : SERVER or CLIENT "
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

function pattern_not_present
{
    if [ $FORCE -eq 1 ]; then
	return 1
    fi
    if [ x""==x"$(grep ${1} ${2} )" ]; then
	return 1
    else
	return 0
    fi
}
