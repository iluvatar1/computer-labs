removepkg /var/log/packages/perl-DBD-SQLite-*
sbopkg -r
echo "P" | MAKEFLAGS=-j$(nproc) sbopkg -i perl-DBD-SQLite #installs version 1.72 as of 2023-01-31
x2godbadmin --createdb

