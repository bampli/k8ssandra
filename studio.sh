#!/bin/bash -e
# dse-studio-deployment
# See https://raw.githubusercontent.com/vishnuc95/Scripts-Kubernetes-Yaml-/master/dse-studio-deployment.yaml

kubectl create ns studio

cat <<EOF | kubectl -n studio apply -f -
apiVersion: apps/v1beta2
kind: Deployment
metadata:
  name: studio-lb
spec:
  selector:
    matchLabels:
      app: studio-lb
  template:
    metadata:
      labels:
        app: studio-lb
    spec:
      containers:
      - name: studio-lb
        image: datastax/dse-studio:latest
        env:
        - name: DS_LICENSE
          value: accept
        ports:
        - containerPort: 9091
          name: studio-gui-port
        - containerPort: 61620
          name: port-61620
---
apiVersion: v1
kind: Service
metadata:
  name: studio-lb
spec:
  ports:
  - name: http
    port: 9091
    protocol: TCP
    targetPort: 9091
    nodePort: 
  loadBalancerIP: 
  selector:
    app: studio-lb
  type: LoadBalancer
EOF

# run these commands in the same shell
#export STUDIO_POD_NAME=$(kubectl get pods --namespace studio -l "app=studio-lb" -o jsonpath="{.items[0].metadata.name}")
#kubectl --namespace studio port-forward $STUDIO_POD_NAME 9091
#kubectl -n studio describe secret $STUDIO_POD_NAME

#echo $(kubectl get secret k8ssandra-superuser -o yaml | grep -m1 -Po 'password: \K.*') | base64 -d && echo ""
#export PASS=$(echo $(kubectl get secret k8ssandra-superuser -o yaml | grep -m1 -Po 'password: \K.*') | base64 -d && echo "")
#echo "k8ssandra-superuser password=$PASS"