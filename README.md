# EasyOps MongoDB 监控插件包

EasyOps MongoDB 监控插件包是适用于 EasyOps 新版监控平台，专门提供 MongoDB 监控服务的官方插件包。它提供了对 MongoDB 的常见监控指标进行采集的采集插件以及可视化的仪表盘展示。

## 目录

- [背景](#背景)
- [适用环境](#适用环境)
- [工作原理](#工作原理)
- [准备工作](#准备工作)
- [使用方法](#使用方法)
- [启动参数](#启动参数) 
- [项目内容](#项目内容)
- [维护者](#维护者)
- [许可证](#许可证)

## 背景

由于目前在 EasyOps 新版监控平台上搭建 MongoDB 监控场景需要经过以下步骤：

1. 自行搜索 MongoDB Exporter 并调试配置。
2. 在插件中心创建采集插件，使用步骤1输出的指标数据录入监控指标。
3. 使用创建的采集插件为具体的资源实例创建采集任务。
4. 理解监控指标含义后配置仪表盘展示。

所以为了实现 MongoDB 监控场景的快速搭建，该项目对 MongoDB 一些常见的监控指标及其采集脚本进行了封装，同时提供一个基本的仪表盘展示。

用户能够借助 EasyOps 平台提供的自动化工具来一键导入该插件包，真正做到 MongoDB 监控场景的开箱即用。

## 适用环境

MongoDB >= 2.1

## 工作原理

1. MongoDB 监控插件包使用了第三方的 MongoDB Exporter 进行指标采集，该 Exporter 的 GitHub 链接为 https://github.com/percona/mongodb_exporter 。

## 准备工作

1. 确认采集的 MongoDB 实例具体的监听地址和端口。
2. 确认用来连接 MongoDB 的用户和密码。该用户至少需要具备 `admin` 数据库的 `clusterMonitor` 角色（用于查看集群状态）和 `local` 数据库的读角色（用于查看表状态），可通过以下命令创建仅具有所需角色的用户。

```
use admin;
db.getSiblingDB("admin").createUser({
    user: "exporter",
    pwd: "123456",
    roles: [
        { role: "clusterMonitor", db: "admin" },
        { role: "read", db: "local" }
    ]
});
```

## 使用方法

### 导入监控插件包

1. 下载该项目的压缩包 ( https://github.com/easy-monitor/mongodb-collector-plugin/archive/master.zip )。

2. 建议解压到 EasyOps 平台服务器上的 `/data/easyops/monitor_plugin_packages` 目录下。

3. 使用 EasyOps 平台提供的自动化工具一键导入该插件包，具体命令如下，请替换其中的 `8888` 为当前 EasyOps 平台具体的 `org`。

```sh
$ cd /usr/local/easyops/collector_plugin_service/tools
$ sh plugin_op.sh install 8888 /data/easyops/monitor_plugin_packages/mongodb-collector-plugin
```

4. 导入成功后访问 EasyOps 平台的「采集插件」列表页面 ( http://your-easyops-server/next/collector-plugin )，就能看到导入的 "mongodb_collector_plugin" 采集插件。

### 启动 MongoDB Exporter

1. 可通过监控插件包提供的启动脚本启动 MongoDB Exporter，具体命令如下，请替换其中的 `--mongodb-host`、`--mongodb-port` 参数为采集的 MongoDB 的监听地址和端口，`--mongodb-user`、`--mongodb-password` 参数为用来连接 MongoDB 的用户和密码。

```sh
$ cd /data/easyops/monitor_plugin_packages/mongodb-collector-plugin/script
$ sh start_script.sh --mongodb-host 127.0.0.1 --mongodb-port 27017 --mongodb-user exporter --mongodb-password 123456
```

2. 通过访问 http://127.0.0.1:9216/metrics 来获取指标数据，请替换其中的 `127.0.0.1:9216` 为 Exporter 具体的监听地址和端口。

```sh
$ curl http://127.0.0.1:9216/metrics
```

3. 接下来可使用导入的采集插件创建采集任务来对接启动的 Exporter。

## 启动参数

| 名称 | 类型 | 必填 | 默认值 | 说明 |
| --- | --- | --- | --- | --- |
| mongodb-host | string | false | 127.0.0.1 | MongoDB 监听地址 |
| mongodb-port | int | false | 27017 | MongoDB 监听端口 |
| mongodb-user | string | false |  | MongoDB 认证用户 |
| mongodb-password | string | false |  | MongoDB 认证密码 |
| exporter-host | string | false | 127.0.0.1 | Exporter 监听地址 |
| exporter-port | int | false | 9216 | Exporter 监听端口 |
| exporter-uri | string | false | /metrics | Exporter 获取指标数据的 URI |

## 项目内容

### 目录结构

```
mongodb-collector-plugin
├── dashboard.json
├── origin_metric.json
└── script
    ├── deploy
    │   └── start_script.sh
    ├── log
    │   └── mongodb-collector-plugin.log
    ├── package.conf.yaml
    ├── plugin.yaml
    └── src
        └── mongodb_exporter
```

该项目的目录结构遵循标准的 EasyOps 监控插件包规范，具体内容如下：

- dashboard.json: 仪表盘的定义文件
- origin_metric.json: 采集插件关联的监控指标定义文件
- script: 采集插件关联的程序包目录，执行采集任务时会部署到指定的目标机器上
- script/deploy/start_script.sh: 启动脚本
- script/log: 日志文件目录
- script/package.conf.yaml: 采集插件关联的程序包的定义文件
- script/plugin.yaml: 采集插件包的定义文件
- script/src: 采集插件包的 Exporter 目录

### plugin.yaml

```yaml
# 支持 easyops/prometheus/zabbix-agent 三种采集类型
# 1. easyops: 表示使用 EasyOps Agent 进行指标采集
# 2. prometheus: 表示对接 Prometheus Exporter 进行指标采集
# 3. zabbix-agent: 表示对接 Zabbix Agent 进行指标采集
agentType: prometheus

# 采集插件的名称，也是采集插件关联的程序包名称
name: mongodb_collector_plugin
# 采集插件关联的程序包版本名称
version: 1.0.0

# 采集插件类别 
category: 数据库
# 采集插件参数列表
params:
  - mongodb_host
  - mongodb_port
  - mongodb_user
  - mongodb_password
  - exporter_host
  - exporter_port
  - exporter_uri
```

## 维护者

@easyopscyrilchen

## 许可证

[MIT](#许可证) © EasyOps
