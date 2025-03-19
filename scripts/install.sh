#!/bin/bash
NGINX_DIR="/opt/nginx-custom"

echo "Installazione di nginx personalizzato..."

# Crea directory di installazione
mkdir -p $NGINX_DIR/sbin
mkdir -p $NGINX_DIR/lib
mkdir -p $NGINX_DIR/conf
mkdir -p /etc/ssl/nginx

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
        -subj "/C=IT/ST=State/L=City/O=Organization/CN=localhost" \
        -addext "subjectAltName=DNS:localhost,IP:127.0.0.1"
    chmod 600 /etc/ssl/nginx/server.key
fi

# Crea script wrapper
cat > /usr/local/bin/nginx << EOW
#!/bin/bash
export LD_LIBRARY_PATH=$NGINX_DIR/lib:\$LD_LIBRARY_PATH
$NGINX_DIR/sbin/nginx -p $NGINX_DIR \$@
EOW

chmod +x /usr/local/bin/nginx

# Crea service
cat > /etc/systemd/system/nginx.service << EOS
[Unit]
Description=nginx - high performance web server
After=network-online.target

[Service]
Type=forking
ExecStart=$NGINX_DIR/sbin/nginx -p $NGINX_DIR
ExecReload=$NGINX_DIR/sbin/nginx -p $NGINX_DIR -s reload
ExecStop=$NGINX_DIR/sbin/nginx -p $NGINX_DIR -s stop
Environment="LD_LIBRARY_PATH=$NGINX_DIR/lib"

[Install]
WantedBy=multi-user.target
EOS

# Crea directory necessarie
mkdir -p $NGINX_DIR/logs
mkdir -p $NGINX_DIR/client_body_temp
chmod 700 $NGINX_DIR/client_body_temp

# Avvia servizio
systemctl daemon-reload
systemctl enable nginx
systemctl start nginx

echo "Nginx installato con successo in $NGINX_DIR"
echo "Un certificato SSL auto-firmato è stato generato in /etc/ssl/nginx/"
echo "Odoo è ora accessibile tramite HTTPS sulla porta 443"
