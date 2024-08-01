# Intel QAT Snapped Applications

Here we show examples of how to build snapped applications
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

## Building custom snapd

The `intel-qat` snap interface can be used by cloning the appropriate fork
of snapd, and then building and installing the snap.

First install the `snapcraft` snap if you have not already:

```
sudo snap install --classic snapcraft
lxd init --auto
```

Now you're ready to build and install a custom snapd:

```
git clone https://github.com/frenchwr/snapd.git
cd snapd
snapcraft
sudo snap install --dangerous snapd_*_amd64.snap
```

Note, building the snap inside the Canonical Locker may fail
due to some sort of GPG issue that I have not investigated deeply.
For now, I have resorted to building the snap on my local machine
and then `scp`'ing the snap to a machine on Locker.

Verify that you are now running the custom snapd:

```
snap list
```

More details about hacking on snapd can be found
[here](https://github.com/canonical/snapd/blob/master/HACKING.md).
