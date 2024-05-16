## 2.3.1

- 🟡[Change] 去掉了之前Log的文本修改Log传递分支名称

## 2.3.0

- 🟢[Add] 新增对于第一次分支打包没有配置文件的支持
- [Add] 增加对于--dart-define=的支持
- [Add] 支持配置上传Sentry Symbols
- [Add] 新增iOS支持自动分发到外部测试组

# 2.2.2

- [Fix] 修复了获取打包属性为上一次打包Unity出包的属性值，导致日志导出异常

# 2.2.1

- [Fix] 修复了Unity Android 新版Vulkan导致打包出问题

# 2.2.0

- [Remove] 去掉了安卓发布到蒲公英的支持
- [Add] 新增安卓对于内网Zealot的自持

## 2.1.0

- [Add] 新增支持`--[no-]supportLdClassic`是否可以选择关闭对于Xcode15 -ld-classic的支持 不然低于Xcode15无法打包的问题

## 2.0.2

- [Fix] 修复打包时候使用Build number临时创建存在不同位置
- [Fix] 修复iOS打包之前不支持build name问题

## 2.0.1

- [Fix] 修复了上传包的Build number和日志的不同 

## 2.0.0

- [Add] 目前使用Appwrite服务重构了打包的配置防止冲突

## v1.1.0

- [Add] 新增日志可以展示当前打包的版本号

## v1.0.10

- [Fix] 修复了`--tag`设置成Bool类型参数错误

## v1.0.9

- [Fix] 修复了安卓自动生成签名配置和本地配置有错误，取消了生成。

## v1.0.8

- [Change] 重构了逻辑 如果`skipUnityUpdate=true`则忽略获取Unity相关参数，逻辑更加清晰。
- [Add] 新增`--tag`参数来标识当前打包方来源

## v1.0.7

- [Fix] 修复`skipUnityUpdate`参数依然走Unity打包操作

## v1.0.6

- [Fix] 修复`skipUnityUpdate`参数依然走Unity打包操作

## v1.0.5

- [Remove] 移除`fastlane add_plugin pgyer`命令改为手动

## V1.0.4

- [Add]	新增使用`skipUnityUpdate`参数可以支持不用设置`unity`相关的参数

## v1.0.3

- [Add]    新增初始化安卓Fastlane会自动添加插件`pgyer`

## v1.0.2

- [Add]    环境配置新增BRANCH参数（origin/dev_mobshare）
- [Add]    新增提前对于`Fastlane`是否安装的检测
- [Add]    新增`skipUnityUpdate`参数可以跳过自动Unity导包更新，适合自己主动更新Unity包
- [Change] 重构了存储上一次打包信息的结构，为了可以支持共用打包配置信息
- [Fix]    修复了获取本地分支名错误的问题
- [Fix]    修复iOS发送钉钉的链接配置错误，导致企业微信重复发送
- [Fix]    修复了获取提交ID因为存在换行报错的问题
