# Snapped CPA Sample Code Command

**NOTE**: as of Aug 6 2024 this snap requires a custom build of snapd
containing the `intel-qat` interface.

## Building the snap

First install the `snapcraft` snap if you have not already:

```
sudo snap install --classic snapcraft
lxd init --auto
```

Now you can build snapped [cpa_sample_code](https://intel.github.io/quickassist/qatlib/sample_code.html?highlight=cpa_sample#running-the-sample-code):

```
snapcraft
```

## Installing the snap

```
sudo snap install --dangerous cpa-sample-code-snap_24.02.0_amd64.snap
```

## Connecting to the snap interface

To access QAT resources on the host, connect to the interface with:

```
sudo snap connect cpa-sample-code-snap:intel-qat
```

The application also needs to create threads, set task affinity, and
perform other process control tasks. Connect to the `process-control`
interface in order to obtain permissions for these tasks:

```
sudo snap connect cpa-sample-code-snap:process-control
```

## Running the snap

Note the application takes several minutes to complete. Runtime
parameters for the application can be found [here](https://intel.github.io/quickassist/GSG/2.X/sampleapplications.html#qat-2-0-gsg-sample-code-parameters).

```
cpa-sample-code-snap
```

To run with `strace`:

```
snap run --strace="-e trace=openat" cpa-sample-code-snap
```
