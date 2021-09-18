#!/bin/bash
set HOSTNAME=hostname
STARTUP_DIR=/usr/local/lcls/epics/iocCommon/$HOSTNAME

# Wait at most 1 minute to see if NFS is mounted
for i in {1..60}
do
  if [ ! -d "$STARTUP_DIR" ]; then
    sleep 1
  else
    break
  fi
done

if [ -d "$STARTUP_DIR" ]; then
  /usr/local/lcls/epics/iocCommon/$HOSTNAME/startup.cmd
else
  echo "startup.cmd file not found. Check if NFS was successfully mounted."
fi
