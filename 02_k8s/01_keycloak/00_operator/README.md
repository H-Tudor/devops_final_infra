# Keycloak Operator

Install guide at: https://www.keycloak.org/operator/installation
Must be installed in target namespace
If Target namespace != keycloak you must do the patch as shown below

How to install operator

Target Namespace: 

```sh
curl -LO https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/26.3.2/kubernetes/keycloaks.k8s.keycloak.org-v1.yml
curl -LO https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/26.3.2/kubernetes/keycloakrealmimports.k8s.keycloak.org-v1.yml

kubectl apply -f keycloaks.k8s.keycloak.org-v1.yml -f keycloakrealmimports.k8s.keycloak.org-v1.yml
kubectl apply -n keycloak -f kubernetes.yml
kubectl patch clusterrolebinding keycloak-operator-clusterrole-binding --type='json' -p='[{"op": "replace", "path": "/subjects/0/namespace", "value":"devops-final"}]'
kubectl rollout restart -n devops-final Deployment/keycloak-operator
```