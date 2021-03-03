
#!/bin/bash -e

# Kubernetes dashboard v2.1.0 released Dec 11, 2020
DASHBOARD="https://raw.githubusercontent.com/kubernetes/dashboard/v2.1.0/aio/deploy/recommended.yaml"

# --------------------------------------------------------
# Dashboard
# --------------------------------------------------------
kubectl create -f $DASHBOARD

cat <<EOF > dashboard.admin-user.yml 
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
EOF

cat <<EOF > dashboard.admin-user-role.yml 
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOF

kubectl create -f dashboard.admin-user.yml -f dashboard.admin-user-role.yml

echo "Kubectl Dashboard installed!"
echo " "
echo "1. Start a kubectl proxy"
echo "2. Open the dashboard using the link below"
echo "3. Authenticate using the provided token"
echo " "
echo "http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy"
echo " "

kubectl -n kubernetes-dashboard describe secret admin-user-token | grep ^token