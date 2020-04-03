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

echo "---Starting...---"
chown -R ${UID}:${GID} /opt/scripts
dbus-uuidgen > /var/lib/dbus/machine-id
if [ ! -d /var/run/dbus ]; then
	mkdir -p /var/run/dbus
fi
chown -R ${UID}:${GID} /var/run/dbus/
chmod -R 770 /var/run/dbus/
chown -R ${UID}:${GID} ${DATA_DIR}
su ${USER} -c "/opt/scripts/start-server.sh"