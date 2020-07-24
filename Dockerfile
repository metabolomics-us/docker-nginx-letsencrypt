FROM nginx:1.15-alpine

RUN apk add inotify-tools certbot openssl ca-certificates

WORKDIR /opt

COPY includes/entrypoint.sh nginx-letsencrypt
COPY includes/certbot.sh certbot.sh
COPY includes/default.conf /etc/nginx/conf.d/default.conf
COPY includes/ssl-options/ /etc/ssl-options

RUN chmod +x nginx-letsencrypt && \
    chmod +x certbot.sh 

ENTRYPOINT ["./nginx-letsencrypt"]
