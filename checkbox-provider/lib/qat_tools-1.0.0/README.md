# qat-tools

Collection of tools for Intel QAT (Quick Assist Technology)

To list all available devices:

```
sudo qatctl list
```

To show configuration of QAT devices:

```
sudo qatctl status
```

To show only data for a set of counters:

```
sudo qatop  --devices 70:00.0 --counters util_pke
```

To output data in terminal:

```
sudo qatop --record  --devices 70:00.0 --counters util_pke exec_pke
```
