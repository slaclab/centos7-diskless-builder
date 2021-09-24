#!/bin/sh
STARTUP_DIR=/afs/slac.stanford.edu/g/lcls/epics/iocCommon

# Wait until AFS is mounted
wait_for_mount()
{
    WAIT_TIME=$1
    i=0

    while [[ $i -le $WAIT_TIME ]]
    do
        ((i = i + 1))
        if [ ! -d "$STARTUP_DIR" ] || [ $(hostname) = "localhost" ]; then
            sleep 1
            echo $i "seconds has passed. hostname = " $(hostname)
        else
            break
        fi
    done
}

wait_for_mount 30

if [ ! -d "$STARTUP_DIR" ]; then
    echo "Had to mount manually"
    mount -a
    wait_for_mount 60
fi

if [ $(hostname) = "localhost" ]; then
    echo "Wait for hostname to be set by DHCP"
    wait_for_mount 120
fi

if [ -d "$STARTUP_DIR" ] && [ $(hostname) != "localhost" ]; then
    /afs/slac.stanford.edu/g/lcls/epics/iocCommon/$(hostname)/startup.cmd
else
    echo "startup.cmd file not found. Check if AFS was successfully mounted."
fi
