# About
acme-update is a wrapper around acme_tiny.py to make sure all certificates are 
up-to-date. It works by looking at all certificate signing requests in a
directory and checking if the associated certificate is still valid. If not a
new certificate is requested and nginx is restarted.

# Install
- `git clone https://github.com/cato-/acme-update.git /usr/local/share/acme-update`
- `ln -s /usr/local/share/acme-update/acme_update.sh /usr/local/bin`
- `mkdir /etc/letsencrypt`
- `mkdir /srv/letsencrypt`
- `openssl genrsa 4096 > domain.key`
- Add something like `34 3 * * * /usr/local/bin/acme_update.sh` to your crontab with `crontab -e`

# Usage
1. Create CSRs for your domains in /etc/nginx/ssl (Location configurable in 
   `/etc/letsencrypt/acme_update.conf`)
2. Configure your webserver to serve /srv/letsencrypt (location configurable) 
   as `http://${domain}/.well-known/acme-challange`. Example snippet for nginx:

    location /.well-known/acme-challenge/ {
        alias /srv/letsencrypt/;
        try_files $uri =404;
    }

# TODO
- Some kind of privilege seperation
- Log and mail notification of updates
