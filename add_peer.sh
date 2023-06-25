#!/bin/bash

if [ "$#" -lt 4 ] || [ "$#" -gt 5 ]; then
  echo "Usage: $0 <private_key_file> <public_key> <peer_ip> <subnet_mask> [peer_endpoint]"
  exit 1
fi

private_key_file=$1
public_key=$2
peer_ip=$3
subnet_mask=$4
peer_endpoint=$5

# Validate IP address and subnet mask
if [[ ! "$peer_ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Invalid peer IP address format. Please provide a valid IP address."
  exit 1
fi

if [[ ! "$subnet_mask" =~ ^[0-9]+$ ]]; then
  echo "Invalid subnet mask format. Please provide a valid subnet mask."
  exit 1
fi

# Check if private key file exists
if [ ! -f "$private_key_file" ]; then
  echo "Private key file not found."
  exit 1
fi

# Read private key from file
private_key=$(cat "$private_key_file")

# Peer Configuration
echo "Adding new peer configuration..."
cat <<EOF >> /etc/wireguard/wg0.conf

[Peer]
PublicKey = $public_key
AllowedIPs = $peer_ip/$subnet_mask
EOF

if [ -n "$peer_endpoint" ]; then
  echo "Endpoint = $peer_endpoint" >> /etc/wireguard/wg0.conf
  echo "PersistentKeepalive = 15" >> /etc/wireguard/wg0.conf
fi

# Apply WireGuard configuration
echo "Applying WireGuard configuration..."
if [ -n "$peer_endpoint" ]; then
  sudo wg set wg0 peer $public_key allowed-ips $peer_ip/$subnet_mask endpoint $peer_endpoint persistent-keepalive 15
else
  sudo wg set wg0 peer $public_key allowed-ips $peer_ip/$subnet_mask
fi

# Output relevant details
echo "Peer configuration added successfully."
echo "Public Key: $public_key"
echo "Allowed IPs: $peer_ip/$subnet_mask"

if [ -n "$peer_endpoint" ]; then
  echo "Endpoint: $peer_endpoint"
fi
