# 手动安装指南

手动安装可以完全控制VPN服务的配置和部署，适合需要定制化需求的用户。

## 系统准备

### 更新系统

```bash
# Ubuntu/Debian
sudo apt update && sudo apt upgrade -y

# CentOS/RHEL
sudo yum update -y
```

### 安装基础工具

```bash
# Ubuntu/Debian
sudo apt install -y curl wget git vim net-tools iproute2

# CentOS/RHEL
sudo yum install -y curl wget git vim net-tools iproute
```

## WireGuard 手动安装

### Ubuntu/Debian

1. **安装WireGuard**

```bash
sudo apt install wireguard wireguard-tools -y
```

2. **生成密钥**

```bash
# 生成服务端私钥
wg genkey | sudo tee /etc/wireguard/server_private.key | wg pubkey | sudo tee /etc/wireguard/server_public.key

# 设置权限
sudo chmod 600 /etc/wireguard/server_private.key
```

3. **创建配置文件**

```bash
sudo nano /etc/wireguard/wg0.conf
```

配置内容：

```ini
[Interface]
PrivateKey = <server-private-key>
Address = 10.0.0.1/24
ListenPort = 51820
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

[Peer]
PublicKey = <client-public-key>
AllowedIPs = 10.0.0.2/32
```

4. **启用IP转发**

```bash
# 临时启用
sudo sysctl -w net.ipv4.ip_forward=1

# 永久启用
echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

5. **启动WireGuard**

```bash
sudo systemctl enable wg-quick@wg0
sudo systemctl start wg-quick@wg0
```

### CentOS/RHEL

1. **安装WireGuard**

```bash
sudo yum install epel-release -y
sudo yum install wireguard-tools -y
```

2. **生成密钥和配置**

```bash
# 生成密钥
wg genkey | sudo tee /etc/wireguard/server_private.key | wg pubkey | sudo tee /etc/wireguard/server_public.key

# 创建配置文件
sudo nano /etc/wireguard/wg0.conf
```

3. **启动服务**

```bash
sudo systemctl enable wg-quick@wg0
sudo systemctl start wg-quick@wg0
```

## OpenVPN 手动安装

### Ubuntu/Debian

1. **安装OpenVPN和Easy-RSA**

```bash
sudo apt install openvpn easy-rsa -y
```

2. **设置PKI**

```bash
# 创建证书目录
make-cadir ~/openvpn-ca
cd ~/openvpn-ca

# 初始化PKI
./easyrsa init-pki

# 创建CA
./easyrsa build-ca

# 生成服务器证书
./easyrsa build-server-full server nopass

# 生成客户端证书
./easyrsa build-client-full client1 nopass

# 生成DH参数
./easyrsa gen-dh
```

3. **创建服务端配置**

```bash
sudo nano /etc/openvpn/server.conf
```

配置内容：

```ini
port 1194
proto udp
dev tun

ca /root/openvpn-ca/pki/ca.crt
cert /root/openvpn-ca/pki/issued/server.crt
key /root/openvpn-ca/pki/private/server.key
dh /root/openvpn-ca/pki/dh.pem

topology subnet

server 10.8.0.0 255.255.255.0

ifconfig-pool-persist /var/log/openvpn/ipp.txt

push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"

keepalive 10 120

cipher AES-256-GCM
data-ciphers AES-256-GCM:AES-128-GCM:CHACHA20-POLY1305

persist-key
persist-tun

status /var/log/openvpn/openvpn-status.log
verb 3

explicit-exit-notify 1
```

4. **启用IP转发**

```bash
sudo sysctl -w net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

5. **配置防火墙**

```bash
sudo ufw allow 1194/udp
sudo ufw allow from 10.8.0.0/24
```

6. **启动OpenVPN**

```bash
sudo systemctl enable openvpn@server
sudo systemctl start openvpn@server
```

### CentOS/RHEL

1. **安装OpenVPN**

```bash
sudo yum install epel-release -y
sudo yum install openvpn easy-rsa -y
```

2. **配置PKI和服务**

