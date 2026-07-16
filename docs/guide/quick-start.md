# 快速开始

本指南将帮助您在5分钟内搭建一个基本的VPN服务。

## 第一步：选择VPN协议

**推荐选择WireGuard**：
- 性能最佳
- 配置简单
- 现代加密算法

## 第二步：准备服务器

### 1. 登录服务器

```bash
ssh root@your-server-ip
```

### 2. 更新系统

```bash
# Ubuntu/Debian
sudo apt update && sudo apt upgrade -y

# CentOS/RHEL
sudo yum update -y
```

### 3. 安装Docker（推荐）

```bash
# 安装Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 启动Docker
sudo systemctl start docker
sudo systemctl enable docker

# 安装Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

## 第三步：部署WireGuard

### 方法一：Docker一键部署（推荐）

1. **创建配置目录**

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
      - PEERS=1
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

4. **查看配置**

```bash
sudo docker logs wireguard
```

5. **获取客户端配置**

```bash
sudo cat ~/wireguard/config/peer1/peer1.conf
```

### 方法二：手动安装

1. **安装WireGuard**

```bash
# Ubuntu/Debian
sudo apt install wireguard -y

# CentOS/RHEL
sudo yum install epel-release -y
sudo yum install wireguard-tools -y
```

2. **生成密钥**

```bash
wg genkey | tee privatekey | wg pubkey > publickey
```

3. **配置服务端**

```bash
sudo nano /etc/wireguard/wg0.conf
```

添加以下内容：

```ini
[Interface]
PrivateKey = your-private-key
Address = 10.0.0.1/24
ListenPort = 51820
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

[Peer]
PublicKey = client-public-key
AllowedIPs = 10.0.0.2/32
```

4. **启动WireGuard**

```bash
sudo systemctl enable wg-quick@wg0
sudo systemctl start wg-quick@wg0
```

## 第四步：配置客户端

### Windows/iOS/Android

1. 下载WireGuard客户端
2. 导入配置文件或扫描二维码
3. 连接VPN

### macOS

```bash
# 使用Homebrew安装
brew install wireguard-tools

# 导入配置
sudo wg-quick up wg0
```

## 第五步：验证连接

1. **检查服务端状态**

```bash
sudo wg show
```

2. **测试连接**

```bash
# 从客户端ping服务端
ping 10.0.0.1

# 检查IP地址
curl ifconfig.me
```

## 第六步：配置订阅链接（可选）

1. **安装订阅生成工具**

```bash
# 下载订阅生成脚本
git clone https://github.com/your-repo/subscription-generator.git
cd subscription-generator
npm install
```

2. **生成订阅链接**

```bash
node generate.js --server your-server-ip --port 51820 --protocol wireguard
```

3. **访问订阅链接**

```
https://your-server-ip/subscription/config
```

## 常见问题

### Q: 无法连接VPN？
A: 检查以下项目：
- 服务器防火墙是否开放51820/UDP端口
- 云服务器安全组是否配置正确
- 客户端配置是否正确

### Q: 连接后无法上网？
A: 检查以下项目：
- 服务器IP转发是否启用
- 路由表配置是否正确
- DNS设置是否正常

### Q: 速度很慢？
A: 尝试以下优化：
- 更换服务器地理位置
- 调整MTU值
- 检查服务器带宽

## 下一步

- [防火墙配置](../security/firewall)：配置防火墙和TLS证书
- [订阅链接概述](../subscription/overview)：为多用户生成配置
- [常见问题](../troubleshooting/common-issues)：优化VPN性能

## 获取帮助

如果遇到问题，请查看：
1. [常见问题](../troubleshooting/common-issues)
2. [日志分析](../troubleshooting/logs)
3. 提交Issue到GitHub仓库