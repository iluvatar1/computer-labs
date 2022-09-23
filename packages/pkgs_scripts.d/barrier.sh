pip install dbus-python
MAKEFLAGS=-j$(nproc) slpkg -s sbo barrier
mkdir -p /root/.local/share/barrier/SSL/
cd /root/.local/share/barrier/SSL/
openssl req -x509 -nodes -days 365 -subj /CN=Barrier -newkey rsa:4096 -keyout Barrier.pem -out Barrier.pem
