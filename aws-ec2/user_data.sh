#!/bin/bash
set -e

# Variables passed from Terraform
PANEL_PORT="${panel_port}"
PANEL_USER="${panel_username}"
PANEL_PASS="${panel_password}"

# Install 3X-UI non-interactively
bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh) <<<$'1\nn\n4\n'

# Set panel port to custom value
/usr/local/x-ui/x-ui setting -port $PANEL_PORT
# Set credentials via CLI
/usr/local/x-ui/x-ui setting -username $PANEL_USER -password $PANEL_PASS -resetTwoFactor

x-ui restart

echo "Setup complete."
