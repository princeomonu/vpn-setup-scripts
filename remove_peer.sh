#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <public_key>"
  exit 1
fi

public_key=$1

# Remove Peer from WireGuard configuration file
echo "Removing peer configuration..."
sudo sed -i "/\[Peer\]\nPublicKey = $public_key/,/^\s*$/d" /etc/wireguard/wg0.conf

# Apply WireGuard configuration
echo "Applying WireGuard configuration..."
sudo wg set wg0 peer "$public_key" remove

# Output removal status
echo "Peer configuration removed successfully."
