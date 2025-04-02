This folder contains instructions and scripts to enable QAT support for Opensearch snap v1.18.

As of now, there are multiple reasons that prevent opensearch from using QAT devices:
- VFIO devices access since opensearch is running with normal user
- Opensearch custom codecs security policy prevents qat-java plugin to properly function.
- MemLock limit setting is too low 
- Opensearch snap lacks the `intel-qat` interface to be able to access VFIO devices
- Opensearch snap lacks QAT libraries (`libqatzip3`)

We will tackle these issues by:
- providing a forked opensearch
  this fork lives in the branch [`benchmark-qat`](https://github.com/canonical/opensearch-snap/tree/benchmark-qat) of the
  opensearch-snap repository.
- providing a bash script to bring in some fixes to fix some security policy and memlock limit configuration.

Here are the steps to enable QAT support for Opensearch snap on your platform:

## Build and install opensearch snap

You have to follow public documentation to build the opensearch snap locally.
Once you have the built snap, you must install it on the platform.

Here are a sample of steps to build the snap with `multipass`

```bash
$ sudo snap install multipass
$ export SNAPCRAFT_BUILD_ENVIRONMENT=multipass
$ git clone -b benchmark-qat https://github.com/canonical/opensearch-snap.git
$ cd opensearch-snap
$ snapcraft
```

And install the snap:

```bash
$ sudo snap install --dangerous ./opensearch_2.18.0_amd64.snap 
```

## Run enablement script

```bash
$ sudo ./enable-opensearch-qat.sh
```

# Quick test

To quickly test the QAT support, we can create an index with `qat_deflate` codec.

## Setup opensearch

```bash
$ sudo snap run opensearch.setup          \
  --node-name cm0                     \
  --node-roles cluster_manager,data   \
  --tls-priv-key-root-pass root1234   \
  --tls-priv-key-admin-pass admin1234 \
  --tls-priv-key-node-pass node1234   \
  --tls-init-setup yes

$ sudo systemctl restart snap.opensearch.daemon.service
$ echo "Wait for opensearch to start up"
$ sleep 20
$ sudo snap run opensearch.security-init --tls-priv-key-admin-pass=admin1234
```

## Create an index with QAT codec

```bash
$ sudo cp /var/snap/opensearch/current/etc/opensearch/certificates/node-cm0.pem ./
$ curl --cacert ./node-cm0.pem -XPUT "https://admin:admin@localhost:9200/qat_index" -H 'Content-Type:application/json' -d'
{
  "settings": {
    "index": {
      "codec.qatmode" : "hardware",
      "codec": "qat_deflate"
    }
  }
}'
```
