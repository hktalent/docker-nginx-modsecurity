docker run -it 5cb3aa00f899 /bin/sh
tmpC2="f8fa4894a145"
docker cp ngx_brotli $tmpC2:/usr/src/
docker cp nginx-ct $tmpC2:/usr/src/
docker cp ModSecurity-nginx $tmpC2:/usr/src/
docker cp ModSecurity $tmpC2:/usr/src/
docker cp owasp-modsecurity-crs $tmpC2:/etc/nginx/
docker cp nginx.conf $tmpC2:/etc/nginx/
docker cp nginx.vh.default.conf $tmpC2:/etc/nginx/conf.d/default.conf
docker cp nginx.tar.gz.asc $tmpC2:/usr/src/
docker cp nginx.tar.gz $tmpC2:/usr/src/
docker cp OpenSSL_1_1_1.tar.gz $tmpC2:/usr/src/


docker ps -a|grep "/bin/sh -c"|grep -v "openvas9"|awk '{print $1}'|xargs docker rm
docker images|grep none|awk '{print $3}'|xargs docker rmi

/usr/sbin/nginx -t

git commit -m "add spdy zlib1211" .;git push
