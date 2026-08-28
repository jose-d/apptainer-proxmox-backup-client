# apptainer-proxmox-backup-client

An Apptainer image containing `proxmox-backup-client` for systems where installing
the native Proxmox package is inconvenient.

The image deliberately follows the current Proxmox Backup Server 3 client package
for Debian 12 (Bookworm). The previously deployed image on Enki contained client
3.0.2; the live PBS server reported version 3.4.8. At the time this automation was
added, the Bookworm repository supplied client 3.4.7. The newer Debian 13 repository
contains client 4.x, which is intentionally not used until the server is upgraded
and compatibility is reviewed.

## Build in GitHub Actions

The workflow is manual only:

1. Open **Actions** and select **Build PBS client SIF**.
2. Click **Run workflow**.
3. Leave **Publish a GitHub Release** disabled for a normal test build.

Each run builds the latest Bookworm PBS 3 client for `amd64`, tests the image, and
uploads a 30-day artifact. The artifact contains:

- the versioned `.sif` image;
- a SHA-256 checksum;
- build metadata and the installed package manifest;
- the image inspection output and embedded definition file.

GitHub also creates a build-provenance attestation for the SIF. The workflow rejects
a future PBS client major version instead of silently producing an incompatible
image.

To publish a release, run the workflow with **Publish a GitHub Release** enabled and
provide a new calendar tag such as `v2026.08.28`. Release publishing is still
button-triggered; pushing a tag does not start a build.

## Build locally

```sh
sudo apptainer build \
  --build-arg BUILD_VERSION=local \
  --build-arg BUILD_REVISION="$(git rev-parse HEAD)" \
  debian-pbs-client.sif debian-pbs-client.def
```

## Use

Configure repository credentials as described in the
[Proxmox backup client documentation](https://pbs.proxmox.com/docs/backup-client.html):

```sh
export PBS_REPOSITORY='user@pbs@pbs.server.com:8007:storage-name'
export PBS_PASSWORD='replace-me'
./debian-pbs-client.sif version
./debian-pbs-client.sif snapshot list
```

For restores, bind a host directory into the container:

```sh
mkdir -p /mnt/restore
apptainer exec --bind /mnt/restore:/mnt/restore debian-pbs-client.sif /bin/bash
proxmox-backup-client restore host/example/2026-08-28T00:00:00Z root.pxar /mnt/restore
```

## Install on Enki

Deployment is intentionally manual. Download and verify the Actions artifact, then
replace `/root/pbs/debian-pbs-client.sif` during a maintenance window. Keep the old
image until a backup and restore test succeeds with the new one.
