#!/bin/bash

export PBS_PASSWORD='FooFoo'
export PBS_REPOSITORY='user@pbs@pbs1.phoebe.lan:8007:storage'

apptainer exec --bind /:/mnt/sysroot ./debian-pbs-client.sif proxmox-backup-client backup root_disk.pxar:/mnt/sysroot
