#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <ip_cidr>"
  exit 1
fi

ip_cidr=$1

# Validate CIDR format
if [[ ! "$ip_cidr" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]+$ ]]; then
  echo "Invalid CIDR format. Please provide IP address in CIDR notation (e.g., 192.168.1.1/24)."
  exit 1
fi

# Extract IP address and subnet mask
ip_address=$(echo "$ip_cidr" | cut -d'/' -f1)
subnet_mask=$(echo "$ip_cidr" | cut -d'/' -f2)

# Clean up existing WireGuard configuration if it exists
bash cleanup.sh

# Peer A Configuration
echo "Generating private and public keys for Peer A..."
privatekey_a=$(wg genkey)
publickey_a=$(echo "$privatekey_a" | wg pubkey)

# Peer A Configuration File
echo "Creating WireGuard configuration file..."
cat <<EOF > wg0.conf
[Interface]
PrivateKey = $privatekey_a
Address = $ip_cidr
ListenPort = 51820
SaveConfig = true

# Add additional peer configurations here
EOF

# Save private key to file
echo "Saving private key to privatekey.txt..."
echo "$privatekey_a" > "privatekey.txt"

# Apply WireGuard configuration
echo "Applying WireGuard configuration..."
sudo mv wg0.conf /etc/wireguard/
sudo systemctl enable wg-quick@wg0
sudo systemctl start wg-quick@wg0

# Output relevant details
echo "WireGuard VPN setup for Peer A is complete."
echo "Peer A Configuration:"
echo "Private Key: $privatekey_a"
echo "Public Key: $publickey_a"
echo "IP Address: $ip_address"
echo "Subnet Mask: $subnet_mask"
