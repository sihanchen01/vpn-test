#!/bin/bash
set -euo pipefail

# Config
BASE="http://47.130.126.21:2053/nvOK9kbmG1rseqgdam"
TOKEN="t4kPDcPXX7rXEz8PeycQcyceFwSjLD1E8BOl3mr08CAkY5FT"
H_AUTH="Authorization: Bearer $TOKEN"
H_JSON="Content-Type: application/json"

# Inbound settings
INBOUND_PORT=443
INBOUND_REMARK="my-reality"
REALITY_TARGET="www.oracle.com:443"
REALITY_SERVER_NAME="www.oracle.com"
REALITY_FINGERPRINT="chrome"

# Client settings
CLIENT_EMAIL="sihan-testing"

# Helper funcs
api() {
	curl -s -X "${1}" "${BASE}${2}" \
		-H "$H_AUTH" \
		-H "$H_JSON" \
		${3:+-d "$3"}
}

check_success() {
	local response="$1"
	local step="$2"
	local success
	success=$(echo "$response" | jq -r ".success")
	if [[ "$success" != "True" && "$success" != "true" ]]; then
		echo "Failed at: $step"
		echo "$response" | jq 2>/dev/null || echo "$response"
		exit 1
	fi
	echo "$step"
}

# Step 1: Generate Reality keys
echo "Generating Reality X25519 keys..."
KEYS=$(api GET "/panel/api/server/getNewX25519Cert")
PRIVATE_KEY=$(echo "$KEYS" | jq -r ".obj.privateKey")
PUBLIC_KEY=$(echo "$KEYS" | jq -r ".obj.publicKey")
echo "  privateKey: $PRIVATE_KEY"
echo "  publicKey:  $PUBLIC_KEY"

# Step 2: Generate short ID and client UUID
SHORT_ID=$(openssl rand -hex 4)
CLIENT_UUID=$(cat /proc/sys/kernel/random/uuid)
echo "shortId:   $SHORT_ID"
echo "clientId:  $CLIENT_UUID"

# Step 3: Create inbound
echo "Creating inbound on port $INBOUND_PORT..."

INBOUND_PAYLOAD=$(python3 -c "
import json
payload = {
    'enable': True,
    'remark': '${INBOUND_REMARK}',
    'listen': '',
    'port': ${INBOUND_PORT},
    'protocol': 'vless',
    'settings': json.dumps({
        'clients': [],
        'decryption': 'none',
        'encryption': 'none',
        'testseed': [900, 500, 900, 256]
    }),
    'streamSettings': json.dumps({
        'network': 'tcp',
        'tcpSettings': {
            'acceptProxyProtocol': False,
            'header': {'type': 'none'}
        },
        'security': 'reality',
        'realitySettings': {
            'show': False,
            'xver': 0,
            'target': '${REALITY_TARGET}',
            'serverNames': ['${REALITY_SERVER_NAME}'],
            'privateKey': '${PRIVATE_KEY}',
            'minClientVer': '',
            'maxClientVer': '',
            'maxTimediff': 0,
            'shortIds': ['${SHORT_ID}'],
            'mldsa65Seed': '',
            'settings': {
                'publicKey': '${PUBLIC_KEY}',
                'fingerprint': '${REALITY_FINGERPRINT}',
                'serverName': '',
                'spiderX': '/',
                'mldsa65Verify': ''
            }
        }
    }),
    'sniffing': json.dumps({'enabled': False})
}
print(json.dumps(payload))
")

INBOUND_RESP=$(api POST "/panel/api/inbounds/add" "$INBOUND_PAYLOAD")
check_success "$INBOUND_RESP" "Create inbound"

INBOUND_ID=$(echo "$INBOUND_RESP" | jq -r ".obj.id")
echo "  inbound id: $INBOUND_ID"

# Step 4: Add client to inbound
echo "Adding client '$CLIENT_EMAIL'..."

CLIENT_PAYLOAD=$(python3 -c "
import json
payload = {
    'inboundIds': [
        ${INBOUND_ID}
    ],
    'client': {
        'id': '${CLIENT_UUID}',
        'email': '${CLIENT_EMAIL}',
        'enable': True,
        'limitIp': 0,
        'totalGB': 0,
        'expiryTime': 0,
        'reset': 0
    }
}
print(json.dumps(payload))
")

CLIENT_RESP=$(api POST "/panel/api/clients/add" "$CLIENT_PAYLOAD")
check_success "$CLIENT_RESP" "Add client"

# Build VLESS URI
SERVER_IP="47.130.126.21"
VLESS_URI="vless://${CLIENT_UUID}@${SERVER_IP}:${INBOUND_PORT}?encryption=none&flow=xtls-rprx-vision&security=reality&sni=${REALITY_SERVER_NAME}&fp=${REALITY_FINGERPRINT}&pbk=${PUBLIC_KEY}&sid=${SHORT_ID}&type=tcp&headerType=none#${INBOUND_REMARK}-${CLIENT_EMAIL}"

# Done
echo ""
echo "-------------------------------------------"
echo "  Setup complete!"
echo "-------------------------------------------"
echo "  Inbound ID:  $INBOUND_ID"
echo "  Port:        $INBOUND_PORT"
echo "  Protocol:    vless + reality"
echo "  Target:      $REALITY_TARGET"
echo "  Client UUID: $CLIENT_UUID"
echo "  Client:      $CLIENT_EMAIL"
echo "  publicKey:   $PUBLIC_KEY"
echo "  shortId:     $SHORT_ID"
echo
echo "  VLESS URI:   $VLESS_URI"
echo "-------------------------------------------"
