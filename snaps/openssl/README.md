# Snapped OpenSSL Command

**NOTE**: as of Aug 1 2024 this snap requires a custom build of snapd
containing the `intel-qat` interface.

## Building the snap

First install the `snapcraft` snap if you have not already:

```
sudo snap install --classic snapcraft
lxd init --auto
```

Now you can build snapped openssl:

```
snapcraft
```

## Installing the snap

```
sudo snap install --dangerous openssl-snap_3.0.13_amd64.snap
```

## Connecting to the interface

```
sudo snap connect openssl-snap:intel-qat
```

## Running the snap

```
openssl-snap
```

For example:

```
openssl-snap speed -engine qatengine -elapsed -async_jobs 72 rsa2048
```

To run with `strace`:

```
snap run --strace="-e trace=openat" openssl-snap speed -engine qatengine -elapsed -async_jobs 72 rsa2048
```
