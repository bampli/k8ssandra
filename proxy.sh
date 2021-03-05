
export PASS=$(echo $(kubectl get secret k8ssandra-superuser -o yaml | grep -m1 -Po 'password: \K.*') | base64 -d && echo "")
export STUDIO_POD_NAME=$(kubectl get pods --namespace studio -l "app=studio-lb" -o jsonpath="{.items[0].metadata.name}")
echo "user=k8ssandra-superuser password=$PASS"
echo "pod="$STUDIO_POD_NAME
# Proxy
kubectl port-forward svc/k8ssandra-grafana 9191:80 &
kubectl port-forward svc/prometheus-operated 9292:9090 &
kubectl port-forward svc/k8ssandra-reaper-reaper-service 9393:8080 &
kubectl port-forward $STUDIO_POD_NAME 9091:9091 --namespace studio &
kubectl port-forward svc/k8ssandra-dc1-service 9042:9042