FROM alpine

LABEL maintainer="51pwn.com<s1pwned@gmail.com>"
# https://hub.docker.com/_/alpine
# https://hub.docker.com/_/nginx
# https://github.com/nginxinc/docker-nginx/blob/7890fc2342613e6669ad83ceead9c81136d2cc0a/mainline/alpine/Dockerfile
ENV NGINX_VERSION 1.15.9
ENV GPG_KEYS B0F4253373F8F6F510D42178520A9993A1C052F8

# start haproxy，https://github.com/shubb30/haproxy-keepalived/blob/master/haproxy.cfg
# https://hub.docker.com/r/itsthenetwork/alpine-haproxy/
# RUN echo "http://nl.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories && \
# apk add -U -v haproxy openssl-dev && \
# rm -rf /var/cache/apk/* /tmp/*
# COPY haproxy.cfg /etc/haproxy/haproxy.cfg
# COPY errorfiles/* /etc/haproxy/
# COPY haproxy.sh /usr/bin/haproxy.sh
# RUN chmod +x /usr/bin/haproxy.sh
# ENTRYPOINT ["/usr/bin/haproxy.sh"]
# end haproxy
RUN mkdir -p /usr/src && mkdir -p /etc/nginx && mkdir -p /etc/nginx/conf.d \
	apk update && apk upgrade
COPY ngx_brotli /usr/src/
COPY nginx-ct /usr/src/
COPY nginx.tar.gz.asc /usr/src/
COPY nginx.tar.gz /usr/src/
COPY OpenSSL_1_1_1.tar.gz /usr/src/
COPY ModSecurity-nginx /usr/src/
COPY ModSecurity /usr/src/
COPY owasp-modsecurity-crs /etc/nginx/
COPY nginx.conf /etc/nginx/
COPY nginx.vh.default.conf /etc/nginx/conf.d/default.conf

