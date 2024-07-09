AUXDIR=$(mktemp -d)
cd $AUXDIR
wget -c https://pkgs.tailscale.com/stable/tailscale_1.68.1_amd64.tgz
tar xvf tailscale*tgz
cp tailscale*/tailscale /usr/local/bin/
cp tailscale*/tailscaled /usr/local/bin/

