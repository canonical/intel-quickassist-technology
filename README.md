# Intel QAT Snapped Applications

This repo contains examples of how to build snapped applications
with QAT support using a custom snap interface for QAT.

**NOTE**: the snap interface is still under development (as of Aug 1 2024),
so testing requires a custom snapd build containing the new interface.

## Host requirements

* Intel Xeon Processor with QAT support
* Ubuntu 24.04
* Install **qatlib-service** in order to run applications in managed mode

```
sudo apt install qatlib-service -y
```

* To run QAT-enabled apps as a non-root user, run the following:

```
sudo usermod -a -G qat $USER # log out after in order for changes to take effect
sudo chown root:qat /dev/qat_adf_ctl
sudo chmod 660 /dev/qat_adf_ctl
```
