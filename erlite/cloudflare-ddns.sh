#!/bin/sh
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Cloudflare settings
source "$SCRIPT_DIR/.cloudflare_env"
# API_TOKEN="PASTE_CLOUDFLARE_API_TOKEN_HERE"
# ZONE_NAME="example.com"
# RECORD_NAME="home.example.com"

# TOOLS:
CUT=/usr/bin/cut
GREP=/bin/grep
HEAD=/usr/bin/head
LOGGER=/usr/bin/logger

log_notice() {
    "$LOGGER" -p user.notice -t cloudflare-ddns "$1"
}

log_error() {
    "$LOGGER" -p user.err -t cloudflare-ddns "$1"
}

API="https://api.cloudflare.com/client/v4"

# Get the current public IPv4 address
CURRENT_IP=$(/usr/bin/curl -4 -fsS https://api.ipify.org)

if [ -z "$CURRENT_IP" ]; then
    $LOGGER_ERR -t cloudflare-ddns "Unable to determine public IP"
    exit 1
fi

AUTH_HEADER="Authorization: Bearer ${API_TOKEN}"
CONTENT_HEADER="Content-Type: application/json"

# Find the Cloudflare zone ID
ZONE_ID=$(/usr/bin/curl -fsS \
    -H "$AUTH_HEADER" \
    "$API/zones?name=$ZONE_NAME&status=active" |
    $GREP -o '"id":"[a-f0-9]*"' |
    $HEAD -1 |
    $CUT -d'"' -f4)

if [ -z "$ZONE_ID" ]; then
    log_error."Unable to find Cloudflare zone ID"
    exit 1
fi

# Find the DNS record ID
RECORD_ID=$(/usr/bin/curl -fsS \
    -H "$AUTH_HEADER" \
    "$API/zones/$ZONE_ID/dns_records?type=A&name=$RECORD_NAME" |
    $GREP -o '"id":"[a-f0-9]*"' |
    $HEAD -1 |
    $CUT -d'"' -f4)

if [ -z "$RECORD_ID" ]; then
    log_error "Unable to find DNS record: $RECORD_NAME"
    exit 1
fi

# Get the address currently stored in Cloudflare
OLD_IP=$(/usr/bin/curl -fsS \
    -H "$AUTH_HEADER" \
    "$API/zones/$ZONE_ID/dns_records/$RECORD_ID" |
    $GREP -o '"content":"[^"]*"' |
    $HEAD -1 |
    $CUT -d'"' -f4)

# Do nothing if the address has not changed
if [ "$CURRENT_IP" = "$OLD_IP" ]; then
    exit 0
fi

# Update the record
RESULT=$(/usr/bin/curl -fsS -X PUT \
    -H "$AUTH_HEADER" \
    -H "$CONTENT_HEADER" \
    "$API/zones/$ZONE_ID/dns_records/$RECORD_ID" \
    --data "{\"type\":\"A\",\"name\":\"$RECORD_NAME\",\"content\":\"$CURRENT_IP\",\"ttl\":120,\"proxied\":false}")

if echo "$RESULT" | $GREP -q '"success":true'; then
    log_notice "Updated $RECORD_NAME from $OLD_IP to $CURRENT_IP"
    exit 0
else
    log_error "Cloudflare update failed: $RESULT"
    exit 1
fi
