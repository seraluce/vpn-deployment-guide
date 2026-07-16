# 日志分析指南

日志分析是VPN故障排除和性能优化的重要手段，本指南介绍如何查看和分析VPN相关日志。

## 日志系统简介

### Linux日志系统

Linux系统使用rsyslog或syslog-ng管理日志，主要日志文件包括：

- `/var/log/syslog`：系统日志
- `/var/log/auth.log`：认证日志
- `/var/log/kern.log`：内核日志
- `/var/log/daemon.log`：服务日志

### VPN日志位置

| 服务 | 日志位置 |
|------|----------|
| WireGuard | `journalctl -u wg-quick@wg0` |
| OpenVPN | `/var/log/openvpn/` |
| Shadowsocks | `journalctl -u shadowsocks-libev` |
| V2Ray | `journalctl -u v2ray` |

## WireGuard日志

### 查看日志

```bash
# 查看WireGuard日志
sudo journalctl -u wg-quick@wg0

# 实时查看日志
sudo journalctl -u wg-quick@wg0 -f

# 查看最近100行日志
sudo journalctl -u wg-quick@wg0 --no-pager -n 100

# 查看特定时间范围日志
sudo journalctl -u wg-quick@wg0 --since "2024-01-01 00:00:00" --until "2024-01-02 00:00:00"
```

### 分析日志

```bash
# 查看连接信息
sudo wg show

# 查看接口状态
sudo ip addr show wg0

# 查看路由表
sudo ip route show | grep wg0
```

### 常见日志信息

```
# 接口启动
[  OK  ] Started WireGuard via wg-quick(8) for wg0.

# 连接建立
peer (public-key) is now connected

# 数据传输
transferred: 1.23 GiB received, 4.56 GiB sent
```

## OpenVPN日志

### 查看日志

```bash
# 查看OpenVPN日志
sudo journalctl -u openvpn@server

# 实时查看日志
sudo journalctl -u openvpn@server -f

# 查看OpenVPN状态日志
sudo cat /var/log/openvpn/openvpn-status.log

# 查看认证日志
sudo cat /var/log/openvpn/openvpn.log
```

### 分析日志

```bash
# 查看连接客户端
sudo cat /var/log/openvpn/openvpn-status.log | grep "ROUTING TABLE"

# 查看IP分配
sudo cat /var/log/openvpn/ipp.txt

# 查看统计信息
sudo cat /var/log/openvpn/openvpn-status.log | grep "GLOBAL STATS"
```

### 常见日志信息

```
# 服务启动
Initialization Sequence Completed

# 客户端连接
client-ip:port: TLS: new client connection from client-ip:port

# 认证成功
client-ip:port: [username] Peer Auth Initiated

# 数据传输
client-ip:port: TLS: soft reset
```

## Shadowsocks日志

### 查看日志

```bash
# 查看Shadowsocks日志
sudo journalctl -u shadowsocks-libev

# 实时查看日志
sudo journalctl -u shadowsocks-libev -f

# 查看最近100行日志
sudo journalctl -u shadowsocks-libev --no-pager -n 100
```

### 分析日志

```bash
# 查看连接信息
sudo ss -antlp | grep 8388

# 查看流量统计
sudo iftop -i eth0 -f "port 8388"
```

### 常见日志信息

```
# 服务启动
INFO: listening on 0.0.0.0:8388

# 客户端连接
INFO: connect to google.com:443 from client-ip:port

# 数据传输
INFO: tcp: relay 1.23 MiB in 0.45s
```

## V2Ray日志

### 查看日志

```bash
# 查看V2Ray日志
sudo journalctl -u v2ray

# 实时查看日志
sudo journalctl -u v2ray -f

# 查看最近100行日志
sudo journalctl -u v2ray --no-pager -n 100
```

### 分析日志

```bash
# 查看连接信息
sudo ss -antlp | grep 443

# 查看配置测试
v2ray -test -config /usr/local/etc/v2ray/config.json
```

### 常见日志信息

```
# 服务启动
V2Ray 1.8.0 started

# 客户端连接
[Tags: default] inbound connection from client-ip:port

# 数据传输
[Tags: default] outbound connection to google.com:443
```

## 日志分析脚本

### 连接统计脚本

```bash
#!/bin/bash

# 统计连接数
count_connections() {
    local port=$1
    local count=$(ss -antlp | grep ":$port" | wc -l)
    echo "Port $port connections: $count"
}

# 统计所有VPN端口
count_connections 51820
count_connections 1194
count_connections 8388
count_connections 443
```

### 流量统计脚本

```bash
#!/bin/bash

# 统计流量
traffic_stats() {
    local port=$1
    echo "Traffic on port $port:"
    sudo iftop -i eth0 -f "port $port" -t -s 10
}

# 统计所有VPN端口
traffic_stats 51820
traffic_stats 1194
traffic_stats 8388
traffic_stats 443
```

### 错误日志分析脚本

