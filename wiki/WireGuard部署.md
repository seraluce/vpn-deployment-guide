# WireGuard 部署指南

WireGuard是一个现代、高性能的VPN协议，以其简洁性和安全性著称。

## WireGuard 简介

### 特点

- **高性能**：比OpenVPN快3-4倍
- **简单配置**：配置文件简洁明了
- **现代加密**：使用先进的加密算法
- **低延迟**：连接建立速度快
- **跨平台**：支持Windows、macOS、Linux、iOS、Android

### 工作原理

WireGuard工作在OSI模型的第3层（网络层），使用UDP协议进行通信。

```
客户端 ←→ WireGuard服务端 ←→ 互联网
```

## 部署方式

### 方式一：Docker部署（推荐）

#### 使用Docker Compose

1. **创建项目目录**

```bash
mkdir -p ~/wireguard && cd ~/wireguard
```

2. **创建docker-compose.yml**

```yaml
version: '3.8'

services:
  wireguard:
    image: linuxserver/wireguard
    container_name: wireguard
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Asia/Shanghai
      - SERVERURL=your-server-ip
      - SERVERPORT=51820
      - PEERS=3
      - PEERDNS=auto
      - INTERNAL_SUBNET=10.13.13.0
    volumes:
      - ./config:/config
      - /lib/modules:/lib/modules
    ports:
      - 51820:51820/udp
    sysctls:
      - net.ipv4.conf.all.src_valid_mark=1
    restart: unless-stopped
```

3. **启动服务**

```bash
sudo docker-compose up -d
```

4. **查看日志**

```bash
sudo docker logs -f wireguard
```

5. **获取客户端配置**

```bash
# 查看peer1配置
sudo cat ~/wireguard/config/peer1/peer1.conf

# 查看peer2配置
sudo cat ~/wireguard/config/peer2/peer2.conf
```

#### 使用Docker命令

```bash
# 创建配置目录
mkdir -p /etc/wireguard

# 运行WireGuard容器
docker run -d \
  --name=wireguard \
  --cap-add=NET_ADMIN \
  --cap-add=SYS_MODULE \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Asia/Shanghai \
  -e SERVERURL=your-server-ip \
  -e SERVERPORT=51820 \
  -e PEERS=1 \
  -e PEERDNS=auto \
  -e INTERNAL_SUBNET=10.13.13.0 \
  -p 51820:51820/udp \
  -v /etc/wireguard:/config \
  -v /lib/modules:/lib/modules \
  --sysctl net.ipv4.conf.all.src_valid_mark=1 \
  --restart=unless-stopped \
  linuxserver/wireguard
```

### 方式二：手动安装

#### Ubuntu/Debian

1. **安装WireGuard**

```bash
sudo apt update
sudo apt install wireguard wireguard-tools -y
```

2. **生成密钥对**

```bash
# 生成服务端私钥
wg genkey | tee /etc/wireguard/server_private.key | wg pubkey > /etc/wireguard/server_public.key

# 设置权限
chmod 600 /etc/wireguard/server_private.key
```

3. **创建服务端配置**

```bash
sudo nano /etc/wireguard/wg0.conf
```

配置内容：

```ini
[Interface]
# 服务端私钥
PrivateKey = <server-private-key>
# VPN内部IP地址
Address = 10.0.0.1/24
# 监听端口
ListenPort = 51820
# 启用IP转发
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

[Peer]
# 客户端公钥
PublicKey = <client-public-key>
# 客户端分配的IP
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

#### CentOS/RHEL

1. **安装WireGuard**

```bash
sudo yum install epel-release -y
sudo yum install wireguard-tools -y
```

2. **生成密钥和配置**

```bash
# 生成密钥
wg genkey | tee /etc/wireguard/server_private.key | wg pubkey > /etc/wireguard/server_public.key

# 创建配置文件
sudo nano /etc/wireguard/wg0.conf
```

3. **启动服务**

```bash
sudo systemctl enable wg-quick@wg0
sudo systemctl start wg-quick@wg0
```

### 方式三：使用安装脚本

```bash
# 下载安装脚本
curl -O https://raw.githubusercontent.com/angristan/wireguard-install/master/wireguard-install.sh

