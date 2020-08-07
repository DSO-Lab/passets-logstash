# 简介

本插件用于在 Logstash 接收流量数据的过程中对IP进行内外网归类、IP地址数值化转换。

INPUT -> `FILTER(IP Filter)` -> OUTPUT

# 代码结构

```
$ tree logstash-filter-ip
├──lib
│   └── logstash
│       └── filters
│           └── ip.rb
└── logstash-filter-ip.gemspec
```

# 环境要求

- Logstash 7.x

# 插件安装（手工）

```
# 1. 将 logstash-filter-ip 目录拷贝到 /usr/share/logstash/vendor/bundle/jruby/2.5.0/gems 目录下:
cp -R ./ /usr/share/logstash/vendor/bundle/jruby/2.5.0/gems/logstash-filter-ip/

# 3. 修改 logstash 根目录下的 Gemfile 文件，添加如下行：
vi /usr/share/logstash/Gemfile
gem "logstash-filter-ip", :path => "vendor/bundle/jruby/2.5.0/gems/logstash-filter-ip"
```

# 基本配置

```
input {
    ...
}

filter {
    ...
    ip {
        source => 'ip'
        inner_name => 'inner'
    }
}

output {
    ...
}
```

所有可配置参数列表：

| 参数名      | 类型   | 必填 | 默认值 | 参数说明
|-------------|--------|------|--------|---------------------------------|
| source      | string | 是   | ip     | 指定IP地址在消息中的参数名
| inner_name  | string | 是   | inner  | 指定输入的用于区分内外部IP的字段名，若IP为内部IP，则输入值为 true，否则为 false

# 参考资料

https://my.oschina.net/shawnplaying/blog/676575?fromerr=icPQGGiU

https://www.cnblogs.com/xing901022/p/5259750.html

