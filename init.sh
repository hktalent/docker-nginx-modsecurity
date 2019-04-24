#!/bin/sh
grep -Ev "^$|^#" ./owasp-modsecurity-crs/crs-setup.conf.example>crs-setup.conf

echo "Include /.../crs-setup.conf" >> crs-setup.conf
echo "Include /.../rules/*.conf" >> crs-setup.conf

git submodule add https://github.com/grahamedgecombe/nginx-ct
cd nginx-ct
git submodule init
git submodule update
cd ..
git submodule add https://github.com/google/ngx_brotli
cd ngx_brotli
git submodule init
git submodule update
cd ..
git submodule add https://github.com/SpiderLabs/ModSecurity 
cd ModSecurity
git checkout v3/master
git submodule init
git submodule update
cd ..

git submodule add https://github.com/SpiderLabs/ModSecurity-nginx
cd ModSecurity-nginx
git submodule init
git submodule update
cd ..

git submodule add https://github.com/SpiderLabs/owasp-modsecurity-crs
cd owasp-modsecurity-crs
git submodule init
git submodule update
cd ..