# 添加执行权限
chmod +x wireguard-install.sh

# 运行安装脚本
sudo ./wireguard-install.sh
```

脚本会自动：
- 安装WireGuard
- 生成密钥
- 配置服务端
- 创建客户端配置

## 客户端配置

### Windows

1. 下载WireGuard客户端：https://www.wireguard.com/install/
2. 导入配置文件或手动添加
3. 连接VPN

### macOS

```bash
# 使用Homebrew安装
brew install wireguard-tools

# 导入配置
sudo wg-quick up wg0

# 断开连接
sudo wg-quick down wg0
```

### iOS/Android

1. 下载WireGuard应用
2. 扫描配置二维码
3. 连接VPN

### Linux客户端

```bash
# 安装WireGuard
sudo apt install wireguard-tools

# 导入配置
sudo wg-quick up wg0

# 查看状态
sudo wg show

# 断开连接
sudo wg-quick down wg0
```

## 管理命令

### 查看状态

```bash
# 查看WireGuard状态
sudo wg show

# 查看接口信息
sudo ip addr show wg0

# 查看路由表
sudo ip route show | grep wg0
```

### 管理客户端

```bash
# 添加客户端
sudo wg set wg0 peer <client-public-key> allowed-ips 10.0.0.2/32

# 移除客户端
sudo wg set wg0 peer <client-public-key> remove

# 查看所有连接
sudo wg show wg0 latest-handshakes
```

### 配置文件管理

```bash
# 备份配置
sudo cp /etc/wireguard/wg0.conf /etc/wireguard/wg0.conf.backup

# 恢复配置
sudo cp /etc/wireguard/wg0.conf.backup /etc/wireguard/wg0.conf

# 重启服务
sudo systemctl restart wg-quick@wg0
```

## 高级配置

### 多用户配置

```ini
[Interface]
PrivateKey = <server-private-key>
Address = 10.0.0.1/24
ListenPort = 51820
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

# 用户1
[Peer]
PublicKey = <user1-public-key>
AllowedIPs = 10.0.0.2/32

# 用户2
[Peer]
PublicKey = <user2-public-key>
AllowedIPs = 10.0.0.3/32

# 用户3
[Peer]
PublicKey = <user3-public-key>
AllowedIPs = 10.0.0.4/32
```

### 路由配置

```ini
[Interface]
PrivateKey = <server-private-key>
Address = 10.0.0.1/24
ListenPort = 51820
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

[Peer]
PublicKey = <client-public-key>
# 只路由特定IP段
AllowedIPs = 10.0.0.2/32, 192.168.1.0/24
```

### DNS配置

```ini
[Interface]
PrivateKey = <server-private-key>
Address = 10.0.0.1/24
ListenPort = 51820
DNS = 8.8.8.8, 8.8.4.4
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
```

## 故障排除

### 常见问题

1. **无法连接**
   ```bash
   # 检查端口是否监听
   sudo netstat -tulpn | grep 51820
   
   # 检查防火墙
   sudo ufw status
   ```

2. **连接后无法上网**
   ```bash
   # 检查IP转发
   cat /proc/sys/net/ipv4/ip_forward
   
   # 检查路由表
   ip route show
   ```

3. **速度慢**
   ```bash
   # 检查MTU值
   sudo ip link set mtu 1420 dev wg0
   
   # 检查网络延迟
   ping -c 10 10.0.0.1
   ```

### 日志查看

```bash
# 查看WireGuard日志
sudo journalctl -u wg-quick@wg0 -f

# 查看系统日志
sudo tail -f /var/log/syslog | grep wireguard
```

## 性能优化

1. **调整MTU值**：默认1420，可根据网络情况调整
2. **优化内核参数**：
   ```bash
   sudo sysctl -w net.core.rmem_max=26214400
   sudo sysctl -w net.core.wmem_max=26214400
   ```
3. **使用SSD存储**：提高密钥交换性能
4. **选择合适地理位置**：减少延迟

## 安全建议

1. **定期更换密钥**：建议每3个月更换一次
2. **限制访问IP**：只允许特定IP连接
3. **启用防火墙**：只开放必要端口
4. **监控连接**：定期检查连接日志
5. **更新软件**：保持WireGuard为最新版本