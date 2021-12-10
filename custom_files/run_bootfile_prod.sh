#!/bin/bash
STARTUP_DIR_LCLS=/usr/local/lcls/epics/iocCommon
STARTUP_DIR_FACET=/usr/local/facet/epics/iocCommon

# Wait until NFS is mounted
wait_for_mount()
{
    WAIT_TIME=$1
    i=0

    while [[ $i -le $WAIT_TIME ]]
    do
        ((i = i + 1))
        if [ ! -d "$STARTUP_DIR_LCLS" ] || [ ! -d "$STARTUP_DIR_FACET" ] ||  [ $(hostname) = "localhost" ]; then
            sleep 1
            echo $i "seconds has passed. hostname = " $(hostname)
        else
            break
        fi
    done
}

wait_for_mount 30

if [ ! -d "$STARTUP_DIR_LCLS" ] || [ ! -d "$STARTUP_DIR_FACET" ]; then
    echo "Had to mount manually"
    mount -a
    wait_for_mount 60
fi

if [ $(hostname) = "localhost" ]; then
    echo "Wait for hostname to be set by DHCP"
    wait_for_mount 120
fi

if [ $(hostname) = "localhost" ]; then
    echo "hostname not set after 120 seconds. startup.cmd will not be loaded"
fi

if [ -e "$STARTUP_DIR_LCLS/$(hostname)/startup.cmd" ]; then
    $STARTUP_DIR_LCLS/$(hostname)/startup.cmd
elif [ -e "$STARTUP_DIR_FACET/$(hostname)/startup.cmd" ]; then
    $STARTUP_DIR_FACET/$(hostname)/startup.cmd
else
    echo "startup.cmd file not found. Check if NFS was successfully mounted."
fi
