# Getting started
Start service with Docker Compose:
```
$ docker-compose up -d
```

Download Root CA from container:
```
$ docker cp ca.internal:/home/step/certs/root_ca.crt .
```

Install the Root CA into your Trusted Root Certification Authorities store.

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
    networks:
      default:
      ca:
    environment:
      LEGO_CA_CERTIFICATES: /ca.pem

networks:
  ca:
    external:
      name: ca
```
