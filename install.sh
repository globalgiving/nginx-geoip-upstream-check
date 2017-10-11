#!/bin/bash

# PGP key & update site for maxmind (geoip DB updater)
apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-keys DE1997DCDE742AFA
echo "deb http://ppa.launchpad.net/maxmind/ppa/ubuntu xenial main" >> /etc/apt/sources.list

apt-get update
apt-get install --no-install-recommends --no-install-suggests -y libperl-dev libgeoip-dev ca-certificates gettext-base geoipupdate git gcc wget libpcre3-dev libssl-dev make build-essential zlib1g-dev libbz2-dev unzip

#install nginx
cd /tmp
git clone https://github.com/yaoweibin/nginx_upstream_check_module.git
wget 'http://nginx.org/download/nginx-1.9.15.tar.gz'
tar -xzvf nginx-1.9.15.tar.gz
cd nginx-1.9.15
patch -p0 < ../nginx_upstream_check_module/check_1.9.2+.patch
./configure --prefix=/etc/nginx \
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
    --with-http_geoip_module \
    --with-http_perl_module \
    --with-threads \
    --with-stream \
    --with-stream_ssl_module \
    --with-http_slice_module \
    --with-mail \
    --with-mail_ssl_module \
    --with-file-aio \
    --with-ipv6 \
    --with-http_v2_module \
    --with-cc-opt='-g -O2 -fstack-protector-strong -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2' \
    --with-ld-opt='-Wl,-Bsymbolic-functions -Wl,-z,relro -Wl,--as-needed' \
    --with-ipv6 \
    --add-module=../nginx_upstream_check_module
make
make install
apt-get remove -y git gcc wget libpcre3-dev libssl-dev make build-essential zlib1g-dev libbz2-dev unzip
apt-get clean

cd /
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
rm -fr /tmp/*

mkdir /var/log/nginx
mkdir /etc/nginx/conf.d
mkdir /var/cache/nginx
rm -fr /etc/nginx/*.default
adduser --system --no-create-home --shell /bin/false --group --disabled-login nginx
