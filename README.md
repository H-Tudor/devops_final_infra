# Devops Final Infrastructure

This repo contains Infrastructure-as-Code part of the Devops Final project 

## About

In order to run the devops final project you need to orchestrate frontend and backend instances as well as to
ensure external providers such as Keycloak and OpenAI are available and this must be done both locally
and in remote environments such as GCP.

Thus this repository contains the infrastructure configurations of the frontend, backend and keycloak instances
accross multiple deployment environments.

## Keycloak - A special case

The most complex part of this infrastructure is the keycloak deployment which i had some trobles with and i
documented that journy in [this file](./00_docs/keycloak.md)

## Overal Setup

For local / development deployments use the `01_compose` folder

For prod deployments use the `03_terraform` folder and deploy each service (frontend, backend and keycloak) individually

For Improving the base keycloak image, check the `00_keycloak` folder (see the keycloak documentation file mentioned before
for more details)

A keycloak configuration is in works in the `02_keycloak` folder but it is not functional as of now.