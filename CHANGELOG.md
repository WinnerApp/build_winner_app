
## 3.3.0

- [Add] 新增获取不到上一次日志节点则默认获取最近十条日志
- [Fix] 修复了日志获取不到的问题

## 3.2.1

- [Fix] 修复了第一次打分支代码日志太长导致显示不了 目前处理flutter和unity最多一次性显示20条

## 3.2.0

- [Add]新增在日志添加显示Unity分支和Flutter最后打包节点和Unity最后打包节点
- [Add] 新增切换分支之前会重置本地分支缓存
- [Add] 新增上传日志包含Tag信息

## 3.1.4

- [Remove] 去掉了新分支会要求填写上一次commit id的要求

## 3.1.3

- 发布正式版本[3.1.3] 支持Sentry 文件上传
 
## 3.0.0-beta31

- [Change] 修改了iOS fastlane的配置
- [Add] 新增fastfile支持配置外部fastfile文件

## 3.0.0-beta30

- [Fix] 修复打包iOS因为pod库版本问题报错

## 3.0.0-beta29

- [Fix] 修复了生成的Build number可能导致安卓无法打包的问题
- [Fix] 修改了获取最新分支打包因为数量限制导致逻辑出现问题

## 3.0.0-beta28

- [Remove] 移除build_time不需要的字段

## 3.0.0-beta27

- [Change] 升级AppwriteSDK 12.0.0->12.1.0

## 3.0.0-beta26

- [Fix] 尝试修复build_time字段类型错误问题

## 3.0.0-beta25

- [Fix] 修复了切换Unity新分支报错

## 3.0.0-beta24

- [Fix] 修复如果后台最新的值为空会导致逻辑错误

## 3.0.0-beta23

- [Fix] 修复使用reject_build_waiting_for_review取消上一次审核

## 3.0.0-beta22

- [Fix] 修复发布公开组可能因为上一个在审核导致失败

## 3.0.0-beta21

- [Change] 修改参数skip_waiting_for_build_processing=false 为了尝试解决不会分发给外部组的问题


## 3.0.0-beta20

- [Change] 升级dart_appwrite到12 适配最新的Appwrite服务器16

## 3.0.0-beta19

- [Fix] 修复生成包渠道名字错误

## 3.0.0-beta18

- [Fix] 修复复制文件因为路径不存在报错

## 3.0.0-beta17

- [Fix] 修复FLUTTER_LAST_COMMIT_HASH和UNITY_LAST_COMMIT_HASH参数非必须变成必须

## 3.0.0-beta16

- [Fix] 修复了BUILD_NUMBER成为了必备的设置错误

## 3.0.0-beta15

- [Add] 新增发布iOS的时候自动通知[内部测试公开组]

## 3.0.0-beta14

- [Add] 新增如果是第一次打对应分支的包 则必须提供对应的上一次的节点ID

## 3.0.0-beta13

- [Add] 新增打包自动复制到临时目录

## 3.0.0-beta12

- 🟢[Add] 新增支持自定义BuildNumber 用于可以打相同版本的安卓渠道包

## 3.0.0-beta11

- 🟢[Add] 新增支持自定义的上传和发布日志参数 

## 3.0.0-beta10

- 🔴[Fix] 再次修复上传日志报错

## 3.0.0-beta9

- 🔴[Fix] 修复了上传日志多处了字符导致报错

## 3.0.0-beta8

- 🔴[Fix] 修复了提前初始化Fastlane导致被回滚的问题

- 🔴[Fix] 修复了日志为空不通知
  
- 🔴[Fix] 修复了通知的日志

## 3.0.0-beta7

- 🔴[Fix] 修复生成dart_define.json文件因为存在导致值不更新

## 3.0.0-beta6

- 🟢[Add] 新增支持Unity强制打包

## 3.0.0-beta5

- 🔴[Fix] 修复了安卓版本设置之后没有报错

## 3.0.0-beta4

- 🔴[Fix] 修复了无法设置版本号和build number的问题

## 3.0.0-beta3

- 🟢[Add] 新增iOS支持ZEALOT_CHANNEL_KEY参数可以取消自动上传功能

## 3.0.0-beta2

- 🟡[Change] 修复了2.0架构的打包问题

## 2.10.0

- 🟢[Add] 新增--split-debug-info参数支持

## 2.9.0

- 🟢[Add] 新增addUmengPushConfig命令可以设置Umeng 通知的配置

## 2.8.0

- 🟢[Add] 新增支持Umeng Push配置支持可以切换正式和测试配置

## 2.7.1

- 🔴[Fix] 修复了无法上传分支的日志问题

## 2.7.0

- 🟢[Add] 支持Fvm flutter进行打包

## 2.6.1

- 🔴[Fix] 获取日志解析错误

## 2.6.0

- 🟢[Add] 新增如果是应用市场的包则不通知群

## 2.5.0

- 🟢[Add] 新增不设置ZEALOT_CHANNEL_KEY则不上传Apk包和发送版本更新通知
- 🟢[Add] 新增upload_apk_channel命令可以单独上传已经存在的包到对应频道

## 2.4.0

- 🟢[Add] 新增iOS在发布应用商店版本自动移除Setting Bundle

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
