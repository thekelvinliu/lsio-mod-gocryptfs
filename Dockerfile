# build static gocryptfs binary from source
FROM golang:1.19-bullseye AS build-gocryptfs
COPY ldflags.patch /tmp/ldflags.patch
WORKDIR /build
RUN git clone --single-branch https://github.com/rfjakob/gocryptfs /build \
  && git apply /tmp/ldflags.patch \
  && /build/build-without-openssl.bash

# install fusermount binary from apt
FROM debian:bullseye AS install-fusermount
RUN apt-get update \
  && apt-get install --no-install-recommends --yes fuse3 \
  && rm -rf /var/lib/apt/lists/*

# prepare root layer
FROM scratch AS prepare-root
COPY root /root
COPY --from=build-gocryptfs /build/gocryptfs /root/usr/local/bin/gocryptfs
COPY --from=install-fusermount /bin/fusermount /root/usr/local/bin/fusermount

# final single layer image
FROM scratch
COPY --from=prepare-root /root /
