# Install docker

```shell
curl -fsSL get.docker.com -o get-docker.sh \
&&  sh get-docker.sh \
&& systemctl enable docker \
&& systemctl start docker
```

# Install docker-compose

```shell
curl -L https://github.com/docker/compose/releases/download/v2.24.5/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose \
&& chmod +x /usr/local/bin/docker-compose
```

# Install go Or rust

```shell
bash <(curl -s -L https://raw.githubusercontent.com/skyMetaverse/nodeHelper/master/tools/helper.sh)
```

