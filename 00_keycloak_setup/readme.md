# Custom Keycloak Image

```sh
docker run --rm
    \ -p 8080:8080
    \ --env-file env/local.env
    \ --name test
    \ <image>
    \ start --optimized
```