```bash
# 设置PKI（同Ubuntu）
make-cadir ~/openvpn-ca
cd ~/openvpn-ca
./easyrsa init-pki
./easyrsa build-ca
./easyrsa build-server-full server nopass
./easyrsa build-client-full client1 nopass
./easyrsa gen-dh

# 创建配置文件
sudo nano /etc/openvpn/server.conf

# 启动服务
sudo systemctl enable openvpn@server
sudo systemctl start openvpn@server
```

## Shadowsocks 手动安装

### Ubuntu/Debian

1. **安装Shadowsocks**

```bash
sudo apt install shadowsocks-libev -y
```

2. **创建配置文件**

```bash
sudo nano /etc/shadowsocks-libev/config.json
```

配置内容：

```json
{
    "server": "0.0.0.0",
    "server_port": 8388,
    "password": "your-password",
    "timeout": 300,
    "method": "aes-256-gcm",
    "fast_open": false,
    "mode": "tcp_and_udp",
    "no_delay": true
}
```

3. **启动Shadowsocks**

```bash
sudo systemctl enable shadowsocks-libev
sudo systemctl start shadowsocks-libev
```

### CentOS/RHEL

1. **安装依赖**

```bash
sudo yum install epel-release -y
sudo yum install libsodium -y
```

2. **安装Shadowsocks**

```bash
# 下载最新版本
wget https://github.com/shadowsocks/shadowsocks-libev/releases/latest/download/shadowsocks-libev-*.tar.gz
tar -xzf shadowsocks-libev-*.tar.gz
cd shadowsocks-libev-*
./configure
make
sudo make install
```

3. **创建配置文件**

```bash
sudo nano /usr/local/etc/shadowsocks-libev/config.json
```

4. **创建服务文件**

```bash
sudo nano /etc/systemd/system/shadowsocks-libev.service
```

服务文件内容：

```ini
[Unit]
Description=Shadowsocks-libev
Documentation=https://github.com/shadowsocks/shadowsocks-libev
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/ss-server -c /usr/local/etc/shadowsocks-libev/config.json
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
```

5. **启动服务**

```bash
sudo systemctl daemon-reload
sudo systemctl enable shadowsocks-libev
sudo systemctl start shadowsocks-libev
```

## V2Ray 手动安装

### Ubuntu/Debian

1. **安装V2Ray**

```bash
bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh)
```

2. **创建配置文件**

```bash
sudo nano /usr/local/etc/v2ray/config.json
```

配置内容（VMess + WebSocket + TLS）：

```json
{
    "log": {
        "loglevel": "warning"
    },
    "inbounds": [
        {
            "listen": "0.0.0.0",
            "port": 443,
            "protocol": "vmess",
            "settings": {
                "clients": [
                    {
                        "id": "your-uuid",
                        "alterId": 0
                    }
                ]
            },
            "streamSettings": {
                "network": "ws",
                "security": "tls",
                "tlsSettings": {
                    "certificates": [
                        {
                            "certificateFile": "/etc/ssl/certs/your-cert.pem",
                            "keyFile": "/etc/ssl/private/your-key.pem"
                        }
                    ]
                },
                "wsSettings": {
                    "path": "/your-path"
                }
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom",
            "tag": "direct"
        },
        {
            "protocol": "blackhole",
            "tag": "blocked"
        }
    ]
}
```

3. **启动V2Ray**

```bash
sudo systemctl enable v2ray
sudo systemctl start v2ray
```

### 使用Xray

```bash
# 安装Xray
bash <(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)

# 创建配置文件
sudo nano /usr/local/etc/xray/config.json

# 启动Xray
sudo systemctl enable xray
sudo systemctl start xray
```

## 防火墙配置

### Ubuntu/Debian (UFW)

```bash
# 允许SSH
sudo ufw allow 22/tcp

# 允许VPN端口
sudo ufw allow 51820/udp  # WireGuard
sudo ufw allow 1194/udp   # OpenVPN
sudo ufw allow 8388/tcp   # Shadowsocks TCP
sudo ufw allow 8388/udp   # Shadowsocks UDP
sudo ufw allow 443/tcp    # V2Ray

# 启用防火墙
sudo ufw enable

# 查看状态
sudo ufw status
```

### CentOS/RHEL (firewalld)

