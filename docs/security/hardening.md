# 安全加固指南

安全加固是保护VPN服务器免受攻击的重要措施，包括系统加固、服务加固和网络安全加固。

## 系统加固

### 更新系统

```bash
# Ubuntu/Debian
sudo apt update && sudo apt upgrade -y

# CentOS/RHEL
sudo yum update -y
```

### 用户管理

#### 禁用root登录

```bash
# 编辑SSH配置
sudo nano /etc/ssh/sshd_config

# 修改以下配置
PermitRootLogin no

# 重启SSH服务
sudo systemctl restart sshd
```

#### 创建普通用户

```bash
# 创建用户
sudo useradd -m -s /bin/bash vpnuser

# 设置密码
sudo passwd vpnuser

# 添加sudo权限
sudo usermod -aG sudo vpnuser
```

#### 密码策略

```bash
# 安装密码策略工具
sudo apt install libpam-pwquality

# 配置密码策略
sudo nano /etc/security/pwquality.conf

# 添加以下配置
minlen = 12
dcredit = -1
ucredit = -1
lcredit = -1
ocredit = -1
```

### 文件权限

#### 关键文件权限

```bash
# 设置关键文件权限
sudo chmod 600 /etc/shadow
sudo chmod 644 /etc/passwd
sudo chmod 600 /etc/ssh/sshd_config
sudo chmod 700 /root
```

#### VPN配置文件权限

```bash
# WireGuard
sudo chmod 600 /etc/wireguard/server_private.key
sudo chmod 644 /etc/wireguard/wg0.conf

# OpenVPN
sudo chmod 600 /etc/openvpn/server.key
sudo chmod 644 /etc/openvpn/server.crt

# V2Ray
sudo chmod 600 /usr/local/etc/v2ray/config.json
```

## SSH加固

### 修改SSH端口

```bash
# 编辑SSH配置
sudo nano /etc/ssh/sshd_config

# 修改端口
Port 2222

# 重启SSH服务
sudo systemctl restart sshd
```

### 禁用密码登录

```bash
# 编辑SSH配置
sudo nano /etc/ssh/sshd_config

# 禁用密码登录
PasswordAuthentication no

# 启用密钥登录
PubkeyAuthentication yes

# 重启SSH服务
sudo systemctl restart sshd
```

### 生成SSH密钥

```bash
# 生成RSA密钥
ssh-keygen -t rsa -b 4096

# 生成ED25519密钥
ssh-keygen -t ed25519

# 复制公钥到服务器
ssh-copy-id -i ~/.ssh/id_ed25519.pub user@server
```

### SSH配置示例

```bash
# /etc/ssh/sshd_config
Port 2222
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
MaxAuthTries 3
ClientAliveInterval 300
ClientAliveCountMax 2
AllowUsers vpnuser
Protocol 2
```

## 服务加固

### 限制服务运行用户

```bash
# 创建专用用户
sudo useradd -r -s /bin/false vpn-service

# 修改服务配置
sudo systemctl edit openvpn@server

# 添加以下内容
[Service]
User=vpn-service
Group=vpn-service
```

### 禁用不必要的服务

```bash
# 查看运行服务
systemctl list-units --type=service --state=running

# 禁用不必要的服务
sudo systemctl disable cups
sudo systemctl disable avahi-daemon
sudo systemctl disable bluetooth
```

### 服务监控

```bash
# 安装监控工具
sudo apt install fail2ban

# 配置fail2ban
sudo nano /etc/fail2ban/jail.local

# 添加以下配置
[sshd]
enabled = true
port = 2222
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
```

## VPN服务加固

### WireGuard加固

```bash
# 限制连接数
sudo wg set wg0 peer <peer-public-key> allowed-ips 10.0.0.2/32

# 定期更换密钥
wg genkey | tee new-private.key | wg pubkey > new-public.key

# 更新配置
sudo nano /etc/wireguard/wg0.conf
```

### OpenVPN加固

```ini
# /etc/openvpn/server.conf
# 使用强加密
cipher AES-256-GCM
data-ciphers AES-256-GCM:AES-128-GCM:CHACHA20-POLY1305

# 启用TLS认证
tls-auth ta.key 0

# 限制客户端
max-clients 10

# 启用压缩
compress lz4-v2

# 日志级别
verb 3

# 禁用用户名/密码认证
# require-cert
```

### Shadowsocks加固

```json
{
    "server": "0.0.0.0",
    "server_port": 8388,
    "password": "strong-password-here",
    "timeout": 300,
    "method": "aes-256-gcm",
    "fast_open": true,
    "mode": "tcp_and_udp",
    "no_delay": true
}
```

### V2Ray加固

```json
{
    "log": {
        "loglevel": "warning"
    },
    "inbounds": [
        {
            "listen": "127.0.0.1",
            "port": 1080,
            "protocol": "socks"
        }
    ],
    "outbounds": [
        {
            "protocol": "vmess",
            "settings": {
                "vnext": [
                    {
                        "address": "your-server-ip",
                        "port": 443,
                        "users": [
                            {
                                "id": "your-uuid",
                                "alterId": 0
                            }
                        ]
                    }
                ]
            }
        }
    ]
}
```