# find /usr/src -type d -name ".git"|xargs -I % rm -rf {} % \
RUN GPG_KEYS=B0F4253373F8F6F510D42178520A9993A1C052F8 \
	&& CONFIG="\
		--prefix=/etc/nginx \
		--sbin-path=/usr/sbin/nginx \
		--modules-path=/usr/lib/nginx/modules \
		--conf-path=/etc/nginx/nginx.conf \
		--error-log-path=/var/log/nginx/error.log \
		--http-log-path=/var/log/nginx/access.log \
		--pid-path=/var/run/nginx.pid \
		--lock-path=/var/run/nginx.lock \
		--http-client-body-temp-path=/var/cache/nginx/client_temp \
		--http-proxy-temp-path=/var/cache/nginx/proxy_temp \
		--http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
		--http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
		--http-scgi-temp-path=/var/cache/nginx/scgi_temp \
		--user=nginx \
		--group=nginx \
		--with-http_ssl_module \
		--with-http_realip_module \
		--with-http_addition_module \
		--with-http_sub_module \
		--with-http_dav_module \
		--with-http_flv_module \
		--with-http_mp4_module \
		--with-http_gunzip_module \
		--with-http_gzip_static_module \
		--with-http_random_index_module \
		--with-http_secure_link_module \
		--with-http_stub_status_module \
		--with-http_auth_request_module \
		--with-http_xslt_module=dynamic \
		--with-http_image_filter_module=dynamic \
		--with-http_geoip_module=dynamic \
		--with-http_perl_module=dynamic \
		--with-threads \
		--with-stream \
		--with-stream_ssl_module \
		--with-stream_ssl_preread_module \
		--with-stream_realip_module \
		--with-stream_geoip_module=dynamic \
		--with-http_slice_module \
		--with-mail \
		--with-mail_ssl_module \
		--with-compat \
		--with-file-aio \
		--with-openssl=/usr/src/openssl \
		--with-http_v2_module \
		--add-module=/usr/src/ModSecurity-nginx \
		--add-module=/usr/src/ngx_brotli \
		--add-module=/usr/src/nginx-ct \
	" \
	&& addgroup -S nginx \
	&& adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx \
	&& apk add --no-cache --virtual .build-deps \
		gcc \
		libc-dev \
		make \
		file \
		doxygen \
		openssl-dev \
		pcre-dev \
		zlib-dev \
		linux-headers \
		curl \
		gnupg \
		libxslt-dev \
		gd-dev \
		geoip-dev \
		perl-dev \
		bash \
	&& apk add --no-cache --virtual .libmodsecurity-deps \
		pcre-dev \
		libxml2-dev \
		git \
		libtool \
		automake \
		autoconf \
		g++ \
		flex \
		bison \
		yajl-dev \
	# Add runtime dependencies that should not be removed
	&& apk add --no-cache \
		yajl \
		libstdc++ \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& cd /usr/src/ \
	found=''; \
	for server in \
		ha.pool.sks-keyservers.net \
		hkp://keyserver.ubuntu.com:80 \
		hkp://p80.pool.sks-keyservers.net:80 \
		pgp.mit.edu \
	; do \
		echo "Fetching GPG key $GPG_KEYS from $server"; \
		gpg --keyserver "$server" --keyserver-options timeout=10 --recv-keys "$GPG_KEYS" && found=yes && break; \
	done; \
	test -z "$found" && echo >&2 "error: failed to fetch GPG key $GPG_KEYS" && exit 1; \
	gpg --batch --verify nginx.tar.gz.asc nginx.tar.gz \
	&& tar -zxC /usr/src -f nginx.tar.gz \
	&& tar -zxC /usr/src -f OpenSSL_1_1_1.tar.gz \
	&& mv /usr/src/openssl-OpenSSL_1_1_1 /usr/src/openssl \
	# && rm OpenSSL_1_1_1.tar.gz \
	# && rm nginx.tar.gz \
	# && rm -rf "$GNUPGHOME" nginx.tar.gz.asc \
	cd /usr/src/ModSecurity \
	&& sed -i -e 's/u_int64_t/uint64_t/g' \
		./src/actions/transformations/html_entity_decode.cc \
		./src/actions/transformations/html_entity_decode.h \
		./src/actions/transformations/js_decode.cc \
		./src/actions/transformations/js_decode.h \
		./src/actions/transformations/parity_even_7bit.cc \
		./src/actions/transformations/parity_even_7bit.h \
		./src/actions/transformations/parity_odd_7bit.cc \
		./src/actions/transformations/parity_odd_7bit.h \
		./src/actions/transformations/parity_zero_7bit.cc \
		./src/actions/transformations/parity_zero_7bit.h \
		./src/actions/transformations/remove_comments.cc \
		./src/actions/transformations/url_decode_uni.cc \
		./src/actions/transformations/url_decode_uni.h \
	# && find ../ -type d -name ".git" -exec rm -rf {} \\;\
    sh build.sh \
	&& ./configure \
	&& make \
	&& make install \
	&& cd /usr/src/nginx-$NGINX_VERSION \
	&& ./configure $CONFIG --with-debug \
	&& make -j$(getconf _NPROCESSORS_ONLN) \
	&& mv objs/nginx objs/nginx-debug \
	&& mv objs/ngx_http_xslt_filter_module.so objs/ngx_http_xslt_filter_module-debug.so \
	&& mv objs/ngx_http_image_filter_module.so objs/ngx_http_image_filter_module-debug.so \
	&& mv objs/ngx_http_geoip_module.so objs/ngx_http_geoip_module-debug.so \
	&& mv objs/ngx_http_perl_module.so objs/ngx_http_perl_module-debug.so \
	&& mv objs/ngx_stream_geoip_module.so objs/ngx_stream_geoip_module-debug.so \
	&& ./configure $CONFIG \
	&& make -j$(getconf _NPROCESSORS_ONLN) \
	&& make install \
	&& rm -rf /etc/nginx/html/ \
	&& mkdir -p /usr/share/nginx/html/ \
	&& install -m644 html/index.html /usr/share/nginx/html/ \
	&& install -m644 html/50x.html /usr/share/nginx/html/ \
	&& install -m755 objs/nginx-debug /usr/sbin/nginx-debug \
	&& install -m755 objs/ngx_http_xslt_filter_module-debug.so /usr/lib/nginx/modules/ngx_http_xslt_filter_module-debug.so \
	&& install -m755 objs/ngx_http_image_filter_module-debug.so /usr/lib/nginx/modules/ngx_http_image_filter_module-debug.so \
	&& install -m755 objs/ngx_http_geoip_module-debug.so /usr/lib/nginx/modules/ngx_http_geoip_module-debug.so \
	&& install -m755 objs/ngx_http_perl_module-debug.so /usr/lib/nginx/modules/ngx_http_perl_module-debug.so \
	&& install -m755 objs/ngx_stream_geoip_module-debug.so /usr/lib/nginx/modules/ngx_stream_geoip_module-debug.so \
	&& ln -s ../../usr/lib/nginx/modules /etc/nginx/modules \
	&& strip /usr/sbin/nginx* \
	&& strip /usr/lib/nginx/modules/*.so \
	&& cd /usr/src \
	&& rm -rf /usr/src/nginx-$NGINX_VERSION \
	\
	# Bring in gettext so we can get `envsubst`, then throw
	# the rest away. To do this, we need to install `gettext`
	# then move `envsubst` out of the way so `gettext` can
	# be deleted completely, then move `envsubst` back.
	&& apk add --no-cache --virtual .gettext gettext \
	&& mv /usr/bin/envsubst /tmp/ \
	&& runDeps="$( \
		scanelf --needed --nobanner /usr/sbin/nginx /usr/lib/nginx/modules/*.so /tmp/envsubst \
			| awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
			| sort -u \
			| xargs -r apk info --installed \
			| sort -u \
	)" \
	&& apk add --no-cache --virtual .nginx-rundeps $runDeps \
	&& apk del .build-deps \
	&& apk del .libmodsecurity-deps \
	&& apk del .gettext \
	&& mv /tmp/envsubst /usr/local/bin/ \
	&& rm -rf /usr/src/ModSecurity /usr/src/ModSecurity-nginx \
	# Bring in tzdata so users could set the timezones through the environment
	# variables
	&& apk add --no-cache tzdata \
	# forward request and error logs to docker log collector
	&& mkdir -p /var/log/nginx && ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log

ENV APP_HOME=/var/cache/nginx
ENV BUNDLE_IGNORE_MESSAGES="true"
WORKDIR $APP_HOME

# 用nginx转发，就暂且不用keepalived
# RUN apk update && apk upgrade
# RUN apk add --no-cache curl ipvsadm iproute2 openrc keepalived && \
#     rm -f /var/cache/apk/* /tmp/* 
# COPY entrypoint.sh /entrypoint.sh 
# RUN chmod +x /entrypoint.sh
# ENTRYPOINT ["/entrypoint.sh"]

COPY allCmnd.sh /allCmnd.sh
RUN chmod +x /allCmnd.sh

EXPOSE 80 443
STOPSIGNAL SIGTERM

ENTRYPOINT ["/allCmnd.sh"]

CMD ["/bin/bash"]
