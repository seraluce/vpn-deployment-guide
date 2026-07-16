# 常见问题解答

本指南收集了VPN部署和使用过程中最常见的问题及其解决方案。

## 连接问题

### 无法连接到VPN服务器

#### 问题描述
客户端无法建立VPN连接，超时或拒绝连接。

#### 可能原因
1. 防火墙未开放端口
2. 服务器未运行
3. 网络配置错误
4. 客户端配置错误

#### 解决方案

**检查防火墙配置**
```bash
# 检查端口是否监听
sudo netstat -tulpn | grep :51820

# 检查防火墙规则
sudo ufw status

# 测试端口连通性
telnet your-server-ip 51820
```

**检查服务状态**
```bash
# 检查WireGuard状态
sudo systemctl status wg-quick@wg0

# 检查OpenVPN状态
sudo systemctl status openvpn@server

# 查看服务日志
sudo journalctl -u wg-quick@wg0 -f
```

**检查网络配置**
```bash
# 检查IP转发
cat /proc/sys/net/ipv4/ip_forward

# 检查路由表
ip route show

# 测试网络连通性
ping your-server-ip
```

### 连接后无法上网

#### 问题描述
VPN连接成功，但无法访问互联网。

#### 可能原因
1. IP转发未启用
2. 路由配置错误
3. DNS配置问题
4. NAT配置错误

#### 解决方案

**启用IP转发**
```bash
# 临时启用
sudo sysctl -w net.ipv4.ip_forward=1

# 永久启用
echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

**检查路由配置**
```bash
# 查看路由表
ip route show

# 添加默认路由
sudo ip route add default via 10.0.0.1 dev wg0
```

**检查NAT配置**
```bash
# 查看NAT规则
sudo iptables -t nat -L

# 添加NAT规则
sudo iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -o eth0 -j MASQUERADE
```

### 连接速度慢

#### 问题描述
VPN连接速度明显慢于直接连接。

#### 可能原因
1. 服务器带宽不足
2. 网络延迟高
3. 加密算法性能差
4. MTU值设置不当

#### 解决方案

**优化服务器配置**
```bash
# 检查服务器带宽
speedtest-cli

# 检查服务器负载
top

# 检查网络延迟
ping -c 10 8.8.8.8
```

**优化VPN配置**
```bash
# 调整MTU值
sudo ip link set mtu 1420 dev wg0

# 使用性能更好的加密算法
# WireGuard: 默认使用ChaCha20
# OpenVPN: 使用AES-256-GCM
```

**选择合适服务器**
```bash
# 测试不同服务器速度
speedtest-cli --server server-id

# 选择延迟最低的服务器
```

## 配置问题

### 证书错误

#### 问题描述
TLS证书验证失败，连接被拒绝。

#### 可能原因
1. 证书过期
2. 证书链不完整
3. 证书与域名不匹配
4. 自签名证书未信任

#### 解决方案

**检查证书状态**
```bash
# 查看证书有效期
openssl x509 -in server.crt -noout -enddate

# 验证证书链
openssl verify -CAfile ca.crt server.crt

# 检查证书域名
openssl x509 -in server.crt -noout -text | grep -A1 "Subject Alternative Name"
```

**更新证书**
```bash
# 更新Let's Encrypt证书
sudo certbot renew

# 重启服务
sudo systemctl restart nginx
sudo systemctl restart v2ray
```

### 配置文件错误

#### 问题描述
配置文件语法错误，服务无法启动。

#### 可能原因
1. JSON格式错误
2. 配置项缺失
3. 参数值错误
4. 编码问题

#### 解决方案

**验证配置文件**
```bash
# 验证JSON格式
python -m json.tool config.json

# 验证YAML格式
python -c "import yaml; yaml.safe_load(open('config.yaml'))"

# 测试配置
v2ray -test -config config.json
```

**修复配置文件**
```bash
# 查看错误日志
sudo journalctl -u v2ray -f

# 使用在线工具验证
# JSON: https://jsonlint.com/
# YAML: https://yamlformatter.currying.com/
```

### 订阅链接问题

#### 问题描述
订阅链接无法访问或配置无法导入。

#### 可能原因
1. 订阅链接无效
2. 服务器未运行
3. 网络连接问题
4. 客户端不支持

#### 解决方案

**测试订阅链接**
```bash
# 测试链接
curl -v "http://your-server-ip:8080/subscribe/user1"

# 检查响应
curl "http://your-server-ip:8080/subscribe/user1" | head -20
```

**检查服务器状态**
```bash
# 检查订阅服务器
systemctl status subscription-server

# 查看日志
tail -f /var/log/subscription.log
```

## 性能问题

### 高延迟

#### 问题描述
VPN连接延迟高，响应慢。

#### 可能原因
1. 服务器地理位置远
2. 网络拥塞
3. 服务器性能差
4. 加密开销大

#### 解决方案

**优化网络**
```bash
# 测试网络延迟
ping -c 10 your-server-ip

