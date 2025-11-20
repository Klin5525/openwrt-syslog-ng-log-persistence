# openwrt-syslog-ng-log-persistence

本项目修改了 **syslog-ng**，在 **不禁用 logd 的情况下** 实现 OpenWrt 的 **日志持久化**。

---

## 背景

1. 根据 [官方 OpenWrt 指南](https://openwrt.org/docs/guide-user/perf_and_log/log.syslog-ng3)，`logread` 是用于读取日志消息的接口。  
   - 当安装 `syslog-ng` 时，**logd 通常需要被禁用**，因为 `/proc/kmsg` 只允许一个进程访问。  
   - ubox 包中默认的 OpenWrt `logread` 命令会被 `/usr/sbin/logread` 脚本覆盖，该脚本读取的是 `/var/log/messages` 而非环形缓冲区。

2. 改变 `logread` 的工作方式可能带来隐藏问题：  
   - 例如，`logd` 提供 **ubus 接口**，供 LuCI、脚本或其他服务读取日志。  
   - **syslog-ng 不提供 ubus 服务**，如果禁用 logd，可能导致 LuCI 或其他工具无法正常显示日志。  

---

## 修改内容

为在保留 `logd` 的前提下实现日志持久化，做了如下修改：

1. **新增脚本**：
   - `./files/inject-kernel-daemon.sh`  
   - `./files/inject-kernel-to-log.sh`  

   这两个脚本 **每 10 秒将新的 dmesg 输出追加到 `/var/log/kernel.log`**。

2. **syslog-ng 配置**：
   - 修改了 `syslog-ng.conf`，调整内核日志的收集方式，确保日志写入 `/var/log/kernel.log`。

3. **Makefile 修改**：
   - 删除 `ALTERNATIVES:=300:/sbin/logread:/usr/libexec/logread.sh`  
     防止 **syslog-ng 的 logread 脚本覆盖原生 OpenWrt `logread`**，从而保留基于 ubus 的日志接口。

4. **源码下载问题**：
   - 依赖包 ivykis 在官方 Makefile 中的源码下载 URL 有问题，因此使用了替代源。

---

## 总结

该方案允许在 **保留 logd 服务的情况下** 使用 syslog-ng 实现 **日志持久化**，确保 LuCI 和其他依赖 ubus 日志接口的系统服务正常工作。
