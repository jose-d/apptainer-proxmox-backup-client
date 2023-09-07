# apptainer-proxmox-backup-client

Purpose: When we need to run [proxmox-backup-client](https://pbs.proxmox.com/docs/backup-client.html) on different system than particular Debian version supported by Proxmox maintainers.

## build

```
sudo apptainer build ./debian-pbs-client.sif ./debian-pbs-client.def
```
## use

### setup repo-specific variables

```
export PBS_REPOSITORY='user@pbs@pbs.server.com:8007:storage-name'
export PBS_PASSWORD="FooFoo"
```
### restore data

first get shell in container, bind some available directory into it:

`apptainer exec --bind /mnt/restore:/mnt/restore ./debian-pbs-client.sif /bin/bash`

show available snapshots:

```
Apptainer> proxmox-backup-client snapshot list
storing login ticket failed: $XDG_RUNTIME_DIR (`/run/user/0`) must be accessible by the current user (error: No such file or directory (os error 2))
+===============================+===========+=========================================+
| snapshot                      |      size | files                                   |
+===============================+===========+=========================================+
| host/fe1/2023-09-07T13:31:47Z | 9.056 GiB | catalog.pcat1 index.json root_disk.pxar |
+-------------------------------+-----------+-----------------------------------------+
...
+===============================+===========+=========================================+
Apptainer>
```

mount snapshot to /tmp/mp

`mkdir /tmp/mp`

`proxmox-backup-client mount host/fe1/2023-09-07T13:31:47Z root_disk.pxar /tmp/mp`

restore file:

```
cp /tmp/mp/etc/auto.net /mnt/restore/
```


### run proxmox-backup-client benchmark

`proxmox-backup-client` is in `%runscript` of recipe, so image can be executed directly:

```
$ ./debian-pbs-client.sif benchmark
Uploaded 139 chunks in 5 seconds.
Time per request: 37928 microseconds.
TLS speed: 110.58 MB/s
SHA256 speed: 2093.88 MB/s
Compression speed: 754.62 MB/s
Decompress speed: 1021.54 MB/s
AES256/GCM speed: 2338.86 MB/s
Verify speed: 680.62 MB/s
+===================================+=====================+
| Name                              | Value               |
+===================================+=====================+
| TLS (maximal backup upload speed) | 110.58 MB/s (9%)    |
+-----------------------------------+---------------------+
| SHA256 checksum computation speed | 2093.88 MB/s (104%) |
+-----------------------------------+---------------------+
| ZStd level 1 compression speed    | 754.62 MB/s (100%)  |
+-----------------------------------+---------------------+
| ZStd level 1 decompression speed  | 1021.54 MB/s (85%)  |
+-----------------------------------+---------------------+
| Chunk verification speed          | 680.62 MB/s (90%)   |
+-----------------------------------+---------------------+
| AES256 GCM encryption speed       | 2338.86 MB/s (64%)  |
+===================================+=====================+
$
```
