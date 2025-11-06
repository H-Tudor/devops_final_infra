http://test.keycloak.org:8080/

kubectl -n keycloak-test-2 port-forward svc/example-kc-service 8080:8080

echo "127.0.0.1 test.keycloak.org" | sudo tee -a /etc/hosts

kubectl get secret example-kc-initial-admin -o jsonpath='{.data.username}' | base64 --decode
kubectl get secret example-kc-initial-admin -o jsonpath='{.data.password}' | base64 --decode



kubectl apply -f https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/26.3.2/kubernetes/keycloaks.k8s.keycloak.org-v1.yml  
kubectl apply -f https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/26.3.2/kubernetes/keycloakrealmimports.k8s.keycloak.org-v1.yml

kubectl -n keycloak apply -f https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/26.3.2/kubernetes/kubernetes.yml   