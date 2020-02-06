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
  echo "#######################################"
  echo ""
}

function pattern_not_present()
{
    local result=1 # assume forced or not present
    if [[ $FORCE -eq 0 ]]; then
	if [ x""!=x"$(grep ${1} ${2} )" ]; then
	    result=0
	fi
    fi
    echo $result
}

function command_exists()
{
    #command -v "$1" &> /dev/null
    hash "$1" &> /dev/null
}

