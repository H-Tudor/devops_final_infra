# Kubernets Configurations

The kubernetes configuration is not functional as i was not able to deploy keycloak to cloud via the official operator

I have structured the k8s dependencies in the order of stack levels (keycloak db, keycloak, backend, frontend).

## Infrastructure

Locally I manged to raise the Postgres DB & Keycloak Instance via the operator but the cloud deployment failed.

## Services

Backend and Frontend configurations are stock helm configurations with unguarded secrets - not even locally tested given the keycloak domain constraint