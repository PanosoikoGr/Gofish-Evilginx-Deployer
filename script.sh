#!/bin/bash

################################################################################
# GoPhish & Evilginx Deployment Script with Interactive Selection
# Author: [Your Name]
# Date: [Today’s Date]
# Objective: Automate deployment of GoPhish or Evilginx with post-launch reminders
################################################################################

set -e

#==========================
# 0. VARIABLES
#==========================

# ---- GoPhish Config ----
GOPHISH_URL="https://getgophish.com/releases/latest/gophish-v0.12.1-linux-64bit.zip"
GOPHISH_DIR="/opt/gophish"
GOPHISH_CONFIG="$GOPHISH_DIR/config.json"
GOPHISH_DOMAIN="phish.yourdomain.com" # Replace with your domain
EMAIL="your-email@domain.com" # For Let's Encrypt

# ---- Evilginx Config ----
EVILGINX_URL="https://github.com/kgretzky/evilginx2/releases/download/v3.2.0/evilginx-linux-amd64.tar.gz"
EVILGINX_DIR="/opt/evilginx"
EVILGINX_DOMAIN="evil.yourdomain.com" # Replace with your Evilginx domain

#==========================
# 1. GET PUBLIC IP
#==========================
echo "[*] Detecting public IP..."
PUBLIC_IP=$(curl -s ifconfig.me)
echo "[*] Public IP detected: $PUBLIC_IP"

#==========================
# 2. SYSTEM PREPARATION
#==========================
echo "[*] Updating system and installing dependencies..."
sudo apt update && sudo apt upgrade -y
sudo apt install unzip certbot jq curl tar -y

#==========================
# 3. SELECT DEPLOYMENT
#==========================
echo ""
echo "Choose what to deploy:"
echo "1) GoPhish"
echo "2) Evilginx"
echo "3) Both"
read -p "Enter choice [1-3]: " CHOICE

#==========================
# 4. DEPLOY GOPHISH
#==========================
deploy_gophish() {
    echo "[*] Deploying GoPhish..."

    mkdir -p $GOPHISH_DIR
    cd $GOPHISH_DIR

    wget -O gophish.zip $GOPHISH_URL
    unzip -o gophish.zip
    rm gophish.zip

    echo "[*] Generating SSL certificate with Certbot..."
    sudo certbot certonly --manual --preferred-challenges dns -d $GOPHISH_DOMAIN --agree-tos --register-unsafely-without-email

    CERT_PATH="/etc/letsencrypt/live/$GOPHISH_DOMAIN/fullchain.pem"
    KEY_PATH="/etc/letsencrypt/live/$GOPHISH_DOMAIN/privkey.pem"

    echo "[*] Modifying GoPhish config.json..."
    jq '.admin_server.listen_url="0.0.0.0:3333" | .admin_server.use_tls=true | .admin_server.cert_path="'$CERT_PATH'" | .admin_server.key_path="'$KEY_PATH'"' $GOPHISH_CONFIG > tmp.$$.json && mv tmp.$$.json $GOPHISH_CONFIG

    echo "[*] Launching GoPhish..."
    cd $GOPHISH_DIR
    nohup ./gophish > gophish.log 2>&1 &

    echo "[+] GoPhish deployed at https://$GOPHISH_DOMAIN:3333"
}

#==========================
# 5. DEPLOY EVILGINX
#==========================
deploy_evilginx() {
    echo "[*] Deploying Evilginx..."

    mkdir -p $EVILGINX_DIR
    cd $EVILGINX_DIR

    wget -O evilginx.tar.gz $EVILGINX_URL
    tar -xvzf evilginx.tar.gz
    rm evilginx.tar.gz

    chmod +x evilginx

    echo "[*] Launching Evilginx..."
    nohup ./evilginx > evilginx.log 2>&1 &

    echo "[+] Evilginx deployed. Remember to configure phishlets and settings in console."
}

#==========================
# 6. EXECUTE BASED ON CHOICE
#==========================
case $CHOICE in
    1)
        deploy_gophish
        ;;
    2)
        deploy_evilginx
        ;;
    3)
        deploy_gophish
        deploy_evilginx
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

#==========================
# 7. POST-LAUNCH REMINDERS
#==========================
echo "======================================================"
echo "Deployment Summary"
echo "------------------------------------------------------"
echo "Public IP: $PUBLIC_IP"
echo ""
if [[ "$CHOICE" == "1" || "$CHOICE" == "3" ]]; then
    echo "[GoPhish]"
    echo "Admin Portal: https://$GOPHISH_DOMAIN:3333"
    echo "SSL Cert Path: /etc/letsencrypt/live/$GOPHISH_DOMAIN/fullchain.pem"
    echo "SSL Key Path: /etc/letsencrypt/live/$GOPHISH_DOMAIN/privkey.pem"
    echo "Check logs: tail -f $GOPHISH_DIR/gophish.log"
    echo ""
fi
if [[ "$CHOICE" == "2" || "$CHOICE" == "3" ]]; then
    echo "[Evilginx]"
    echo "Domain: $EVILGINX_DOMAIN"
    echo "Public IP: $PUBLIC_IP"
    echo "Check logs: tail -f $EVILGINX_DIR/evilginx.log"
    echo ""
fi
echo "------------------------------------------------------"
echo "REMINDERS:"
echo "-> Update DNS A records for the domains above pointing to: $PUBLIC_IP"
echo "-> Verify firewall rules allow inbound traffic on ports 80 and 443"
echo "-> Configure Evilginx phishlets as needed after launch"
echo "======================================================"
