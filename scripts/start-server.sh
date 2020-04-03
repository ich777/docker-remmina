#!/bin/bash
export XDG_CONFIG_HOME=${DATA_DIR}
export $XDG_DATA_HOME=${DATA_DIR}
export DISPLAY=:99

echo "---Preparing Server---"
chmod -R ${DATA_PERM} ${DATA_DIR}

echo "---Sleep zZz---"
sleep infinity

echo "---Starting Remmina---"
