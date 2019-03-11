# NGINX with libModSecurity + ModSecurity-nginx + Keepalived +  connector

git submodule add https://github.com/SpiderLabs/owasp-modsecurity-crs

The dockerfile of this container has been copied from the [official nginx repo (alpine-perl variant)](https://github.com/nginxinc/docker-nginx/blob/1.15.3/mainline/alpine-perl/Dockerfile) and has been modified to add [ModSecurity library (v3)](https://github.com/SpiderLabs/ModSecurity/tree/v3/master) + [ModSecurity nginx connector](https://github.com/SpiderLabs/ModSecurity-nginx).

You can refer to the [official nginx image documentation](https://hub.docker.com/_/nginx/) for instructions on how to use this image.

When you provide your configuration you can enable modsecurity. Please refer to [their wiki](https://github.com/SpiderLabs/ModSecurity/wiki) for documentation.

NOTE: no rules are shipped with this container, if you enable modsecurity you need to provide your own
## how use
```
mkdir /mytools
cd /mytools/
git clone https://github.com/hktalent/docker-nginx-modsecurity
cd /mytools/docker-nginx-modsecurity
git submodule update --remote

docker build -t mtx_alpine_nginx_modsecurity .

```

## Extras
If you're curious to know the difference from this dockerfile and the upstream one:
```
bash
diff <(curl -fsL https://github.com/nginxinc/docker-nginx/raw/1.15.3/mainline/alpine-perl/Dockerfile) <(curl -fsL http://github.com/elisiano/docker-nginx-modsecurity/raw/master/Dockerfile)
```
