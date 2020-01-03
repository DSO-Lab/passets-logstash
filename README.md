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

## Logstash 插件功能说明

- geoip

内置 geoip 插件的修改版本，用于解析指定IP的归属地信息（国家、城市、经纬度）。

[详细](plugins/logstash-filter-geoip-6.0.3-java/README.md)

- ip

根据IP地址定义的RFC规范识别内外网地址以及计算 IP 地址字符串对应的数值。

[详细](plugins/logstash-filter-ip/README.md)

- url

拆分URL的 scheme、主机、URI、查询参数。

[详细](plugins/logstash-filter-url/README.md)

