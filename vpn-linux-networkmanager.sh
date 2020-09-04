#!/bin/bash

PASS_CRED_PATH="vpn/XauthPassword" # retrieved with: pass "${PASS_CRED_PATH}"
PASS_IPSEC_TOKEN_PATH="vpn/IPSecSecretToken" # retrieved with: pass "${PASS_CRED_PATH}"
PASS_TOTP_SECRET_PATH="vpn/TOTP-secret" # retrieved with: pass "${PASS_TOTP_SECRET_PATH}"
VPN_NAME="VPN" # connection name, configured with Network Manager

#############################################################
# Check dependencies
if ! command -v pass &>/dev/null ; then
  echo "pass (passwordstore.org) dependency is missing. Install it before running (eg: sudo apt install pass)"
  exit 1
fi
if ! command -v nmcli &>/dev/null ; then
  echo "nmcli dependency is missing. Install it before running (eg: sudo apt install network-manager)"
  exit 1
fi
if ! command -v oathtool &>/dev/null ; then
  echo "oathtool dependency is missing. Install it before running (eg: sudo apt install oathtool)"
  exit 1
fi
#############################################################


# Check already connected VPN
if [[ $(nmcli connection show --active | grep "$VPN_NAME" | wc -l) -gt 0 ]]; then
  read -p "${VPN_NAME} is already ON. Disconnect? [y/N] " choice
  if [[ "$choice" =~ [yY] ]]; then
    nmcli connection down "${VPN_NAME}"
    echo "$VPN_NAME was DISCONNECTED"
  fi

  exit 0
fi

# Change credentials and connect
nmcli connection modify "$VPN_NAME" vpn.secrets "Xauth password=$( pass "${PASS_CRED_PATH}" )$( pass "${PASS_TOTP_SECRET_PATH}"| xargs -I{} oathtool --totp --base32 {} ) ,IPSec secret=$( pass "${PASS_IPSEC_TOKEN_PATH}" )"

nmcli connection up "$VPN_NAME"

[[ $? -ne 0 ]] && echo "Some error occurred (wrong TOTP?)" || echo "$VPN_NAME is now CONNECTED"
