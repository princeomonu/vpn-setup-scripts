# Clean up existing WireGuard configuration if it exists
echo "Cleaning up existing WireGuard configuration..."
sudo systemctl stop wg-quick@wg0
sudo systemctl disable wg-quick@wg0
sudo rm -f /etc/wireguard/wg0.conf
sudo wg-quick down wg0