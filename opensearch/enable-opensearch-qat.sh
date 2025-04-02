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

systemctl restart snap.opensearch.daemon.service
