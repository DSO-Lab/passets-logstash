FROM logstash:7.4.1

LABEL maintainer="tanjelly@gmail.com" version="1.0.0"

USER root

ENV TZ="Asia/Shanghai" ELASTICSEARCH_URL="localhost:9200" ELASTICSEARCH_INDEX="logstash-passets" INNER_IP_LIST="10.0.0.0-10.255.255.255,172.16.0.0-172.31.255.255,192.168.0.0-192.168.255.255,169.254.0.0-169.254.255.255,127.0.0.1-127.0.0.255"

WORKDIR /usr/share/logstash/

COPY config/ config/
COPY plugins/ vendor/bundle/jruby/2.5.0/gems/

VOLUME /usr/share/logstash/logs /usr/share/logstash/data

RUN rm -f config/logstash-sample.conf && \
    sed -i '/gem "logstash-filter-xml"/i gem "logstash-filter-ip", :path => "vendor/bundle/jruby/2.5.0/gems/logstash-filter-ip"' Gemfile && \
    sed -i '/gem "logstash-filter-xml"/i gem "logstash-filter-url", :path => "vendor/bundle/jruby/2.5.0/gems/logstash-filter-url"' Gemfile && \
    cd config/ && \
    tar -C ./ --strip-components=1 -zxf GeoLite2-City.tar.gz && rm -f GeoLite2-City.tar.gz && \
    cd ../vendor/bundle/jruby/2.5.0/gems/logstash-filter-geoip-6.0.3-java/ && \
    rm -rf gradle src gradlew.* build.gradle

EXPOSE 5044

ENTRYPOINT ["bin/logstash", "-f", "config/logstash.conf", "--config.reload.automatic"]