## 网络安全加固

### 防火墙配置

```bash
# 只允许必要端口
sudo ufw allow 2222/tcp
sudo ufw allow 51820/udp
sudo ufw allow 1194/udp
sudo ufw allow 8388/tcp
sudo ufw allow 443/tcp

# 启用防火墙
sudo ufw enable
```

### 网络隔离

```bash
# 创建VPN专用网络
sudo ip netns add vpn-net

# 将VPN接口移动到专用网络
sudo ip link set wg0 netns vpn-net

# 配置网络
sudo ip netns exec vpn-net ip addr add 10.0.0.1/24 dev wg0
sudo ip netns exec vpn-net ip link set wg0 up
```

### 流量控制

```bash
# 安装流量控制工具
sudo apt install tc

# 限制带宽
sudo tc qdisc add dev eth0 root handle 1: htb default 11
sudo tc class add dev eth0 parent 1: classid 1:1 htb rate 100mbit
sudo tc class add dev eth0 parent 1:1 classid 1:11 htb rate 10mbit
```

## 日志和监控

### 集中日志

```bash
# 安装rsyslog
sudo apt install rsyslog

# 配置远程日志
sudo nano /etc/rsyslog.conf

# 添加以下内容
*.* @@log-server:514
```

### 日志分析

```bash
# 安装日志分析工具
sudo apt install logwatch

# 运行日志分析
sudo logwatch --output stdout --range today
```

### 监控脚本

```bash
#!/bin/bash

# 监控VPN服务
while true; do
    # 检查WireGuard状态
    if ! sudo wg show | grep -q "interface"; then
        echo "WireGuard is down"
        sudo systemctl restart wg-quick@wg0
    fi
    
    # 检查OpenVPN状态
    if ! systemctl is-active --quiet openvpn@server; then
        echo "OpenVPN is down"
        sudo systemctl restart openvpn@server
    fi
    
    # 检查连接数
    CONNS=$(ss -antlp | grep -E ':(51820|1194|8388|443)' | wc -l)
    echo "Active connections: $CONNS"
    
    # 检查系统资源
    CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}')
    MEM=$(free -m | awk 'NR==2{printf "%.2f%%", $3*100/$2}')
    echo "CPU: $CPU%, Memory: $MEM%"
    
    sleep 60
done
```

## 安全检查清单

### 系统安全

- [ ] 系统已更新到最新版本
- [ ] root登录已禁用
- [ ] SSH密钥认证已启用
- [ ] 密码策略已配置
- [ ] 文件权限已设置
- [ ] 不必要的服务已禁用

### VPN安全

- [ ] VPN配置文件权限正确
- [ ] 使用强加密算法
- [ ] 证书已正确配置
- [ ] 防火墙规则正确
- [ ] 连接数限制已设置
- [ ] 日志记录已启用

### 网络安全

- [ ] 只开放必要端口
- [ ] 网络隔离已配置
- [ ] 流量控制已设置
- [ ] DDoS防护已启用
- [ ] 入侵检测已配置

### 监控安全

- [ ] 日志集中收集
- [ ] 监控告警已配置
- [ ] 定期安全检查已安排
- [ ] 备份策略已制定

## 应急响应

### 检测入侵

```bash
# 检查异常进程
ps aux | grep -v "^root" | awk '{print $11}' | sort | uniq -c | sort -rn

# 检查异常连接
netstat -antlp | grep -v "127.0.0.1" | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -rn

# 检查异常日志
grep -i "failed\|error\|denied" /var/log/auth.log
```

### 阻止攻击

```bash
# 封禁IP
sudo fail2ban-client set sshd banip 192.168.1.100

# 阻止连接
sudo iptables -A INPUT -s 192.168.1.100 -j DROP
```

### 恢复服务

```bash
# 重启VPN服务
sudo systemctl restart wg-quick@wg0
sudo systemctl restart openvpn@server
sudo systemctl restart shadowsocks-libev
sudo systemctl restart v2ray
```

## 定期维护

### 安全更新

```bash
# 自动更新
sudo apt install unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades
```

### 密钥轮换

```bash
#!/bin/bash

# 轮换WireGuard密钥
generate_new_keys() {
    wg genkey | tee new-private.key | wg pubkey > new-public.key
    echo "New keys generated"
    echo "Update your configuration and restart WireGuard"
}

# 每月轮换密钥
generate_new_keys
```

### 证书更新

```bash
# 更新Let's Encrypt证书
sudo certbot renew

# 重启服务
sudo systemctl restart nginx
sudo systemctl restart v2ray
```

## 最佳实践

1. **最小权限原则**：只授予必要的权限
2. **深度防御**：多层安全防护
3. **定期更新**：保持系统和软件更新
4. **监控日志**：及时发现异常
5. **备份数据**：定期备份配置和数据
6. **安全培训**：提高安全意识
7. **应急响应**：制定应急响应计划
8. **定期审计**：定期进行安全审计