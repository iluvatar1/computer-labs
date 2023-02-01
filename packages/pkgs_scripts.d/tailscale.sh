AUXDIR=$(mktemp -d)
cd $AUXPDIR
wget -c https://pkgs.tailscale.com/stable/tailscale_1.36.0_amd64.tgz
tar xvf tailscale*tgz
cp tailscale*/tailscale /usr/local/bin/
cp tailscale*/tailscaled /usr/local/bin/

