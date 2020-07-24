# Docker nginx-letsencrypt

A single container to allow an nginx container to be up and running with an ACME certificate with a single command.

A simple `docker-compose` script can be used to run this image with the proper configureations:

```
version: "3"

services:
  nginx:
    image: eros.fiehnlab.ucdavis.edu/nginx-letsencrypt:latest
    ports:
      - 80:80
      - 443:443
    environment:
      - DOMAIN=$URL
      - EMAIL=$EMAIL
    volumes:
      - "certs:/etc/letsencrypt"
      - "default.conf:/etc/nginx/conf.d/default.conf"
    restart: always
```

This requires including a custom nginx configuration for the website based on:

```
server {
  listen 80;
  server_name some_name;
  
  location /.well-known/acme-challenge/ {
    root /var/www/certbot;
  }

  location / {
    return 301 https://$host$request_uri;
  }      
}

server {
    listen 443 ssl;
    server_name some_name;

    ssl_certificate /usr/share/nginx/certificates/fullchain.pem;
    ssl_certificate_key /usr/share/nginx/certificates/privkey.pem;
    
    include /etc/ssl-options/options-nginx-ssl.conf;
    ssl_dhparam /etc/ssl-options/ssl-dhparams.pem;

    location / {
      root /usr/share/nginx/html;
    }
}
```
