# 上游项目

本仓库不包含以下项目的文件，只引用。使用者请自行从原项目获取，并遵守各自的许可证。

## 1. coolhpj/uu-remote-wol-router-helper

- 作者：coolhpj
- 许可证：MIT（以原项目为准）
- 版本：v0.1.0-beta.2（2026-10-26 实测时用的版本）
- 用途：把路由器上已装的老 UU 插件迁移到官方新版，并提供 monitor、启动包装（xnetease-uu）和开机脚本（/data/uu-v14/auto.sh，firewall include）。
- 关键设计（实测核对过）：
  - 默认关闭安装门禁，须显式确认语 + 与官方包 MD5 绑定的 smoke-pass + 老插件四件齐全（manifest、start_script、installPlugin JSON、start_script 含 xnetease-uu），缺则退出。
  - `diagnose` 是只读检测，不装东西；`stage` 只写 /tmp，不动持久区；`smoke-test` 是临时测新版，测完要恢复老版；`install` 才是持久迁移，会备份、换文件、注册 firewall include，45 秒内健康不过自动回滚。
  - XiaoQiang 的 smoke-test 在实测时未接入 `uu-helper.sh`，须直接跑 `platforms/xiaoqiang/smoke-test.sh`，且其检测逻辑在 busybox 上有截断问题，见本仓库 `patches/`。

## 2. edwardvon/uuplugin-redmi-ax6000

- 作者：edwardvon
- 许可证：以原项目为准（原项目未明确标出开源许可证时，按原项目声明处理，不要擅自改许可证）
- 版本：2023 年从小米 AX6000 抓包的网易 UU 插件，manifest 4.0.2、uu.conf v2.7.2
- 用途：作为 coolhpj 迁移的前置种子。插件 ID 与 coolhpj 门禁同为 `2882303761518031252`。
- 注意：
  - 包里含网易 UU 的二进制（`uuplugin` 等）和 lib 文件，这些不是开源代码，本仓库不收录、不分发。
  - 老包无 guardian、无 xtables，monitor 每 60 秒检查、无退避地重启 uuplugin。
  - 作者 2026-10-13 称已无 AX6000、方法可能过时，实测时仍可用作种子，但长期用应迁移到官方新版。

## 获取方式（示例，具体以原项目 README 为准）

```sh
# coolhpj（路由器上 busybox wget 不认 https 时用 curl）
curl -L -o uu-helper.tar.gz https://codeload.github.com/coolhpj/uu-remote-wol-router-helper/tar.gz/refs/heads/main
tar -xzf uu-helper.tar.gz
cd uu-remote-wol-router-helper-main

# edwardvon 种子（只在路由器上做无自启动测试时用，不要直接做自启动）
curl -L -o uuplugin.tar.gz https://codeload.github.com/edwardvon/uuplugin-redmi-ax6000/tar.gz/refs/heads/main
tar -xzf uuplugin.tar.gz
```

> 实际下载地址、分支名以原项目当前页面为准，不要凭记忆猜 URL。
