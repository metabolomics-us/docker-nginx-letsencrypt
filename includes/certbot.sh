if [[ ! -f /var/www/certbot ]]; then
    mkdir -p /var/www/certbot
fi

# Iterate over provided comma-separated domains
for x in $(echo $DOMAIN | sed "s/,/ /g"); do
    certbot certonly \
        --config-dir "${LETSENCRYPT_DIR:-/etc/letsencrypt}" \
		--agree-tos \
		--domains "$x" \
		--email "$EMAIL" \
		--expand \
		--noninteractive \
		--webroot \
		--webroot-path /var/www/certbot \
		$OPTIONS || true

    if [[ -f "${LETSENCRYPT_DIR:-/etc/letsencrypt}/live/$x/privkey.pem" ]]; then
        cp "${LETSENCRYPT_DIR:-/etc/letsencrypt}/live/$x/privkey.pem" /usr/share/nginx/certificates/$x/privkey.pem
        cp "${LETSENCRYPT_DIR:-/etc/letsencrypt}/live/$x/fullchain.pem" /usr/share/nginx/certificates/$x/fullchain.pem

        # Set default certificate for single domain applications
        cp "${LETSENCRYPT_DIR:-/etc/letsencrypt}/live/$x/privkey.pem" /usr/share/nginx/certificates/privkey.pem
        cp "${LETSENCRYPT_DIR:-/etc/letsencrypt}/live/$x/fullchain.pem" /usr/share/nginx/certificates/fullchain.pem
    fi
done
