FROM debian:9 as builder

RUN apt-get update -q
RUN apt-get install -yq lua5.1 lua5.1-dev unzip libpcre3-dev zlib1g-dev build-essential checkinstall wget -yq


WORKDIR /build/

RUN wget https://github.com/SlastikhinNikita/JenHook/raw/master/nginx.conf
RUN wget https://github.com/SlastikhinNikita/JenHook/raw/master/index.html
RUN mkdir /usr/include/lua5.1/include/
#RUN ls /usr/include/lua5.1/ /usr/include/lua5.1/include/
RUN ln -s /usr/lib/x86_64-linux-gnu/liblua5.1.so /usr/local/lib/liblua.so

RUN wget 'http://nginx.org/download/nginx-1.14.0.tar.gz' && \
  tar -xzvf nginx-1.14.0.tar.gz && \
  rm nginx-1.14.0.tar.gz

WORKDIR /build/nginx-1.14.0/

RUN wget https://github.com/simplresty/ngx_devel_kit/archive/master.zip &&\
  unzip master.zip && \
  rm master.zip && \
  mv ngx_devel_kit-master ngx_devel_kit

RUN wget https://github.com/openresty/lua-nginx-module/archive/master.zip && \
  unzip master.zip && rm master.zip && \
  mv lua-nginx-module-master lua-nginx-module

ENV LUA_LIB=/usr/lib/x86_64-linux-gnu/ LUA_INC=/usr/include/lua5.1/

RUN ./configure --prefix=/opt/nginx \
  --with-ld-opt="-Wl,-rpath,/usr/lib/x86_64-linux-gnu/" \
  --add-module=./ngx_devel_kit \
  --add-module=./lua-nginx-module
#  --with-lua-prefix=/usr/include/lua5.1

RUN make -j2
RUN checkinstall -y
RUN find / -name liblua5.1.so.0


FROM debian:9

RUN apt-get update -q && apt-get install -yq lua5.1

WORKDIR /app/
COPY --from=builder /build/nginx-1.14.0/*.deb /app/
COPY --from=builder /usr/lib/x86_64-linux-gnu/liblua5.1.so.0 /usr/lib/x86_64-linux-gnu/liblua5.1.so.0

RUN dpkg -i /app/*.deb
RUN mkdir /opt/nginx/logs/
CMD /opt/nginx/sbin/nginx -g daemon\ off\;
COPY --from=builder /build/nginx.conf /opt/nginx/conf/
COPY --from=builder /build/index.html /opt/nginx/html

