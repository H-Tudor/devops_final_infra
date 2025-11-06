create test cert:

openssl req -subj '/CN=test.keycloak.org/O=Test Keycloak./C=US' -newkey rsa:2048 -nodes -keyout key.pem -x509 -days 365 -out certificate.pem

create cert secret:
kubectl create secret tls example-tls-secret --cert certificate.pem --key key.pem

create db secret

kubectl create secret generic keycloak-db-secret \
  --from-literal=username=testuser \
  --from-literal=password=testpassword

create admin secret

kubectl create secret generic  keycloak-example-kc-credential \
  --from-literal=username=admin \
  --from-literal=password=password \
  -n devops-final