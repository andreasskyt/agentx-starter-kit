#!/usr/bin/env bash
# Baseline hardening for a fresh Ubuntu/Debian VPS that will run AgentX agents.
# Run as root ON THE SERVER. Read it first. Keep your current SSH session open until you've tested a new one.
# Usage: bash harden-vps.sh [--no-ufw]   (--no-ufw if your provider's firewall already allows only SSH)
set -euo pipefail
[[ $EUID -eq 0 ]] || { echo "Run as root."; exit 1; }
use_ufw=1; [[ "${1:-}" == "--no-ufw" ]] && use_ufw=0
export DEBIAN_FRONTEND=noninteractive

# Refuse to disable password login unless a key is installed for root.
if ! grep -qE '^(ssh-|ecdsa-)' /root/.ssh/authorized_keys 2>/dev/null; then
  echo "No SSH key in /root/.ssh/authorized_keys. Add yours first, or you'll lock yourself out."; exit 1
fi

echo "== Updates"
apt-get update -qq && apt-get -y -qq upgrade
apt-get install -y -qq unattended-upgrades fail2ban git python3 curl ca-certificates >/dev/null
dpkg-reconfigure -f noninteractive unattended-upgrades

echo "== fail2ban (sshd)"
cat > /etc/fail2ban/jail.d/sshd.local <<'J'
[sshd]
enabled = true
maxretry = 5
bantime = 1h
J
systemctl enable --now fail2ban >/dev/null
systemctl restart fail2ban

echo "== Swap"
if ! swapon --show | grep -q .; then
  fallocate -l 2G /swapfile && chmod 600 /swapfile && mkswap /swapfile >/dev/null && swapon /swapfile
  grep -q '^/swapfile' /etc/fstab || echo '/swapfile none swap sw 0 0' >> /etc/fstab
  echo "2 GB swap added."
else
  echo "Swap already present."
fi

echo "== SSH: keys only"
cat > /etc/ssh/sshd_config.d/10-hardening.conf <<'S'
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin prohibit-password
X11Forwarding no
S
sshd -t
systemctl reload ssh 2>/dev/null || systemctl reload sshd

if [[ $use_ufw -eq 1 ]]; then
  echo "== ufw: only SSH in"
  apt-get install -y -qq ufw >/dev/null
  ufw default deny incoming >/dev/null
  ufw default allow outgoing >/dev/null
  ufw allow OpenSSH >/dev/null
  ufw --force enable >/dev/null
  ufw status verbose
fi

echo
echo "Done. Now, from your computer, open a NEW terminal and test: ssh <host> 'echo ok'"
echo "Also check password login is refused: ssh -o PubkeyAuthentication=no <host>  (should say Permission denied)"
