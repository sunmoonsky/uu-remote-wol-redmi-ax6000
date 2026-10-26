# 硬件与 WOL 设置

## PN51-E1（被控电脑）

- Ryzen 7 5700U，内存 4GB（瓶颈），256GB SSD，Windows。
- 有线网卡 Realtek PCIe 2.5GbE，MAC 请填你自己的，唤醒写法用冒号分隔，如 `XX:XX:XX:XX:XX:XX`。
- BIOS：ErP Ready Disabled、Power On By PCI-E Enabled；Power On By RTC 不需动，Restore AC Power Loss 保持 Power Off。
- Windows 网卡“电源管理”三项全勾；快速启动关；关机后网口灯亮。
- 未必需要再查：网卡“高级”页 Shutdown Wake-On-Lan / Wake on Magic Packet / Wake on pattern match、WOL & Shutdown Link Speed 10 Mbps，及 `powercfg /devicequery wake_armed`。本地唤醒已成功时优先级低。

## 红米 AX6000 / RB06（辅助设备）

- XiaoQiang 固件，OpenWrt 派生，MT7986，aarch64，512MB 内存。
- 二级路由：WAN 接上级光猫，无公网 IP，外网不能入站直连。
- 本仓库的 UU 插件与 ShellCrash / Mihomo 无关，不要为唤醒换 ShellCrash 内核（换内核代价大，且 /data 空间紧张）。

## 本地 etherwake 兜底（已建成）

- 路由器原先无 etherwake/wol/python3；`opkg update` 因 18.06-SNAPSHOT 源 404 失败（快照源被清理），不要改源为新版 OpenWrt。
- 单包：archive.openwrt.org 18.06.7 的 etherwake，http 下载（busybox wget 不认 https）。
- 首次装因 /overlay 已满失败，改用 `opkg -d ram install` 到 /tmp 绕过，并持久化到 `/data/wol/`。
- 现成命令（MAC 换成你自己的）：

```sh
/data/wol/etherwake -i br-lan XX:XX:XX:XX:XX:XX
```

- 本地唤醒已成功验证：快速启动关、关机后网口灯亮的前提下，跑上面命令可开机。
