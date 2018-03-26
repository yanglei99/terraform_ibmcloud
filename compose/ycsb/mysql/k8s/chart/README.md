### YCSB workload 

A YCSB workload Chart for Kubernetes


## Install Chart
To install the Chart into your Kubernetes cluster

```bash
helm install --namespace "ycsb" -n "ycsb" .
```

After installation succeeds, you can get a status of Chart

```bash
helm status "ycsb"
```

If you want to delete your Chart, use this command
```bash
helm delete  --purge "ycsb"
```

### Install Chart with specific resource size
By default, this Chart will run YCSB workload with CPU 1 vCPU and 2Gi of memory.
To update the settings, edit `values.yaml`

