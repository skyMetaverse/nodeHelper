#!/bin/sh

# 创建Nginx目录
mkdir -p /opt/nginx
mkdir -p /opt/nginx/html
mkdir -p /opt/nginx/certs
touch /opt/nginx/nginx.conf

# 申请证书
curl https://get.acme.sh | sh
~/.acme.sh/acme.sh --register-account -m xxxx@gmail.com
~/.acme.sh/acme.sh --issue -d example.com --standalone

# 下载证书
~/.acme.sh/acme.sh --installcert -d example.com --key-file /opt/nginx/certs/key.pem --fullchain-file /opt/nginx/certs/cert.pem

# ./../config/nginx.conf.example

docker run -d --name nginx --restart=always -p 80:80 -p 443:443 -v /opt/nginx/nginx.conf:/etc/nginx/nginx.conf -v /opt/nginx/html:/usr/share/nginx/html nginx:latest

# 反向代理
# ./../config/nginx.conf.proxy.example
docker run -d --name nginx --restart=always -p 80:80 -p 443:443 -v /opt/nginx/nginx.conf:/etc/nginx/nginx.conf -v /opt/nginx/certs:/etc/nginx/certs -v /opt/nginx/html:/usr/share/nginx/html nginx:latest
