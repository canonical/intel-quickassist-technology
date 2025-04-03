#!/bin/bash

#
# This script enable QAT on top of opensearch 1.18 (https://github.com/canonical/opensearch-snap/tree/benchmark-qat)
#

if [ "$EUID" -ne 0 ]
then echo "Please run as root"
     exit
fi

### Setup QAT devices (VF - Virtual Function)
# Enable SR-IOV & VF with the script from qatlib-service
# Configure all devices in dc (compression/decompression) mode
apt install -y qatlib-service
systemctl stop qat
systemctl disable qat

cat - > /etc/sysconfig/qat <<'EOF'
ServicesEnabled=dc
EOF
/usr/sbin/qat_init.sh

# QAT devices access to snap_daemon
setfacl -m group:snap_daemon:rw /dev/vfio/devices/*
setfacl -m group:snap_daemon:rw /dev/vfio/*

### Opensearch intel-qat snap interface
snap connect opensearch:intel-qat

### Connect some needed interfaces because of manual installation
# of the opensearch snap
snap connect opensearch:sys-fs-cgroup-service
snap connect opensearch:log-observe
snap connect opensearch:system-observe
snap connect opensearch:mount-observe
snap connect opensearch:process-control
snap connect opensearch:hardware-observe

### Custom codecs plugin security policy

CUSTOM_CODECS_PLUGIN_POLICY="/var/snap/opensearch/current/usr/share/opensearch/plugins/opensearch-custom-codecs/plugin-security.policy"

cat - > ${CUSTOM_CODECS_PLUGIN_POLICY} <<'EOF'
grant codeBase "${codebase.zstd-jni}" {
  permission java.lang.RuntimePermission "loadLibrary.*";
};

grant codeBase "${codebase.qat-java}" {
  permission java.lang.RuntimePermission "loadLibrary.*";
  permission org.opensearch.secure_sm.ThreadPermission "modifyArbitraryThread";
};
EOF

### Memory settings

# the amount of memory that can be locked -> unlimited
mkdir -p /etc/systemd/system/snap.opensearch.daemon.service.d/
SYSTEMD_DROPIN="/etc/systemd/system/snap.opensearch.daemon.service.d/config_name.conf"
cat >${SYSTEMD_DROPIN} <<EOF
[Service]
LimitMEMLOCK=infinity
EOF
systemctl daemon-reload

### Setup opensearch
snap run opensearch.setup          \
  --node-name cm0                     \
  --node-roles cluster_manager,data   \
  --tls-priv-key-root-pass root1234   \
  --tls-priv-key-admin-pass admin1234 \
  --tls-priv-key-node-pass node1234   \
  --tls-init-setup yes

snap start opensearch.daemon
echo "Wait for opensearch to start up"
sleep 20
snap run opensearch.security-init --tls-priv-key-admin-pass=admin1234

systemctl restart snap.opensearch.daemon.service
