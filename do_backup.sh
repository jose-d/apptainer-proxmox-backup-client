#!/bin/bash

export PBS_PASSWORD='FooFoo'
export PBS_REPOSITORY='user@pbs@pbs1.phoebe.lan:8007:storage'
PBS_IMAGE='/root/backup/debian-pbs-client.sif'

apptainer exec --bind /:/mnt/sysroot ${PBS_IMAGE} proxmox-backup-client backup root_disk.pxar:/mnt/sysroot
