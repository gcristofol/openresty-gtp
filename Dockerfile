# Derived Dockerfile Example using `opm`
# https://github.com/openresty/docker-openresty
#
# Installs openresty-opm and then uses opm to install pgmoon.
#

FROM openresty/openresty:trusty

COPY conf/* /usr/local/openresty/nginx/conf/
COPY lua/*lua /usr/local/openresty/nginx/lua/

RUN ls -lisa /usr/local/openresty/nginx/conf/
RUN ls -lisa /usr/local/openresty/nginx/lua/

CMD openresty



