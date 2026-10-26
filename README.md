# uu-remote-wol-redmi-ax6000

用红米 AX6000（RB06）做 UU 远程辅助设备，在外网零购置远程开机华硕 Mini PC PN51-E1 的实测整合。

> 本仓库只整合文档、步骤和本地适配补丁，不分发网易 UU 的二进制，也不包含任何私人信息（WiFi 名、UU 账号、MAC 地址等一律用占位符）。

## 硬件

- 路由器：红米 AX6000 / RB06，XiaoQiang 固件，OpenWrt 派生，aarch64，二级路由（WAN 接上级光猫，无公网 IP）
- 被控电脑：华硕 Mini PC PN51-E1，Windows，有线网卡，MAC 记为 `XX:XX:XX:XX:XX:XX`（请填你自己的）
- 手机：UU 主机加速器 + UU 远程，同一个 UU 账号

## 上游项目（只引用，不照搬二进制）

- `coolhpj/uu-remote-wol-router-helper`（MIT，v0.1.0-beta.2）：迁移工具，把已装的老 UU 插件换成官方新版，并补 monitor、启动包装和开机脚本。详见 `UPSTREAM.md`。
- `edwardvon/uuplugin-redmi-ax6000`（2023 年从小米 AX6000 抓包的老 UU 插件种子）：作为 coolhpj 迁移的前置条件，插件 ID 与 coolhpj 门禁同为 `2882303761518031252`，含 manifest、start_script（含 xnetease-uu）、installPlugin JSON。详见 `UPSTREAM.md`。

本仓库不包含上述两个项目的文件，也不包含 `uuplugin`、`xuplugin-guardian`、`uu.conf`、`xtables-nft-multi` 等二进制/运行文件，使用者请按 `UPSTREAM.md` 自行获取。

## 完整流程（实测通过，2026-10-26）

1. PN51 本地 WOL 先配好：BIOS ErP Ready Disabled、Power On By PCI-E Enabled；网卡电源管理三项全勾；快速启动关；关机后网口灯亮。本地 etherwake 唤醒先验通（兜底命令见 `docs/硬件与WOL设置.md`）。
2. 路由器上用无自启动方式先跑 edwardvon 种子：只跑 `./auto.sh`，不做 firewall include 自启动。验 `ps` 有 monitor + uuplugin、到 `:16000` 有 ESTABLISHED。
3. 手机 UU 主机加速器里发现路由器并绑定（见第 5 步的坑：不要走全新安装向导）。
4. 路由器上跑 coolhpj：`diagnose` → `preflight` → `stage openwrt-aarch64`（实测版本 v14.10.6）→ `smoke-test` → `install`（迁移）。
5. 手机 UU 主机加速器里删掉旧卡，走“合作款路由器”重新绑定（型号会显示为 OpenWrt，不是 RB06，这是正常的）。
6. PN51 上完成 UU 远程本机配置，手机 UU 远程里进 PN51 的远程开机配置，选 OpenWrt 路由器做辅助设备。
7. PN51 真关机，手机关 WiFi、只用移动数据，点远程开机，PN51 真开机即成功。
8. 重启复验（可选，等方便时做）：路由器重启后插件应由 `/data/uu-v14/auto.sh` 的 firewall include 自动起来，再做一次移动数据唤醒。

## 关键坑（先看，再动手）

- **busybox `ps` 截断**：路由器上 plain `ps` 只显示 `{uuplugin} /userd`，脚本查 `uuplugin ./uu.conf` 永远查不到，会误报 offline，还会让新 monitor 每 60 秒多起一个 uuplugin。补丁见 `patches/`，核心就是把检测里的 `ps` 换成 `ps w`。
- **smoke-test 恢复检测**：老插件起的是绝对路径，新插件起的是 `./uu.conf`，恢复那一步只认 `./uu.conf` 会在 20 秒内判失败，哪怕老插件其实已经回来了。补丁见 `patches/`。
- **sed 的 `&`**：sed 替换串里的 `&` 代表整行原内容，写 `2>&1` 会把原行又插一遍。补丁脚本里已避开 `&`，用 `2>/dev/null` 代替。
- **官方安装向导判 RB06 不支持**：全新“安装路由器插件”向导做型号检测时会说 RB06 暂不支持加速，不要走这条。已经装好插件的情况下走“合作款路由器”绑定，那条不做型号检测。
- **UU 远程里没有单独的辅助设备列表**：辅助设备靠主机加速器绑定的路由器提供，不要在 UU 远程里找一个独立的列表，也不要在 PN51 的向导里找 RB06 列表，PN51 向导只管本机局域网设置和 BIOS。
- **不要重复加卡**：同一台路由器加出 RB06 和 OpenWrt 两张卡会互相干扰，删了重绑时只留 OpenWrt 那张。

## 目录

- `docs/2026-10-26-实测记录.md`：当天的完整时间线和每一步的输出要点
- `docs/硬件与WOL设置.md`：PN51 BIOS/网卡/快速启动、本地 etherwake 兜底
- `docs/迁移步骤.md`：stage → smoke-test → install 的逐条命令和停表条件
- `patches/apply-xiaoqiang-ps-w.sh`：给 coolhpj 本地副本打 `ps w` 补丁和恢复检测补丁的脚本
- `scripts/检查清单.md`：迁移后和唤醒前的检查命令
- `UPSTREAM.md`：上游项目、许可证、署名和获取方式
- `LICENSE`：本仓库自有文档和脚本的许可证（上游项目各自的许可证见 `UPSTREAM.md`）

## 回滚

迁移前会自动备份到 `/data/uu-wol-helper-state/backups/<时间戳>-<PID>/`，回滚命令见 `docs/迁移步骤.md`。回滚后老插件不一定自动起，须手动 `ps w` / `netstat` 验，停了就手动 `./xnetease-uu plugon`。
