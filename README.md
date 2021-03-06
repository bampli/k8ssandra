# k8ssandra
### K8ssandra Starter

Create a Kubernetes Cluster with [K8ssandra](https://github.com/k8ssandra/k8ssandra), an open-source distribution of Apache Cassandra that includes API services and operational tooling.

The cluster includes several pods to provide:

- Apache Cassandra Database.
- Prometheus and Grafana for monitoring.
- Stargate collection of API endpoints for Cassandra.
- Reaper to schedule and manage repairs in Cassandra.
- Medusa manager for backup & restore of K8ssandra clusters.

## Google Cloud Platform

Tests Ok with GKE 3-node clusters powered by:

- **test 1**: e2-standard-4 / 16G-ram / 4-vcpu / 32G-disk.
- **test 2**: n1-standard-2 / 7.5G-ram / 2-vcpu / 32G-disk.

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
    helm repo update

    helm install -f k8ssandra.yaml k8ssandra k8ssandra/k8ssandra
```

### First Checks

```bash
    kubectl get cassandradatacenters
    kubectl describe CassandraDataCenter dc1 | grep "Cassandra Operator Progress:"
    export USER=$(kubectl get secret k8ssandra-superuser -o jsonpath="{.data.username}" | base64 --decode ; echo)
    export PASS=$(kubectl get secret k8ssandra-superuser -o jsonpath="{.data.password}" | base64 --decode ; echo)

    # Ex: username=k8ssandra-superuser  password=bzpSkKwcIeGMUcZoP6fZ

    kubectl exec -it k8ssandra-dc1-default-sts-0 -c cassandra -- nodetool -u $USER -pw $PASS status
    kubectl exec -it k8ssandra-dc1-default-sts-0 -c cassandra -- nodetool -u $USER -pw $PASS ring
    kubectl exec -it k8ssandra-dc1-default-sts-0 -c cassandra -- nodetool -u $USER -pw $PASS info
```

### Port Forwarding

The kubectl port-forward command does not require an Ingress/Traefik to work.

```bash
    kubectl port-forward svc/k8ssandra-grafana 9191:80 &
    kubectl port-forward svc/prometheus-operated 9292:9090 &
    kubectl port-forward svc/k8ssandra-reaper-reaper-service 9393:8080 &
```

The K8ssandra services are now available at:

- Prometheus: http://127.0.0.1:9292
- Grafana: http://127.0.0.1:9191
- Reaper: http://127.0.0.1:9393/webui

Grafana default is admin/secret. Change Grafana admin password directly with *grafana-cli*:

```bash
    kubectl exec -it k8ssandra-grafana-5c6d5b8f5f-fcwcl -c grafana -- /bin/sh
    grafana-cli admin reset-admin-password admin
```
Helm also shows initial config:

```bash
    helm show values k8ssandra/k8ssandra | grep "adminUser"
    helm show values k8ssandra/k8ssandra | grep "adminPassword"
```

### Ingress

TODO: Ingress.

```bash
    helm repo add traefik https://helm.traefik.io/traefik
    helm repo update

    helm install traefik traefik/traefik -n traefik --create-namespace -f traefik.values.yaml
```

### WIP

```bash

    export TRAEFIK_POD=$(kubectl get pods -n traefik --selector "app.kubernetes.io/name=traefik" --output=name)

    kubectl port-forward -n traefik $TRAEFIK_POD 9000:9000

    export ADDRESS=localhost

    helm upgrade -f k8ssandra.yaml k8ssandra k8ssandra/k8ssandra --set ingress.traefik.enabled=true

    helm upgrade -f k8ssandra.yaml k8ssandra k8ssandra/k8ssandra \
    --set ingress.traefik.enabled=true \
    --set ingress.traefik.repair.host=repair.${ADDRESS} \
    --set ingress.traefik.monitoring.grafana.host=grafana.${ADDRESS} \
    --set ingress.traefik.monitoring.prometheus.host=prometheus.${ADDRESS}

    kubectl port-forward svc/k8ssandra-grafana 9191:80 & kubectl port-forward svc/prometheus-operated 9292:9090 & kubectl port-forward svc/k8ssandra-reaper-reaper-service 9393:8080 &

```