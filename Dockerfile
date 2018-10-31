FROM alpine:3.6
LABEL maintainer="Nurd Platform Team"

ARG KONG_VERSION=0.14.0
ARG KONG_SETUP=kong

WORKDIR /

RUN echo "==> Configuring Kong..." \
	&& apk add --no-cache --virtual .build-deps wget tar ca-certificates \
	&& apk add --no-cache libgcc openssl pcre perl tzdata curl git \
	&& wget -O $KONG_SETUP.tar.gz "https://bintray.com/kong/kong-community-edition-alpine-tar/download_file?file_path=kong-community-edition-$KONG_VERSION.apk.tar.gz" 

RUN tar xzf $KONG_SETUP.tar.gz  \
	&& rm -f $KONG_SETUP.tar.gz \
	&& apk del .build-deps \
	&& echo "==> Kong Finishing..." \

RUN echo "==> Configuring Kong Plugins..." \
 	&& luarocks install https://luarocks.org/manifests/kong/kong-plugin-zipkin-0.0.4-0.rockspec \
 	&& luarocks remove --force opentracing \
 	&& luarocks install https://raw.githubusercontent.com/rocks-moonscript-org/moonrocks-mirror/master/opentracing-0.0.2-0.src.rock \
 	&& luarocks remove --force kong-prometheus-plugin \
 	&& luarocks install https://raw.githubusercontent.com/yciabaud/kong-plugin-prometheus/master/kong-plugin-prometheus-0.1.1-1.rockspec \
	&& echo "==> Kong Plugins Finishing..."  	

COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY kong.conf /kong.conf
ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444