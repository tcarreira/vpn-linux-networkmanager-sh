# vpn-linux-networkmanager.sh

This script is intended to connect the VPN, by directly asking the TOTP token.  
This script assumes the XAuth password has the format `<UserPassword><TOTPToken>`

The secrets are managed by pass (https://www.passwordstore.org/) using PGP encryption.

# Configure

1. You must have a previously working VPN connection in the Network Manager
2. You must have the following dependencies
   1. a pass keyring working (https://www.passwordstore.org/)
   2. nmcli (from the network-manager package)
   3. oathtool (for generating totp tokens)
3. Create the secrets within pass (these are secuyrely protected by PGP)
   1. `pass insert vpn/XauthPassword` # this is your backstage password
   2. `pass insert vpn/IPSecSecretToken` # IPSec shared secret
   3. `pass insert vpn/TOTP-secret` # TOTP Secret - token generator
   4. test if it is corretcly stored:
      1. `pass vpn/IPSecSecretToken`
4. Try it!
   1. `./vpn-linux-networkmanager.sh`
   2. Check if the VPN is connected


# Is this secure?

This is as secure as your `pass` setup.
If properly configured, each secret is protected by your private PGP key.
For additional protection, it is recommended you use a password protected PGP key.

Furthermore, the vpn password is rotated every 30 seconds (totp), so this should be pretty secure.