```bash
#!/bin/bash

# 分析错误日志
analyze_errors() {
    local service=$1
    echo "=== $service Error Logs ==="
    sudo journalctl -u "$service" --no-pager | grep -i "error\|fail\|denied" | tail -20
}

# 分析所有VPN服务错误
analyze_errors "wg-quick@wg0"
analyze_errors "openvpn@server"
analyze_errors "shadowsocks-libev"
analyze_errors "v2ray"
```

## 性能监控

### 监控脚本

```bash
#!/bin/bash

# 监控VPN性能
monitor_performance() {
    while true; do
        echo "=== VPN Performance Monitor ==="
        echo "Time: $(date)"
        
        # 检查连接数
        echo "Connections:"
        ss -antlp | grep -E ':(51820|1194|8388|443)' | wc -l
        
        # 检查CPU使用
        echo "CPU Usage:"
        top -bn1 | grep "Cpu(s)" | awk '{print $2}'
        
        # 检查内存使用
        echo "Memory Usage:"
        free -m | awk 'NR==2{printf "%.2f%%", $3*100/$2}'
        
        # 检查网络流量
        echo "Network Traffic:"
        vnstat -h 1
        
        sleep 60
    done
}

# 运行监控
monitor_performance
```

### 报警脚本

```bash
#!/bin/bash

# 配置阈值
CPU_THRESHOLD=80
MEMORY_THRESHOLD=85
CONNECTION_THRESHOLD=100

# 检查并报警
check_and_alert() {
    local metric=$1
    local value=$2
    local threshold=$3
    
    if [ $(echo "$value > $threshold" | bc) -eq 1 ]; then
        echo "ALERT: $metric is $value (threshold: $threshold)"
        # 发送邮件或通知
        # send_alert "$metric is $value"
    fi
}

# 主监控循环
while true; do
    # 检查CPU
    CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}')
    check_and_alert "CPU" "$CPU" "$CPU_THRESHOLD"
    
    # 检查内存
    MEMORY=$(free -m | awk 'NR==2{printf "%.2f", $3*100/$2}')
    check_and_alert "Memory" "$MEMORY" "$MEMORY_THRESHOLD"
    
    # 检查连接数
    CONNECTIONS=$(ss -antlp | grep -E ':(51820|1194|8388|443)' | wc -l)
    check_and_alert "Connections" "$CONNECTIONS" "$CONNECTION_THRESHOLD"
    
    sleep 60
done
```

## 日志轮转

### 配置日志轮转

```bash
# 创建日志轮转配置
sudo nano /etc/logrotate.d/vpn

# 添加以下内容
/var/log/vpn/*.log {
    daily
    missingok
    rotate 7
    compress
    delaycompress
    notifempty
    create 0640 root adm
    sharedscripts
    postrotate
        /etc/init.d/rsyslog restart > /dev/null
    endscript
}
```

### 手动轮转日志

```bash
# 手动轮转日志
sudo logrotate -f /etc/logrotate.d/vpn

# 查看轮转状态
cat /var/lib/logrotate/status
```

## 集中日志

### 配置rsyslog

```bash
# 编辑rsyslog配置
sudo nano /etc/rsyslog.conf

# 启用TCP/UDP接收
$ModLoad imtcp
$InputTCPServerRun 514

$ModLoad imudp
$UDPServerRun 514

# 配置远程日志
*.* @@log-server:514
```

### 配置日志服务器

```bash
# 安装rsyslog
sudo apt install rsyslog

# 启动rsyslog
sudo systemctl enable rsyslog
sudo systemctl start rsyslog
```

## 安全日志

### 认证日志

```bash
# 查看认证日志
sudo cat /var/log/auth.log | grep -i "vpn"

# 查看失败的登录尝试
sudo cat /var/log/auth.log | grep -i "failed"
```

### 防火墙日志

```bash
# 查看防火墙日志
sudo tail -f /var/log/ufw.log

# 查看iptables日志
sudo tail -f /var/log/kern.log | grep IPTables
```

## 故障排除

### 常见日志问题

1. **日志为空**
   ```bash
   # 检查服务状态
   sudo systemctl status wg-quick@wg0
   
   # 检查日志权限
   ls -la /var/log/
   ```

2. **日志过多**
   ```bash
   # 配置日志轮转
   sudo logrotate -f /etc/logrotate.d/vpn
   
   # 清理旧日志
   sudo find /var/log -name "*.log.*" -mtime +30 -delete
   ```

3. **日志格式混乱**
   ```bash
   # 配置日志格式
   sudo nano /etc/rsyslog.conf
   
   # 添加格式配置
   $template precise,"%syslogtag%,%msg%\n"
   ```

### 日志分析工具

```bash
# 安装日志分析工具
sudo apt install logwatch
sudo apt install goaccess

# 使用logwatch
sudo logwatch --output stdout --range today

# 使用goaccess
goaccess /var/log/nginx/access.log -o report.html
```

## 最佳实践

1. **启用日志记录**：记录所有重要事件
2. **配置日志轮转**：避免日志文件过大
3. **集中日志管理**：使用rsyslog或ELK
4. **定期分析日志**：及时发现异常
5. **保护日志安全**：设置适当权限
6. **备份重要日志**：定期备份关键日志
7. **使用日志工具**：提高分析效率
8. **文档化日志**：记录日志分析方法