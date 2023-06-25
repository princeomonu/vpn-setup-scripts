#!/bin/bash

# Add Route Script
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <public_key> <cidr_list>"
  exit 1
fi

public_key=$1
cidr_list=$2

# Get the current allowed IPs for the peer
current_allowed_ips=$(sudo wg show wg0 allowed-ips | awk -v key="$public_key" '$1 == "peer" && $0 ~ key {print $0}')

allowed=$(sudo wg show wg0 allowed-ips)
current_allowed_ips=$(echo "$allowed" | awk -v key="$public_key" '$1 == key {print $2, $3}')
echo "current_allowed_ips: $current_allowed_ips"

if echo "$current_allowed_ips" | grep -q "none"; then
  echo "no current allowed IPs found"
  current_allowed_ips=""
fi

# Combine the current and new CIDR lists
combined_cidrs="$current_allowed_ips ${cidr_list[*]}"
echo 'combined_cidrs: '$combined_cidrs

# Remove duplicates and sort the CIDR list
unique_cidrs=$(echo "$combined_cidrs" | tr ' ' '\n' | sort -u)

# Add allowed IPs for the peer
all_cidrs=''
for cidr in $unique_cidrs; do
  # Add the route for each CIDR
  echo "Adding allowed IP for the peer: $cidr"
  if [ -z "$all_cidrs" ]; then
    all_cidrs="$cidr"
  else
    all_cidrs+=",$cidr"
  fi
done

echo "All CIDRs: $all_cidrs"

sudo wg set wg0 peer "$public_key" allowed-ips "$all_cidrs" || { echo "Failed to add allowed IP for the peer: $all_cidrs"; exit 1; }

echo "Allowed IPs added successfully for the peer."


# reload
bash reload.sh