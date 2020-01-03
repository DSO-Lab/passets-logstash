# 简介

本插件是基于 Logstash 官方的 [GEOIP](https://github.com/logstash-plugins/logstash-filter-geoip) 插件修改而来。用于在Logstash接收流量数据的过程中识别IP地址的归属地（国家、城市）及经纬度信息，用于后续可能需要的按地区归集、地图展示等。

INPUT -> `FILTER(GEOIP Filter)` -> OUTPUT

# 代码结构

```
$ tree logstash-filter-geoip
├──lib
│   │── logstash-filter-geoip_jars.rb
│   └── logstash
│       └── filters
│           │── geoip/patch.rb
│           └── geoip.rb                     # 插件主程序
│── src/main/java/org/logstash/filters
│   │── Fields.java
│   └── GeoIPFilter.java
|── vendor\jar-dependencies                  # GEO2IP相关Jar包文件
│   │── com
│       └── ...
│   └── org/logstash/filters/logstash-filter-geoip/6.0.0/logstash-filter-geoip-6.0.0.jar
└── logstash-filter-geoip.gemspec
```

# 环境要求

- Logstash 7.x

# 插件安装（手工）

```
# 将 logstash-filter-geoip-6.0.3-java 目录拷贝到 /usr/share/logstash/vendor/bundle/jruby/2.5.0/gems 目录下覆盖同名目录及文件：
cp -R ./ /usr/share/logstash/vendor/bundle/jruby/2.5.0/gems/logstash-filter-geoip-6.0.3-java/
```

# 基本配置

```
input {
    ...
}

filter {
    ...
    geoip {
        source => "ip"
        target => "geoip"
        fields => ["city_name", "country_name", "location"]
        database => '/usr/share/logstash/config/GeoLite2-City.mmdb'
        locale => 'zh-CN'
    }
    ...
}

output {
    ...
}
```

所有可配置参数列表：

| 参数名       | 类型   | 必填 | 默认值  | 参数说明
|--------------|--------|------|---------|--------------------------|
| source       | string | 是   | ip      | 指定获得IP的字段名
| target       | string | 否   | geoip   | 指定输出 IP 归属地信息的字段名，不建议修改
| fields       | array  | 否   | 全部    | 指定输出到 geoip 的属性列表，不建议修改
| database     | path   | 否   | 内置    | 指定IP归属地数据库文件的路径，不建议修改
| locale       | string | 否   | en-US   | 指定IP所属国家、城市以哪种语言输出

# 参考资料

https://my.oschina.net/shawnplaying/blog/676575?fromerr=icPQGGiU

https://www.cnblogs.com/xing901022/p/5259750.html



# 构建方法

1. 修改 build.gradle，将其中的 logstashCorePath 替换为 Logstash 中 logstash-core 目录所在的位置

2. 执行下面的命令：

```
gradlew

gradlew build
```

3. 将 build/libs/ 目录中提取生成的 logstash-filter-geoip-6.0.0.jar 放到 vendor/jar-dependencies/org/logstash/filters/logstash-filter-geoip/6.0.0/ 目录下

4. 删除 build 目录
