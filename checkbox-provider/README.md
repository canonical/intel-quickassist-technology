## Checkbox provider for Intel® QuickAssist Technology (Intel® QAT)

To build the checkbox provider snap, goto the directory `checkbox-provider` and run:

```bash
snapcraft
```

To install the provider snap:

```bash
sudo snap install --dangerous ./checkbox-qat-classic_2.0_amd64.snap
```

To run the tests:

```bash
sudo checkbox-qat-classic.test-runner-automated
```




