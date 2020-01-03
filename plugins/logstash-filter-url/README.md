# 简介

本插件用于在Logstash接收流量数据的过程中对 URL 进行拆分，提取站点、路径，生成 URL 模板。便于后续数据分析过程中的 数据聚类操作。

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

- Logstash 7.x

# 插件安装（手工）

```
# 1. 将 logstash-filter-url 目录拷贝到 /usr/share/logstash/vendor/bundle/jruby/2.5.0/gems 目录下
cp -R ./ /usr/share/logstash/vendor/bundle/jruby/2.5.0/gems/

# 2. 修改 Logstash 根目录下的 Gemfile 文件
vi /usr/share/logstash/Gemfile
gem "logstash-filter-url", :path => "vendor/bundle/jruby/2.5.0/gems/logstash-filter-url"
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
            source => "url"
            url_tpl_name => "url_tpl"
            path_name => "path"
            site_name  => "site"
        }
    }
}

output {
    ...
}
```

所有可配置参数列表：

| 参数名       | 类型   | 必填 | 默认值  | 参数说明
|--------------|--------|------|---------|--------------------------|
| source       | string | 否   | url     | 指定获得URL的字段名
| url_tpl_name | string | 否   | url_tpl | 指定输出 URL 模板的字段名
| path_name    | string | 否   | path    | 指定输出 URL 路径部分的字段名
| site_name    | string | 否   | site    | 指定输出 URL 站点部分的字段名

# 参考资料

https://my.oschina.net/shawnplaying/blog/676575?fromerr=icPQGGiU

https://www.cnblogs.com/xing901022/p/5259750.html

