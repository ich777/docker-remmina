#!/bin/bash
echo "---Checking if UID: ${UID} matches user---"
usermod -u ${UID} ${USER}
echo "---Checking if GID: ${GID} matches user---"
usermod -g ${GID} ${USER}
echo "---Setting umask to ${UMASK}---"
umask ${UMASK}

echo "---Checking for optional scripts---"
if [ -f /opt/scripts/user.sh ]; then
	echo "---Found optional script, executing---"
    chmod +x /opt/scripts/user.sh
    /opt/scripts/user.sh
else
	echo "---No optional script found, continuing---"
fi

echo "---Checking configuration for noVNC---"
novnccheck

echo "---Starting...---"
chown -R ${UID}:${GID} /opt/scripts
dbus-uuidgen > /var/lib/dbus/machine-id
if [ ! -d /var/run/dbus ]; then
	mkdir -p /var/run/dbus
fi
chown -R ${UID}:${GID} /var/run/dbus/
chmod -R 770 /var/run/dbus/
echo "---dbus cleanup---"
if [ -d ${DATA_DIR}/.dbus/session-bus ]; then
	rm -R ${DATA_DIR}/.dbus/session-bus/*
fi
chown -R ${UID}:${GID} ${DATA_DIR}

term_handler() {
	kill -SIGTERM "$(pidof remmina)"
	tail --pid="$(pidof remmina)" -f 2>/dev/null
	exit 143;
}

trap 'kill ${!}; term_handler' SIGTERM
su ${USER} -c "/opt/scripts/start-server.sh" &
killpid="$!"
while true
do
	wait $killpid
	exit 0;
done