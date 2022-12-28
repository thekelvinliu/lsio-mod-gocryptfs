# lsio-mod-gocryptfs

add [gocryptfs] to a linuxserver docker container to mount encrypted directories and files

## usage

this docker mod requires fuse, meaning docker containers must be privileged and have access to `/dev/fuse` on the host.
for example with docker compose:

```yaml
---
services:
  code:
    image: lscr.io/linuxserver/code-server:latest
    environment:
      DOCKER_MODS: "thekelvinliu/lsio-mod-gocryptfs:latest"
      PGID: 1000
      PUID: 1000
    privileged: true
    devices:
      - /dev/fuse:/dev/fuse
    volumes:
      - /path/to/cipher/directories:/encrypted
      - ./config/gocryptfs:/gocryptfs
```

## configuration

the main config file for this docker mod is a csv file, which is expected at `/gocryptfs/mounts.csv` by default.
this location can be changed using the `GOCRYPTFS_MOUNTS_FILE` environment variable.
the csv enables multiple gocryptfs cipher directories to be mounted at once.
each line in the file corresponds to a single gocryptfs mount and contains:

- `name`: used in the service name that manages the mount
- `cipherdir`: path to gocryptfs-encrypted cipher directory
- `mountpoint`: path to gocryptfs mountpoint
- `passfile`: path to a plaintext file containing the gocryptfs password

here's an example csv file that defines two mounts:

```csv
name,cipherdir,mountpoint,passfile
company-secrets,/encrypted/company-secrets,/decrypted/secrets,/gocryptfs/company-secrets-pass
personal-documents,/encrypted/personal-documents,/decrypted/docs,/gocryptfs/personal-documents-pass
```

once the gocryptfs services start,
`/decrypted/secrets` will contain the unencrypted directories and files of the encrypted `/encrypted/company-secrets`.
and similarly,
`/decrypted/docs` will contain the unencrypted directories and files from `/encrypted/personal-documents`.

[gocryptfs]: https://github.com/rfjakob/gocryptfs
