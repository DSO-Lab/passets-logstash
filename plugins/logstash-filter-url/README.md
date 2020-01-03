# 简介

本插件用于在Logstash接收流量数据的过程中对URL进行处理，提取 scheme、host、path和query信息。

INPUT -> `FILTER(URL Filter)` -> OUTPUT

# 代码结构

```
$ tree logstash-filter-url
├──lib
│   └── logstash
│       └── filters
│           └── url.rb
└── logstash-filter-url.gemspec
```

# 环境要求

无

# 插件安装（手工）

```
# 1. 创建gem包目录
mkdir /usr/share/logstash/vendor/bundle/jruby/2.5.0/gems/logstash-filter-url-1.0.0

# 2. 将 logstash-filter-url 目录下的所有文件拷贝到这个目录下

# 3. 修改根Gemfile文件
vi /usr/share/logstash/Gemfile
gem "logstash-filter-url", :path => "vendor/bundle/jruby/2.5.0/gems/logstash-filter-url-1.0.0"
```

# 基本配置

```
input {
    ...
}

filter {
    ...
    if [protocol] == 'HTTP-Response' {
        url {
            source => "http_uri"
            target => "url"
        }
    }
}

output {
    ...
}
```

所有可配置参数列表：

| 参数名 | 类型 | 必填项 | 默认值 | 说明 |
|--------|------|--------|--------|------|
| source | string | 是 | http_uri | 获取URL的字段名 |
| target | string | 是 | url | 回填数据的字段名 |

# 参考资料

https://my.oschina.net/shawnplaying/blog/676575?fromerr=icPQGGiU

https://www.cnblogs.com/xing901022/p/5259750.html

