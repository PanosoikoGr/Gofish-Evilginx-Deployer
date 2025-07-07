# Gofish-Evilginx-Deployer
# GoPhish & Evilginx Automated Deployment Script

## 📌 Overview

This Bash script automates the **installation, configuration, and deployment** of:

- [**GoPhish**](https://getgophish.com) – an open-source phishing framework  
- [**Evilginx2**](https://github.com/kgretzky/evilginx2) – a man-in-the-middle attack framework for phishing bypassing 2FA

It streamlines **system preparation, SSL generation, configuration editing, and service startup** with a single script, enhancing your **DevSecOps and red team automation** workflows.

---

## ⚙️ Features

✅ System updates and dependency installation  
✅ Automatic public IP detection  
✅ Interactive choice for deployment (GoPhish, Evilginx, or both)  
✅ Download and install the latest releases  
✅ SSL certificate generation using Certbot (manual DNS challenge) for GoPhish  
✅ JSON configuration editing via `jq`  
✅ Post-launch reminders for DNS and firewall rules  
✅ Background service execution with logs

---

## 🚀 Usage

### 1. Clone the repository

```bash
git clone https://github.com/yourusername/gophish-evilginx-deployer.git
cd gophish-evilginx-deployer
```
2. Edit script variables
At the top of deploy.sh, update:

GOPHISH_DOMAIN – your phishing subdomain

EMAIL – email for Let's Encrypt

EVILGINX_DOMAIN – your Evilginx domain

3. Make the script executable
```bash
chmod +x deploy.sh
```
4. Run the script
```bash
sudo ./script.sh
```
You will be prompted:
```
Choose what to deploy:
1) GoPhish
2) Evilginx
3) Both
Enter choice [1-3]:
```

🔒 Prerequisites
Ubuntu 20.04 / 22.04 (or compatible Debian-based VPS)

sudo privileges

Domains configured and able to set DNS records (A records and DNS TXT for Let's Encrypt DNS challenge)

⚠️ Notes & Recommendations
SSL Certificate Generation: Uses Certbot with manual DNS challenge for GoPhish. Automating DNS record creation via Namecheap API is recommended for production.

Evilginx Configuration: After deployment, configure phishlets and settings within the Evilginx console.

Firewall: Ensure ports 80 and 443 are open inbound to the VPS.

Legal Usage Only: This script is intended for authorized security testing, education, and research. Unauthorized use is illegal and unethical.
