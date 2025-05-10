I created a custom configuration file (e.g., cluster.yaml) to define specific cluster parameters, such as the number of nodes.
Here's an example for creating a multi-node cluster:
```
# cluster.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
  - role: worker
```

Then create the cluster with:
`kind create cluster --config kind-config.yaml`
