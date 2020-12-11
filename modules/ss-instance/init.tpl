#!/usr/bin/env sh
set -e

sudo apt-get update
sudo apt install -y shadowsocks-libev
sudo systemctl enable shadowsocks-libev
sudo systemctl start shadowsocks-libev

cat << EOCFG | sudo tee /etc/shadowsocks-libev/config.json
{
    "server":"0.0.0.0",
    "server_port":${port},
    "local_port":1080,
    "password":"${password}",
    "timeout":60,
    "method":"${method}"
}
EOCFG

sudo systemctl restart shadowsocks-libev

