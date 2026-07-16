# 防火墙配置指南

防火墙是保护VPN服务器安全的重要组件，正确配置可以有效防止未授权访问。

## 防火墙简介

### 什么是防火墙

防火墙是一种网络安全系统，监控和控制进出网络的流量。它可以基于预定义的安全规则允许或阻止数据包。

### 防火墙类型

| 类型 | 说明 | 适用场景 |
|------|------|----------|
| 包过滤防火墙 | 基于数据包头部信息过滤 | 基本防护 |
| 状态检测防火墙 | 跟踪连接状态 | 企业环境 |
| 应用层防火墙 | 深度检查应用层数据 | 高安全需求 |
| 下一代防火墙 | 综合多种功能 | 现代网络环境 |

## Linux防火墙工具

### iptables

iptables是Linux内核的防火墙工具，功能强大但配置复杂。

#### 基本命令

```bash
# 查看规则
sudo iptables -L

# 查看详细规则
sudo iptables -L -n -v

# 添加规则
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# 删除规则
sudo iptables -D INPUT -p tcp --dport 22 -j ACCEPT

# 清空规则
sudo iptables -F
```

#### VPN端口配置

```bash
# 允许SSH
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# 允许WireGuard
sudo iptables -A INPUT -p udp --dport 51820 -j ACCEPT

# 允许OpenVPN
sudo iptables -A INPUT -p udp --dport 1194 -j ACCEPT

# 允许Shadowsocks
sudo iptables -A INPUT -p tcp --dport 8388 -j ACCEPT
sudo iptables -A INPUT -p udp --dport 8388 -j ACCEPT

# 允许V2Ray
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# 允许HTTP/HTTPS
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# 允许已建立的连接
sudo iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# 拒绝其他所有入站连接
sudo iptables -A INPUT -j DROP
```

#### NAT配置

```bash
# 启用IP转发
sudo sysctl -w net.ipv4.ip_forward=1

# 配置NAT
sudo iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -o eth0 -j MASQUERADE

# 允许转发
sudo iptables -A FORWARD -i wg0 -j ACCEPT
sudo iptables -A FORWARD -o wg0 -j ACCEPT
```

#### 保存规则

```bash
# Ubuntu/Debian
sudo iptables-save > /etc/iptables/rules.v4

# CentOS/RHEL
sudo service iptables save
```

### firewalld

firewalld是CentOS/RHEL的默认防火墙管理工具。

#### 基本命令

```bash
# 查看状态
sudo firewall-cmd --state

# 查看区域
sudo firewall-cmd --get-zones

# 查看默认区域
sudo firewall-cmd --get-default-zone

# 查看规则
sudo firewall-cmd --list-all
```

#### VPN端口配置

```bash
# 允许SSH
sudo firewall-cmd --permanent --add-service=ssh

# 允许WireGuard
sudo firewall-cmd --permanent --add-port=51820/udp

# 允许OpenVPN
sudo firewall-cmd --permanent --add-port=1194/udp

# 允许Shadowsocks
sudo firewall-cmd --permanent --add-port=8388/tcp
sudo firewall-cmd --permanent --add-port=8388/udp

# 允许V2Ray
sudo firewall-cmd --permanent --add-port=443/tcp

# 允许HTTP/HTTPS
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https

# 重新加载
sudo firewall-cmd --reload
```

#### NAT配置

```bash
# 启用IP转发
sudo sysctl -w net.ipv4.ip_forward=1

# 配置NAT
sudo firewall-cmd --permanent --add-masquerade

# 重新加载
sudo firewall-cmd --reload
```

### ufw

ufw是Ubuntu的简化防火墙管理工具。

#### 基本命令

```bash
# 查看状态
sudo ufw status

# 启用防火墙
sudo ufw enable

# 禁用防火墙
sudo ufw disable

# 重置规则
sudo ufw reset
```

#### VPN端口配置

```bash
# 允许SSH
sudo ufw allow 22/tcp

# 允许WireGuard
sudo ufw allow 51820/udp

# 允许OpenVPN
sudo ufw allow 1194/udp

# 允许Shadowsocks
sudo ufw allow 8388/tcp
sudo ufw allow 8388/udp

# 允许V2Ray
sudo ufw allow 443/tcp

# 允许HTTP/HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# 允许来自特定IP
sudo ufw allow from 192.168.1.0/24

# 允许来自特定IP到特定端口
sudo ufw allow from 192.168.1.0/24 to any port 22
```

#### 高级配置

```bash
# 设置默认策略
sudo ufw default deny incoming
sudo ufw default allow outgoing

# 删除规则
sudo ufw delete allow 80/tcp

# 查看详细规则
sudo ufw status verbose
```

## VPN服务端防火墙配置

### WireGuard防火墙配置

```bash
# Ubuntu/Debian (ufw)
sudo ufw allow 51820/udp
sudo ufw allow from 10.0.0.0/24

# CentOS/RHEL (firewalld)
sudo firewall-cmd --permanent --add-port=51820/udp
sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="10.0.0.0/24" accept'
sudo firewall-cmd --reload

# iptables
sudo iptables -A INPUT -p udp --dport 51820 -j ACCEPT
sudo iptables -A INPUT -i wg0 -j ACCEPT
```

