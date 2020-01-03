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

无

# 插件安装（手工）

```
# 1. 创建gem包目录
mkdir /usr/share/logstash/vendor/bundle/jruby/2.5.0/gems/logstash-filter-ip-1.0.0

# 2. 将 logstash-filter-ip 目录下的所有文件拷贝到这个目录下

# 3. 修改根Gemfile文件
vi /usr/share/logstash/Gemfile
gem "logstash-filter-ip", :path => "vendor/bundle/jruby/2.5.0/gems/logstash-filter-ip-1.0.0"
```

# 基本配置

```
input {
    ...
}

filter {
    ...
    ip {
        format_num => {
            "src_addr" => "src_num"
            "dst_addr" => "dst_num"
        }
        judge_network => {
            "src_addr" => "src_inner"
            "dst_addr" => "dst_inner"
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
| format_num | hash | 是 | 无 | 格式：{ 输入字段 => 输出字段 } |
| judge_network | hash | 是 | 无 | 格式：{ 输入字段 => 输出字段 } |

# 参考资料

https://my.oschina.net/shawnplaying/blog/676575?fromerr=icPQGGiU

https://www.cnblogs.com/xing901022/p/5259750.html

