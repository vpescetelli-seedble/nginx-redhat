#!/bin/bash
NGINX_DIR="/opt/nginx-custom"

echo "Installazione di nginx personalizzato..."

# Crea directory di installazione
mkdir -p $NGINX_DIR/sbin
mkdir -p $NGINX_DIR/lib
mkdir -p $NGINX_DIR/conf
mkdir -p $NGINX_DIR/logs
mkdir -p /var/log/nginx
mkdir -p /etc/ssl/nginx
mkdir -p /etc/nginx/conf.d

# Copia i file
cp -r binaries/* $NGINX_DIR/sbin/
cp -r lib/* $NGINX_DIR/lib/
cp -r config/* $NGINX_DIR/conf/

# Genera certificati SSL auto-firmati se non esistono
if [ ! -f /etc/ssl/nginx/server.crt ]; then
    echo "Generazione di certificati SSL auto-firmati..."
    openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
        -keyout /etc/ssl/nginx/server.key \
        -out /etc/ssl/nginx/server.crt \
        -subj "/C=IT/ST=State/L=City/O=Organization/CN=localhost"
    chmod 600 /etc/ssl/nginx/server.key
fi

# Modifica il file nginx.conf per cambiare l'utente
sed -i 's/^user  nginx;/user  root;/' $NGINX_DIR/conf/nginx.conf

# Correggi i percorsi nei file di configurazione di odoo
sed -i 's/uri\\;/uri;/g' $NGINX_DIR/conf/conf.d/odoo.conf
sed -i 's/odoo\\;/odoo;/g' $NGINX_DIR/conf/conf.d/odoo.conf
sed -i 's/polling\\;/polling;/g' $NGINX_DIR/conf/conf.d/odoo.conf

# Copia tutti i file di configurazione in /etc/nginx/
cp -f $NGINX_DIR/conf/nginx.conf /etc/nginx/
cp -f $NGINX_DIR/conf/mime.types /etc/nginx/
cp -f $NGINX_DIR/conf/fastcgi_params /etc/nginx/
cp -f $NGINX_DIR/conf/scgi_params /etc/nginx/
cp -f $NGINX_DIR/conf/uwsgi_params /etc/nginx/
cp -f $NGINX_DIR/conf/conf.d/* /etc/nginx/conf.d/

# Crea script wrapper
cat > /usr/local/bin/nginx << EOW
#!/bin/bash
export LD_LIBRARY_PATH=$NGINX_DIR/lib:\$LD_LIBRARY_PATH
$NGINX_DIR/sbin/nginx \$@
EOW

chmod +x /usr/local/bin/nginx

# Crea service
cat > /etc/systemd/system/nginx.service << EOS
[Unit]
Description=nginx - high performance web server
After=network-online.target

[Service]
Type=forking
ExecStartPre=/opt/nginx-custom/sbin/nginx -t
ExecStart=/opt/nginx-custom/sbin/nginx
ExecReload=/opt/nginx-custom/sbin/nginx -s reload
ExecStop=/opt/nginx-custom/sbin/nginx -s stop
Environment="LD_LIBRARY_PATH=$NGINX_DIR/lib"

[Install]
WantedBy=multi-user.target
EOS

# Crea directory necessarie per nginx
mkdir -p $NGINX_DIR/logs
mkdir -p $NGINX_DIR/client_body_temp
mkdir -p $NGINX_DIR/proxy_temp
mkdir -p $NGINX_DIR/fastcgi_temp
mkdir -p $NGINX_DIR/uwsgi_temp
mkdir -p $NGINX_DIR/scgi_temp
chmod 700 $NGINX_DIR/client_body_temp
chmod 700 $NGINX_DIR/proxy_temp
chmod 700 $NGINX_DIR/fastcgi_temp
chmod 700 $NGINX_DIR/uwsgi_temp
chmod 700 $NGINX_DIR/scgi_temp

# Crea i file di log
touch /var/log/nginx/error.log
touch /var/log/nginx/access.log
chmod 644 /var/log/nginx/*.log

# Avvia servizio
systemctl daemon-reload
systemctl enable nginx
systemctl start nginx

echo "Nginx installato con successo in $NGINX_DIR"
echo "Un certificato SSL auto-firmato è stato generato in /etc/ssl/nginx/"
echo "Odoo è ora accessibile tramite HTTPS sulla porta 443"