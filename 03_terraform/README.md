# Terraform Service Deployment

The devops_final services (keycloak, backend and frontend) can be deployed to cloud, and for this project the cloud of choice was Google thus the entire terraform config is written for google

## Terraform Config

Terraform state is kept in a bucket at the project level and each service has its own bucket folder.
The project, region and bucket is configurable at the level of each service but has not yet been optimized to use tfvars -> known issue.

Currently there are 3 service:
- keycloak: consisting of a cloud sql instance (with user and db) and a cloud run instance (with domain, secrets and repo / image)
- backend: consisting of a cloud run instance (with domain, secrets and repo / image)
- frontend: consisting of a cloud run instance (with domain, secrets and repo / image)

## Continuous Deployment

This repo and more specifically this terraform configuration is imported for each service (backend and frontend) deploy by the github actions workflow and based on the service name the correct terraform folder is selected.

For running in a CD pipeline you would need a serivce account with access rights to at least the following resources:

- artifact registry writer: for pushing the new container images
- cloud storage: for storing the state
- service account user: run terraform actions
- secret manager %: get secret contents
- dns %: get, create and destroy dns entries
- cloud run %: get, create and destroy instances
- cloud sql %: get, create and destroy instances, database and users 


## Instance Management

These services are configured as cloud run instances with minimum instances left to default which is zero, thus after a while they need will take a while to start thus service might be initially unavailable for the first user in a batch -> this can be optimized with additional costs

The keycloak data is persisted in a Postgres Cloud SQL, and by default the instance is configured as a low-scale sandbox in the keycloak module.

The DB instance takes around 10 minutes to provision and deploy, and only after that will the keycloak instance start the deployment process.

## Service Domains

Keycloak uses domains as part of its checks, thus this terraform assumes a domain in Cloud DNS, in the target project and where each service expects to be able to access the other services via the domain.

For each service domain aquisition in GCP takes around 15 - 20 minutes until domain becomes available, but this applies only for the initial deployment, and in the subsequent deployments targeting only the update of the image hash will only take at most a minute. 

## Secrets

Each service has a couple of secrets required, and their name is is configurable in the service variables; below you will find the list of variables and their meaning. You will need
to create them ahead of time.

**Keycloak**:

- database.config.password_secret: the password of the db user 
- service.instance.admin_password_secret: the default password for the admin user

**Backend**:

- keycloak.client_secret: the secret configured in the keycloak backend realm for the client_id
- llm.secret: the secret key used to connect to the llm provider

**Frontend**:

- keycloak.client_secret: the secret configured in the keycloak frontend realm for the client_id
- backend.auth.client_secret: the secret configured in the keycloak backend realm for the client_id
- backend.auth.user_secret: the password configured for the app-user in the keycloak backend realm
- service.instance.cookie_secret: the secret used to secure the auth cookie

## Known issues

- no secret env variables in cloud run 
- missing terraform to configure the cloud prerequisites (domain, service accounts)
- missing terraform to configure the keycloak realm
- missing global cold deploy automation
- use of public ip for db access instead of a private connection