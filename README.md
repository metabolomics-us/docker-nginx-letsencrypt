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
      - ORGANIZATION=$ORGANIZATION
    volumes:
      - "certs:/etc/letsencrypt"
      - "config/default.conf:/etc/nginx/conf.d/default.conf"
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

### Multiple Domains

For multiple domains, start by adding comma-separated domains in `docker-compose.yml`, e.g.:

```
version: "3"

services:
  nginx:
    image: eros.fiehnlab.ucdavis.edu/nginx-letsencrypt:latest
    ports:
      - 80:80
      - 443:443
    environment:
      - DOMAIN=example.com,example.net,example.org
      - EMAIL=$EMAIL
      - ORGANIZATION=$ORGANIZATION
    volumes:
      - "certs:/etc/letsencrypt"
      - "config/example.com.conf:/etc/nginx/conf.d/example.com.conf"
      - "config/example.net.conf:/etc/nginx/conf.d/example.net.conf"
      - "config/example.org.conf:/etc/nginx/conf.d/example.org.conf"
    restart: always
```

For each domain, a separate nginx configuration is also required, e.g. for `example.com.conf`:

```
server {
  listen 80;
  server_name example.com;
  
  location /.well-known/acme-challenge/ {
    root /var/www/certbot;
  }

  location / {
    return 301 https://$host$request_uri;
  }      
}

server {
    listen 443 ssl;
    server_name example.com;

    ssl_certificate /usr/share/nginx/certificates/example.com/fullchain.pem;
    ssl_certificate_key /usr/share/nginx/certificates/example.com/privkey.pem;
    
    include /etc/ssl-options/options-nginx-ssl.conf;
    ssl_dhparam /etc/ssl-options/ssl-dhparams.pem;

    location / {
      root /usr/share/nginx/html;
    }
}
```

and similarly for the other domains.  

Each domain requests a separate configuration, so please note that too many domains may run into LetsEncrypt rate limiting issues.