### OpenVPN防火墙配置

```bash
# Ubuntu/Debian (ufw)
sudo ufw allow 1194/udp
sudo ufw allow from 10.8.0.0/24

# CentOS/RHEL (firewalld)
sudo firewall-cmd --permanent --add-port=1194/udp
sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="10.8.0.0/24" accept'
sudo firewall-cmd --reload

# iptables
sudo iptables -A INPUT -p udp --dport 1194 -j ACCEPT
sudo iptables -A INPUT -i tun0 -j ACCEPT
```

### Shadowsocks防火墙配置

```bash
# Ubuntu/Debian (ufw)
sudo ufw allow 8388/tcp
sudo ufw allow 8388/udp

# CentOS/RHEL (firewalld)
sudo firewall-cmd --permanent --add-port=8388/tcp
sudo firewall-cmd --permanent --add-port=8388/udp
sudo firewall-cmd --reload

# iptables
sudo iptables -A INPUT -p tcp --dport 8388 -j ACCEPT
sudo iptables -A INPUT -p udp --dport 8388 -j ACCEPT
```

### V2Ray防火墙配置

```bash
# Ubuntu/Debian (ufw)
sudo ufw allow 443/tcp

# CentOS/RHEL (firewalld)
sudo firewall-cmd --permanent --add-port=443/tcp
sudo firewall-cmd --reload

# iptables
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT
```

## 高级防火墙配置

### 速率限制

```bash
# iptables速率限制
sudo iptables -A INPUT -p tcp --dport 8388 -m limit --limit 10/minute --limit-burst 20 -j ACCEPT

# ufw速率限制
sudo ufw limit 8388/tcp
```

### 连接跟踪

```bash
# iptables连接跟踪
sudo iptables -A INPUT -m state --state INVALID -j DROP
sudo iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
```

### 端口扫描防护

```bash
# 检测端口扫描
sudo iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
sudo iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP
sudo iptables -A INPUT -p tcp --tcp-flags ALL FIN,URG,PSH -j DROP
sudo iptables -A INPUT -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j DROP
```

### DDoS防护

```bash
# SYN洪泛防护
sudo iptables -A INPUT -p tcp --syn -m limit --limit 1/s --limit-burst 3 -j ACCEPT

# ICMP洪泛防护
sudo iptables -A INPUT -p icmp --icmp-type echo-request -m limit --limit 1/s --limit-burst 4 -j ACCEPT

# UDP洪泛防护
sudo iptables -A INPUT -p udp -m limit --limit 10/s --limit-burst 20 -j ACCEPT
```

## 日志和监控

### 启用日志

```bash
# iptables日志
sudo iptables -A INPUT -j LOG --log-prefix "IPTables-Dropped: " --log-level 4

# ufw日志
sudo ufw logging on

# firewalld日志
sudo firewall-cmd --set-log-denied=all
```

### 查看日志

```bash
# 查看iptables日志
sudo tail -f /var/log/kern.log | grep IPTables-Dropped

# 查看ufw日志
sudo tail -f /var/log/ufw.log

# 查看firewalld日志
sudo journalctl -u firewalld -f
```

### 监控连接

```bash
# 查看所有连接
sudo netstat -antlp

# 查看特定端口连接
sudo netstat -antlp | grep :51820

# 查看连接状态
sudo conntrack -L
```

## 故障排除

### 常见问题

1. **无法连接VPN**
   ```bash
   # 检查防火墙规则
   sudo iptables -L -n
   
   # 检查端口监听
   sudo netstat -tulpn | grep :51820
   
   # 测试端口连通性
   telnet your-server-ip 51820
   ```

2. **连接后无法上网**
   ```bash
   # 检查IP转发
   cat /proc/sys/net/ipv4/ip_forward
   
   # 检查NAT规则
   sudo iptables -t nat -L
   
   # 检查路由表
   ip route show
   ```

3. **防火墙规则不生效**
   ```bash
   # 检查规则顺序
   sudo iptables -L -n --line-numbers
   
   # 检查默认策略
   sudo iptables -L INPUT -n
   ```

### 调试技巧

1. **临时禁用防火墙**
   ```bash
   # iptables
   sudo iptables -F
   
   # ufw
   sudo ufw disable
   
   # firewalld
   sudo systemctl stop firewalld
   ```

2. **使用tcpdump抓包**
   ```bash
   # 抓取特定端口
   sudo tcpdump -i any port 51820
   
   # 抓取特定IP
   sudo tcpdump -i any host your-client-ip
   ```

3. **使用nmap扫描**
   ```bash
   # 扫描端口
   nmap -sU -p 51820 your-server-ip
   
   # 扫描所有端口
   nmap -sS -p- your-server-ip
   ```

## 最佳实践

1. **最小权限原则**：只开放必要端口
2. **定期审查规则**：定期检查防火墙规则
3. **启用日志记录**：记录所有拒绝的连接
4. **使用白名单**：只允许信任的IP
5. **定期更新系统**：保持系统和防火墙更新
6. **备份规则**：定期备份防火墙规则
7. **测试配置**：修改配置后测试连接
8. **监控异常**：监控异常连接和攻击