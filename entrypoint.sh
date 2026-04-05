#!/bin/bash

# Auto-update game server via SteamCMD if SRCDS_APPID is set
if [ -n "${SRCDS_APPID}" ]; then
    ./steamcmd/steamcmd.sh +force_install_dir /home/container +login anonymous +app_update ${SRCDS_APPID} ${SRCDS_BETAID} ${SRCDS_BETAPASS} validate +quit
fi

# Replace startup variables
MODIFIED_STARTUP=$(echo -e ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')
echo ":/home/container$ ${MODIFIED_STARTUP}"

# Run the server
eval ${MODIFIED_STARTUP}
