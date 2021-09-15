#!/bin/bash
set HOSTNAME=hostname
STARTUP_DIR=/afs/slac.stanford.edu/g/lcls/epics/iocCommon/$HOSTNAME

for i in {1..60}
do
  if [ ! -d "$STARTUP_DIR" ]; then
    sleep 1
  else
    break
  fi
done

if [ -d "$STARTUP_DIR" ]; then
  /afs/slac.stanford.edu/g/lcls/epics/iocCommon/$HOSTNAME/startup.cmd
else
  echo "startup.cmd file not found. Check if afs was successfully mounted."
fi
