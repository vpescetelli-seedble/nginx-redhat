# Nginx Standalone per Red Hat

Pacchetto standalone di nginx con tutte le dipendenze incluse per sistemi Red Hat, progettato per ambienti senza accesso esterno ai repository.

## Contenuto del pacchetto
- `binaries/`: Contiene gli eseguibili di nginx
- `lib/`: Contiene tutte le librerie necessarie
- `config/`: Contiene i file di configurazione di nginx
- `scripts/`: Contiene lo script di installazione

## Installazione

1. Clona questa repository:
git clone https://github.com/vpescete/nginx-standalone.git
cd nginx-standalone

2. Esegui lo script di installazione:
sudo ./scripts/install.sh

3. Verifica l'installazione:
nginx -v
systemctl status nginx

## Configurazione

I file di configurazione si trovano in `/opt/nginx-custom/conf/`.

Per applicare modifiche alla configurazione:
sudo nginx -s reload

## Disinstallazione
sudo systemctl stop nginx
sudo systemctl disable nginx
sudo rm -rf /opt/nginx-custom /usr/local/bin/nginx /etc/systemd/system/nginx.service
sudo systemctl daemon-reload
## Configurazione Odoo

Questo pacchetto include una configurazione pronta per esporre Odoo (porta 8069) sulla porta 443 (HTTPS). La configurazione:

- Reindirizza tutto il traffico HTTP (porta 80) a HTTPS (porta 443)
- Utilizza certificati SSL auto-firmati generati durante l'installazione
- Supporta il long polling di Odoo
- Configura i parametri proxy corretti per Odoo

### Personalizzazione

Se necessario, è possibile modificare il file `/opt/nginx-custom/conf/conf.d/odoo.conf` per adattarlo alle proprie esigenze specifiche:

- Cambiare il nome del server
- Configurare certificati SSL diversi
- Modificare le impostazioni del proxy
