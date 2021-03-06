#!/bin/bash

CERTIFICATE_DIR=/etc/nginx/ssl
MIN_VALID_DAYS=7
ACCOUNT_KEY=/etc/letsencrypt/account.key
ACME_DIR=/srv/letsencrypt
PATH=$PATH:$(dirname $0)
ACME_TINY=$(which acme-tiny)
if [ -z "$ACME_TINY" ]; then
    ACME_TINY=$BIN_DIR/acme_tiny.py
fi 

BIN_DIR=$(dirname $0)

test -e /etc/letsencrypt/acme_update.conf && source /etc/letsencrypt/acme_update.conf

DATE=$(date +%Y%m%d%H%M%S)

DEBUG=
CHANGED=0

for CSR in $CERTIFICATE_DIR/*.csr; do
    CRT=${CSR%.*}.crt
    if [ -e $CRT ]; then
        if openssl x509 -in $CRT -noout -checkend $(( 60 * 60 * 24 * $MIN_VALID_DAYS )) >/dev/null 2>&1; then
            continue
        fi
    fi
    $DEBUG $ACME_TINY --quiet --account-key $ACCOUNT_KEY --csr $CSR  --acme-dir /srv/letsencrypt/ > $CRT.new || continue
    echo "Renewed certificate for ${CSR%.*}"
    $DEBUG curl -s https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.pem >> $CRT.new
    if [ ! -e $CERTIFICATE_DIR/old ]; then mkdir $CERTIFICATE_DIR/old; fi;
    $DEBUG mv $CRT $CRT.old.$DATE
    $DEBUG mv $CRT.old.$DATE $CERTIFICATE_DIR/old
    $DEBUG mv $CRT.new $CRT
    CHANGED=1
done

if [ $CHANGED -eq 1 ]; then
    /usr/sbin/nginx -s reload
fi
