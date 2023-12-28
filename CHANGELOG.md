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