# 使用更快的DNS
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf

# 启用TCP Fast Open
sudo sysctl -w net.ipv4.tcp_fastopen=3
```

**优化服务器**
```bash
# 检查服务器性能
top
htop

# 升级服务器配置
# 增加CPU、内存、带宽
```

### 高CPU使用率

#### 问题描述
VPN服务占用CPU过高。

#### 可能原因
1. 加密算法性能差
2. 连接数过多
3. 服务器配置低
4. 系统资源不足

#### 解决方案

**优化加密算法**
```bash
# 使用性能更好的算法
# WireGuard: 默认使用ChaCha20
# OpenVPN: 使用AES-256-GCM
# V2Ray: 使用AES-128-GCM
```

**限制连接数**
```bash
# WireGuard
sudo wg set wg0 peer <peer-public-key> allowed-ips 10.0.0.2/32

# OpenVPN
max-clients 10
```

### 高内存使用率

#### 问题描述
VPN服务占用内存过高。

#### 可能原因
1. 连接数过多
2. 缓冲区设置不当
3. 内存泄漏
4. 系统资源不足

#### 解决方案

**优化内存使用**
```bash
# 调整缓冲区大小
sudo sysctl -w net.core.rmem_max=16777216
sudo sysctl -w net.core.wmem_max=16777216

# 限制连接数
# 根据服务器内存调整最大连接数
```

**监控内存使用**
```bash
# 查看内存使用
free -m

# 查看进程内存
ps aux --sort=-%mem | head -10
```

## 安全问题

### DDoS攻击

#### 问题描述
服务器遭受DDDoS攻击，服务不可用。

#### 可能原因
1. 端口暴露在公网
2. 缺乏防护措施
3. 未启用速率限制
4. 未配置防火墙

#### 解决方案

**启用防护**
```bash
# 限制连接速率
sudo iptables -A INPUT -p tcp --dport 51820 -m limit --limit 10/minute --limit-burst 20 -j ACCEPT

# 封禁异常IP
sudo fail2ban-client set sshd banip 192.168.1.100
```

**使用CDN**
```bash
# 配置Cloudflare CDN
# 使用WAF防护
```

### 未授权访问

#### 问题描述
未经授权的用户连接到VPN服务。

#### 可能原因
1. 密码弱或泄露
2. 证书未验证
3. 访问控制不当
4. 配置文件权限错误

#### 解决方案

**加强认证**
```bash
# 使用强密码
openssl rand -base64 32

# 启用证书验证
# OpenVPN: require-cert
# V2Ray: 使用UUID

# 限制访问IP
sudo ufw allow from 192.168.1.0/24
```

**检查配置权限**
```bash
# 检查文件权限
ls -la /etc/wireguard/
ls -la /etc/openvpn/

# 修复权限
sudo chmod 600 /etc/wireguard/server_private.key
```

### 日志泄露

#### 问题描述
敏感信息泄露到日志文件。

#### 可能原因
1. 日志级别过高
2. 记录敏感信息
3. 日志未加密
4. 日志权限不当

#### 解决方案

**调整日志级别**
```bash
# V2Ray
"loglevel": "warning"

# OpenVPN
verb 3

# Shadowsocks
"timeout": 300
```

**保护日志文件**
```bash
# 设置日志权限
sudo chmod 640 /var/log/vpn.log

# 加密日志
sudo apt install logrotate
```

## 故障排除工具

### 网络诊断

```bash
# 检查网络连接
ping -c 4 your-server-ip

# 检查路由
traceroute your-server-ip

# 检查DNS
nslookup your-domain.com

# 检查端口
nmap -sU -p 51820 your-server-ip
```

### 服务诊断

```bash
# 检查服务状态
systemctl status wg-quick@wg0
systemctl status openvpn@server
systemctl status shadowsocks-libev
systemctl status v2ray

# 查看日志
journalctl -u wg-quick@wg0 -f
journalctl -u openvpn@server -f
```

### 性能诊断

```bash
# 检查CPU使用
top
htop

# 检查内存使用
free -m

# 检查磁盘使用
df -h

# 检查网络流量
iftop -i eth0
```

## 联系支持

如果以上解决方案都无法解决问题，请提供以下信息：

1. **系统信息**
   ```bash
   uname -a
   lsb_release -a
   ```

2. **服务状态**
   ```bash
   systemctl status wg-quick@wg0
   systemctl status openvpn@server
   ```

3. **错误日志**
   ```bash
   journalctl -u wg-quick@wg0 -n 100
   journalctl -u openvpn@server -n 100
   ```

4. **网络配置**
   ```bash
   ip addr show
   ip route show
   ```

将以上信息提交到GitHub Issue，我们会尽快帮助您解决问题。