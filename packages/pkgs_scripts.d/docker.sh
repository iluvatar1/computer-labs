#!/bin/bash

echo "This script installs docker"

if command -v docker 2>/dev/null; then
    echo "Docker already installed."
    exit 0
fi

echo "Checking if this is the nis server to create the docker group ..."
IS_SERVER=1
if grep -q "+:" /etc/group; then 
    IS_SERVER=0
fi
echo "IS_SERVER: $IS_SERVER"

echo "Creating docker group (do not forget to add the given user to the group: usermod -a -G docker <your_username>) ..."
if [ "$IS_SERVER" == "1" ] && ! grep -q 281 /etc/group; then
    echo "Creating docker group on server ..."
    groupadd -r -g 281 docker
else
    echo "Group already exists or this is a client and you should create the docker group on the server"
fi

# sbopkg gives error, will use static builds
echo "Using static builds ..."
wget -c -nc https://github.com/docker/compose/releases/download/v2.29.2/docker-compose-linux-x86_64 -O /usr/bin/docker-compose
chmod +x /usr/bin/docker-compose

cd /tmp
wget -c -nc https://download.docker.com/linux/static/stable/x86_64/docker-27.2.0.tgz
tar xvf docker-27.2.0.tgz
cp docker/* /usr/bin/
echo "Done copying static files"

# From https://slackbuilds.org/repository/15.0/system/docker/
echo "Creating rc file ..."
cat <<EOF > /etc/rc.d/rc.docker
#!/bin/sh
#
# Docker startup script for Slackware Linux
#
# Docker is an open-source project to easily create lightweight, portable,
# self-sufficient containers from any application.

PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin

BASE=dockerd

UNSHARE=/usr/bin/unshare
DOCKER=/usr/bin/\${BASE}
DOCKER_PIDFILE=/var/run/\${BASE}.pid
DOCKER_LOG=/var/log/docker.log
DOCKER_OPTS=""

# Default options.
if [ -f /etc/default/docker ]; then
  . /etc/default/docker
fi

# Check if docker is present.
if [ ! -x \${DOCKER} ]; then
  echo "\${DOCKER} not present or not executable"
  exit 1
fi

docker_start() {
  echo "Starting \${BASE} ..."
  # If there is an old PID file (no dockerd running), clean it up.
  if [ -r \${DOCKER_PIDFILE} ]; then
    if ! ps axc | grep \${BASE} 1> /dev/null 2> /dev/null ; then
      echo "Cleaning up old \${DOCKER_PIDFILE}."
      rm -f \${DOCKER_PIDFILE}
    fi
  fi

  nohup "\${UNSHARE}" -m -- \${DOCKER} -p \${DOCKER_PIDFILE} \${DOCKER_OPTS} >> \${DOCKER_LOG} 2>&1 &
}

docker_stop() {
  echo -n "Stopping \${BASE} ..."
  if [ -r \${DOCKER_PIDFILE} ]; then
    DOCKER_PID=\$(cat \${DOCKER_PIDFILE})
    kill \${DOCKER_PID}
    while [ -d /proc/\${DOCKER_PID} ]; do
      sleep 1
      echo -n "."
    done
  fi
  echo " done"
}

docker_restart() {
  docker_stop
  sleep 1
  docker_start
}

docker_status() {
  if [ -f \${DOCKER_PIDFILE} ] && ps -o cmd \$(cat \${DOCKER_PIDFILE}) | grep -q \${BASE} ; then
    echo "Status of \${BASE}: running"
  else
    echo "Status of \${BASE}: stopped"
  fi
}

case "\$1" in
  'start')
    docker_start
    ;;
  'stop')
    docker_stop
    ;;
  'restart')
    docker_restart
    ;;
  'status')
    docker_status
    ;;
  *)
    echo "Usage: \$0 {start|stop|restart|status}"
esac

exit 0

EOF

chmod +x /etc/rc.d/rc.docker

echo "Done. Start the service using /etc/rc.d/rc.docker start"
