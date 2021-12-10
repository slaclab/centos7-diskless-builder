# Custom configuration files

## Description

This directory contains local configuration files which are added to the root image during the generation process.

## Configuration File Description

| Configuration file                                    | Description
|-------------------------------------------------------|----------------
| 90-nproc.conf                                         | Increases the maximum number of allowed threads as some EPICS IOCs ususally violate the default amount.
| epics.conf                                            | Increases the maximum RT priority and memlock for user laci or flaci to run IOCs with priority scheduling of tasks.
| create-users.sh                                       | Script to create users with specific SLAC's needs.
| run_bootfile_dev.sh, run_bootfile_prod.sh             | Waits for NFS to mount, mount it manually if needed, and calls startup.cmd. One file for dev, another for prod.
| run_bootfile_dev.service, run_bootfile_prod.service   | systemd service units to call the respective shell scripts.
| slac.sh                                               | This file is copied to `etc/profile.d`. It contains shell startup code, specific to SLAC.
