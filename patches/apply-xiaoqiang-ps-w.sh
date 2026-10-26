#!/bin/sh
# 给 coolhpj 本地副本打 XiaoQiang busybox 适配补丁。
# 只在 /tmp/uu-remote-wol-router-helper-main 里跑，不要改上游仓库。
# 原理：路由器 plain ps 截断进程名，只显示 {uuplugin} /userd，
# 脚本查 uuplugin ./uu.conf 永远查不到；ps w 显示完整命令行。
# 注意：sed 替换串里的 & 会展开原行，本脚本刻意避开 &，
# 用 2>/dev/null 代替 2>&1，分隔符用 | 或 #，不要用 /（会和 /dev/null 撞）。

set -e
cd /tmp/uu-remote-wol-router-helper-main

# 1. ps -> ps w（8 处，逻辑一行不改）
sed -i 's|ps 2>/dev/null|ps w 2>/dev/null|g' \
  platforms/xiaoqiang/smoke-test.sh \
  platforms/xiaoqiang/health.sh \
  platforms/xiaoqiang/persist-common.sh \
  platforms/xiaoqiang/runtime/uuplugin_monitor.sh

sed -i 's/ps | grep/ps w | grep/g' \
  platforms/xiaoqiang/runtime/uuplugin_monitor.sh

# 2. smoke-test 的 is_uu_running：同时认 ./uu.conf 和绝对路径 uu.conf
# 先确认行号（实测为 90 行，is_uu_running 函数体）
sed -n '89,92p' platforms/xiaoqiang/smoke-test.sh

# 用 # 做分隔符、且替换串里不含 &，整行重写
sed -i '90s#.*#    ps w 2>/dev/null | grep "[u]uplugin" | grep "uu.conf" >/dev/null 2>/dev/null#' \
  platforms/xiaoqiang/smoke-test.sh

echo "--- verify ps w ---"
grep -n "ps w" platforms/xiaoqiang/smoke-test.sh \
  platforms/xiaoqiang/health.sh \
  platforms/xiaoqiang/persist-common.sh \
  platforms/xiaoqiang/runtime/uuplugin_monitor.sh

echo "--- verify is_uu_running ---"
sed -n '89,92p' platforms/xiaoqiang/smoke-test.sh
