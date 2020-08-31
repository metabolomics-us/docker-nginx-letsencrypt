#!/bin/sh
# Create a self signed default certificate, so Ngix can start before we have
# any real certificates.

# Iterate over provided comma-separated domains
for x in $(echo $DOMAIN | sed "s/,/ /g"); do
    # Ensure we have folders available
    if [[ ! -f /usr/share/nginx/certificates/$x/fullchain.pem ]]; then
        mkdir -p /usr/share/nginx/certificates/$x
    fi

    if [[ ! -f /usr/share/nginx/certificates/$x/cert.crt ]]; then
        openssl genrsa -out /usr/share/nginx/certificates/$x/privkey.pem 4096
        openssl req -new -key /usr/share/nginx/certificates/$x/privkey.pem -out /usr/share/nginx/certificates/$x/cert.csr -nodes -subj \
            "/C=PT/ST=World/L=World/O=${x:-ilhicas.com}/OU=Ilhicas/CN=${x:-ilhicas.com}/EMAIL=${EMAIL:-info@ilhicas.com}"
        openssl x509 -req -days 365 -in /usr/share/nginx/certificates/$x/cert.csr -signkey /usr/share/nginx/certificates/$x/privkey.pem -out /usr/share/nginx/certificates/$x/fullchain.pem
    fi

    # Set default certificate for single domain applications
    cp /usr/share/nginx/certificates/$x/privkey.pem /usr/share/nginx/certificates/privkey.pem
    cp /usr/share/nginx/certificates/$x/fullchain.pem /usr/share/nginx/certificates/fullchain.pem
done

# Send certbot Emission/Renewal to background
$(while :; do /opt/certbot.sh; sleep "${RENEW_INTERVAL:-12h}"; done;) &

# Check for changes in the certificate (i.e renewals or first start)
$(while inotifywait -e close_write /usr/share/nginx/certificates; do nginx -s reload; done) &

nginx -g "daemon off;"
