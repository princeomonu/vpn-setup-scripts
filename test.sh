# public_key=AesseMaBkqd/CDyKoCqB550QhKRM9h93I4bmK23ZumY=
# current_allowed_ips="AesseMaBkqd/CDyKoCqB550QhKRM9h93I4bmK23ZumY=    10.10.9.0/24 10.10.9.0/24" | awk -v key="$public_key" '$1 == key {print $2, $3}'
# echo 'current_allowed_ips: '$current_allowed_ips

public_key="AesseMaBkqd/CDyKoCqB550QhKRM9h93I4bmK23ZumY="
allowed=$(sudo wg show wg0 allowed-ips)
current_allowed_ips=$(echo "$allowed" | awk -v key="$public_key" '$1 == key {print $2, $3}')
echo "current_allowed_ips: $current_allowed_ips"
