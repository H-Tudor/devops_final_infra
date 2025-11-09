# Keycloak Deployment Documentation

Keycloak is an open-source authentification provider that is sponsored by CNCF and is cloud-agnostic,
being able to run in most environments, from bare metal to local dockers and to k8s. Its primary usecase
consists of OpenID Connect (OIDC) compatible interfaces (an OAuth2 improvement), but one of the tennents
of OAuth2 is validating agains a resource owner's domain, thus you must be able to handle redirects to
specified domains.

## Keycloak Build Optimizations

Keycloak comes as both an install kit as well as a container image. But its deployment consists of 2 steps:
- build
- run

In the development mode, the build stage is run again and again, causing a prolongued boot time, but in
a production environment it causes un-needed downtime, thus for production is heavily advised that
you take the base image, set the kwnow constants and then create a new image with the code already built
and run it with the `--optimized` flag

Also, keycloak allows exporting the realm (tennant) configurations to json files.

You can find my *optimized* image in the [00_keycloak_setup](../00_keycloak_setup/) folder along with the
realms exports 

## Keycloak in docker compose

Locally via docker you might be able to pull something like editing the `/etc/hosts` to match
the target domain against the local IP or a more refined solution would be to use traefik.

While nginx knows how to handle a request that comes targeted to a domain and can route based on that
to a service, you would still need to resolve at the browser level the domain (via `/etc/hosts`), but 
with traefik it *somehow* knows to automatically intercept requests to the target domain, but you have
to properly configure the yaml files describing the domains.

But the next hurdle comes in the form of endpoint resolution. The OIDC standard assumes that a provider
can provide a description of itself containing among other things the endpoints on which a redirect url can
requested or a code can be exchanged into a token. And most OIDC client interfaces adhear to this principle
to such extent that the login abstraction automatically calls the redirect url endpoint then the code
exchange endpoint - as provided by the provider.

Why is this relevant? Because it sets the primary constraint of the deployment!

Keycloak must be configured with a hostname in the production version, but that hostname must match the domain
on which the keycloak will be publicly served, but also it must be privately accessible to the clients.

In docker compose you can achieve this my using traefik (as mentioned above) and aliasing the keycloak instance
as the fake domain, but beware that in the hostname (thus the fake domain) you must also include a port, and both
keycloak and traefik want to use the 8080 port by default, thus you need to change the keycloak http port

You can find my docker compose configuration in the [01_compose](../01_compose/) folder. Keep in mind that the environment
variables are not stored in the docker compose but gitignored files in the env folder (create if it does not exists) with 
templates in the env example folder

## Keycloak in kubernetes

Since keycloak is sponsored by CNCF (Cloud Native Computing Foundation) it is also mean to be used in the cloud,
and for that, besides containerization, the keycloak is also k8s compatible and more - has an oficially maintained
kubernetes operator which streamlines the procces of deployment - in vanilla kubernetes.

But when trying to deploy to a cloud provider, when trying to route external traffic to the pods, the provider will
attempt to ensure that the pods are active by performing its own healthchecks irrespective of the operator declared
healthchecks on the defautl port (8080). The catch is that keycloak (in its latest versions) has moved the health checks
to port 9000 behind the metrics and health service. and more than that, the keycloak operator - being cloud agnostic - 
does not define google specific health check probe resources, and google expects such resources to be mounted via
annotation to the ingress - which the operator abstracts.

You might attempt to create a custom ingress and create a custom probe with a much delayed start given keycloak's delayed
start even in prod mode.

I failed at this last point in the given time constrained thus I abbandoned the idea.


## Keycloak in cloud run

Keycloak is a statefull resource thus ill-fitted to be run as a cloud run - but as a last resort i works with a catch.

I managed to automate a cloud run + cloud sql deployment (with some room for future improvements) but the catch mentioned before
is that on resource destruction and reinstantiation you loose your data and have to manually reimport the realms and create the users

Another issue with the cloud run deployment is the 30 minute cold init time (10 for the DB, 20 for the domain mapping) 
