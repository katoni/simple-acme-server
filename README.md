This Docker image is based on the awesome [smallstep/cli](https://github.com/smallstep/cli) and [smallstep/certificates](https://github.com/smallstep/certificates) by [smallstep](https://smallstep.com).

# Getting started
```
$ docker run --name ca.internal --restart unless-stopped -v step:/home/step -d katoni/simple-acme-server
```

Download Root CA from container:
```
$ docker cp ca.internal:/home/step/certs/root_ca.crt .
```

Install the Root CA into your Trusted Root Certification Authorities store.

Containers in the same network now can access the ACME server: https://ca.internal/acme/development/directory.

## Access from another container

Example with Traefik reverse proxy:
```
services:
  traefik:
    image: traefik
    command:
      - "--log.level=DEBUG"
      - "--providers.docker=true"
      - "--entrypoints.http.address=:80"
      - "--certificatesResolvers.internal.acme.email=your-email@your-domain.org"
      - "--certificatesResolvers.internal.acme.httpChallenge=true"
      - "--certificatesResolvers.internal.acme.httpChallenge.entryPoint=http"
      - "--certificatesResolvers.internal.acme.caServer=https://ca.internal/acme/development/directory"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./ca.pem:/ca.pem
    environment:
      LEGO_CA_CERTIFICATES: /ca.pem
```

*Note: Docker Desktop (since version 1.12.1) [recognizes certs](https://docs.docker.com/docker-for-windows/faqs/#how-do-i-add-custom-ca-certificates) stored under Trust Root Certification Authorities or Intermediate Certification Authorities.
However, there appears to be an issue ([docker/for-win#4804](https://github.com/docker/for-win/issues/4804)), so we have to manually mount the root CA.
We use `LEGO_CA_CERTIFICATES` to configure lego to use our custom CA certificate.*

## Credits

https://smallstep.com/blog/private-acme-server/