```bash
# 允许VPN端口
sudo firewall-cmd --permanent --add-port=51820/udp  # WireGuard
sudo firewall-cmd --permanent --add-port=1194/udp   # OpenVPN
sudo firewall-cmd --permanent --add-port=8388/tcp   # Shadowsocks TCP
sudo firewall-cmd --permanent --add-port=8388/udp   # Shadowsocks UDP
sudo firewall-cmd --permanent --add-port=443/tcp    # V2Ray

# 重新加载
sudo firewall-cmd --reload

# 查看状态
sudo firewall-cmd --list-all
```

## 网络配置

### IP转发

```bash
# 临时启用
sudo sysctl -w net.ipv4.ip_forward=1

# 永久启用
echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

### 路由配置

```bash
# 查看路由表
ip route show

# 添加路由
sudo ip route add 10.0.0.0/24 via 10.0.0.1

# 删除路由
sudo ip route del 10.0.0.0/24
```

### DNS配置

```bash
# 查看DNS配置
cat /etc/resolv.conf

# 修改DNS
sudo nano /etc/resolv.conf
```

## 服务管理

### systemd命令

```bash
# 启动服务
sudo systemctl start service-name

# 停止服务
sudo systemctl stop service-name

# 重启服务
sudo systemctl restart service-name

# 查看状态
sudo systemctl status service-name

# 设置开机启动
sudo systemctl enable service-name

# 禁用开机启动
sudo systemctl disable service-name
```

### 查看日志

```bash
# 查看服务日志
sudo journalctl -u service-name -f

# 查看最近日志
sudo journalctl -u service-name --since "1 hour ago"

# 查看错误日志
sudo journalctl -u service-name | grep -i error
```

## 性能调优

### 内核参数

```bash
# 编辑sysctl.conf
sudo nano /etc/sysctl.conf

# 添加以下参数
net.core.rmem_max=16777216
net.core.wmem_max=16777216
net.ipv4.tcp_rmem=4096 87380 16777216
net.ipv4.tcp_wmem=4096 65536 16777216
net.ipv4.tcp_congestion_control=bbr
net.core.default_qdisc=fq
```

### 应用配置

```bash
# 应用配置
sudo sysctl -p

# 验证配置
sysctl net.core.rmem_max
```

## 故障排除

### 常见问题

1. **服务无法启动**
   ```bash
   # 检查配置语法
   v2ray -test -config /usr/local/etc/v2ray/config.json
   
   # 检查端口占用
   sudo netstat -tulpn | grep :port
   ```

2. **连接问题**
   ```bash
   # 检查防火墙
   sudo ufw status
   
   # 检查网络
   ping -c 4 your-server-ip
   ```

3. **权限问题**
   ```bash
   # 检查文件权限
   ls -la /etc/wireguard/
   
   # 修复权限
   sudo chmod 600 /etc/wireguard/server_private.key
   ```

### 日志分析

```bash
# 查看系统日志
sudo tail -f /var/log/syslog

# 查看服务日志
sudo journalctl -u service-name -f

# 搜索错误信息
sudo journalctl -u service-name | grep -i error
```

## 维护任务

### 定期更新

```bash
# 更新系统
sudo apt update && sudo apt upgrade -y

# 更新VPN软件
sudo apt install --only-upgrade wireguard openvpn shadowsocks-libev
```

### 备份配置

```bash
# 备份配置目录
sudo tar -czf vpn-backup-$(date +%Y%m%d).tar.gz /etc/wireguard /etc/openvpn /usr/local/etc/v2ray

# 恢复配置
sudo tar -xzf vpn-backup-20240101.tar.gz -C /
```

### 监控状态

```bash
# 检查服务状态
sudo systemctl status wireguard openvpn shadowsocks-libev v2ray

# 检查连接数
ss -antlp | grep -E ':(51820|1194|8388|443)'

# 检查系统资源
top -bn1 | head -20
```

## 最佳实践

1. **定期更新系统**：保持系统和软件更新
2. **备份重要配置**：定期备份VPN配置
3. **监控系统日志**：及时发现异常
4. **使用强密码**：为所有服务设置强密码
5. **限制访问权限**：只允许必要的端口和IP
6. **记录维护日志**：记录所有配置更改
7. **测试配置**：在生产环境前测试配置
8. **文档化配置**：记录所有配置细节