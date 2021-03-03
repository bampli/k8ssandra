# k8ssandra
K8ssandra Starter

Create a Kubernetes Cluster with [K8ssandra](https://github.com/k8ssandra/k8ssandra), an open-source distribution of Apache Cassandra that includes API services and operational tooling.

The cluster includes several pods to provide:

- Apache Cassandra Database.
- Prometheus and Grafana for monitoring.
- Stargate collection of API endpoints for Cassandra.
- Reaper to schedule and manage repairs in Cassandra.
- Medusa manager for backup & restore of K8ssandra clusters.

## Google Cloud Platform

### GKE Cluster

Create a GKE 3-node cluster powered by e2-standard-4 / 16G-ram / 4-vcpu / 32G-disk.

### Storage Class

Create a storage class for Cassandra nodes, [this](https://github.com/datastax/cass-operator#creating-a-storage-class) is a storage class for using SSDs in GKE.

```bash
    kubectl apply -f gke-storage.yaml
```

*gke-storage.yaml*
```yaml
    apiVersion: storage.k8s.io/v1
    kind: StorageClass
    metadata:
    name: server-storage
    provisioner: kubernetes.io/gce-pd
    parameters:
    type: pd-ssd
    replication-type: none
    volumeBindingMode: WaitForFirstConsumer
    reclaimPolicy: Delete
```

### Helm Charts

K8ssandra is distributed as a collection of Helm charts powered by [Cassandra Operator](https://github.com/datastax/cass-operator) pre-installed and configured for running with a minimal set of resources.

```bash
    helm repo add k8ssandra https://helm.k8ssandra.io/stable
    helm repo add traefik https://helm.traefik.io/traefik
    helm repo update

    helm install -f k8ssandra.yaml k8ssandra k8ssandra/k8ssandra
```