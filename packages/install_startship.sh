# TODO : make this idempotent
cd /tmp
wget https://starship.rs/install.sh
sh install.sh -y
echo 'eval "$(starship init bash)"' >> /root/.bashrc
