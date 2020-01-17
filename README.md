# Passets Logstash 数据处理模块

本模块为 [passets](https://github.com/DSO-Lab/passets) 系统一个组件，用于处理接收到的 syslog 流量数据，并对其进行内外网地址识别、URL拆分、IP定位等操作。

本项目基于 Logstash 的过滤插件来运行。

## 运行环境

- [Logstash](https://www.elastic.co/cn/products/logstash) 7.4.x

## 容器镜像构建

构建 X86_64 镜像：

```
docker build -t dsolab/passets-logstash:<tag> .
```

构建 ARMv7 镜像：

```
docker build -f Dockerfile_armv7 -t dsolab/passets-logstash:<tag>_armv7 .
```

## 容器启动

### 启动命令
```
docker run -it --rm -e ELASTICSEARCH_URL=x.x.x.x:9200 -p 5044:5044/udp dsolab/passets-logstash:<tag>
```

###  使用 docker-compose 启动

docker-compose.yml
```
version: "3"

services:
  logstash:
    build: .
    image: dsolab/passets-logstash:<tag>
    container_name: passets-logstash
    environment:
      - TZ=Asia/Shanghai
      - ELASTICSEARCH_URL=http://<elasticsearch-host>:9200/  # ES地址
    ports:
      - "5044:5044/udp"
```

构建:
```
docker-compose build
```

启动：
```
docker-compose up -d
```

## 文件说明

```
Dockerfile               # 容器镜像环境配置文件
Dockerfile_armv7         # 容器镜像环境配置文件（ARMv7)
docker-compose.yml       # 容器启动配置文件
config                   # Logstash 配置文件目录
  logstash.yml           # Logstash 运行配置
  logstash.conf          # Logstash 数据处理配置
  log4j2.properties      # Logstash 日志记录配置
  passets.json           # 资产数据在ES上的索引模板
  GeoLite2-City.tar.gz   # IP 定位数据库
plugins
  logstash-filter-geoip-6.0.3-java # IP 归属地、经纬度识别插件目录
    ...
  logstash-filter-ip               # IP 转换、内网识别插件目录
    ...
  logstash-filter-url              # URL 拆分插件目录
    ...
```

## 数据处理说明

- [geoip](plugins/logstash-filter-geoip-6.0.3-java/README.md)

内置 geoip 插件的修改版本，用于解析指定IP的归属地信息（国家、城市、经纬度）。

- [ip](plugins/logstash-filter-ip/README.md)

根据IP地址定义的RFC规范识别内外网地址以及计算 IP 地址字符串对应的数值。

- [url](plugins/logstash-filter-url/README.md)

提取URL中的站点、路径和参数模板信息。

## FAQ

> 如何更新 IP 定位数据库？

Passets 使用了 GEO2IP 的城市数据库（GeoLite2-City），由于该数据库已经不提供公开下载，你需要免费[注册一个 MaxMind 帐号](https://www.maxmind.com/en/geolite2/signup)，登录成功之后即可下载。

将下载的 GeoLite2-City_yyyyMMdd.tar.gz(yyyyMMdd为年月日)文件重命名为 GeoLite2-City.tar.gz，放到 [config](./config/) 目录下，然后重新构建容器镜像即可。

