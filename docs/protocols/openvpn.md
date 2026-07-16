# OpenVPN 部署指南

OpenVPN是一个成熟的、功能丰富的VPN解决方案，支持多种认证方式和加密算法。

## OpenVPN 简介

### 特点

- **成熟稳定**：经过长期验证的稳定解决方案
- **兼容性好**：支持几乎所有操作系统
- **功能丰富**：支持多种认证方式和加密算法
- **社区活跃**：拥有庞大的用户社区
- **文档完善**：有详细的官方文档

### 工作原理

OpenVPN工作在OSI模型的第2层（数据链路层）或第3层（网络层），使用TCP或UDP协议。

```
客户端 ←→ OpenVPN服务端 ←→ 互联网
```

## 部署方式

### 方式一：Docker部署

#### 使用Docker Compose

1. **创建项目目录**

```bash
mkdir -p ~/openvpn && cd ~/openvpn
```

2. **创建docker-compose.yml**

```yaml
version: '3.8'

services:
  openvpn:
    image: kylemanna/openvpn
    container_name: openvpn
    cap_add:
      - NET_ADMIN
    environment:
      - OVPN_DATA=/etc/openvpn
      - OVPN_CN=your-server-ip
      - OVPN_PORT=1194
    volumes:
      - ./data:/etc/openvpn
    ports:
      - 1194:1194/udp
    restart: unless-stopped
```

3. **初始化配置**

```bash
sudo docker-compose run --rm openvpn ovpn_genconfig -u udp://your-server-ip
sudo docker-compose run --rm openvpn ovpn_initpki
```

4. **启动服务**

```bash
sudo docker-compose up -d
```

5. **生成客户端证书**

```bash
# 生成用户证书
sudo docker-compose run --rm openvpn easyrsa build-client-full client1 nopass

# 导出客户端配置
sudo docker-compose run --rm openvpn ovpn_getpkg client1
```

#### 使用Docker命令

```bash
# 创建数据目录
mkdir -p /etc/openvpn

# 初始化配置
docker run -v /etc/openvpn:/etc/openvpn --rm kylemanna/openvpn ovpn_genconfig -u udp://your-server-ip
docker run -v /etc/openvpn:/etc/openvpn --rm -it kylemanna/openvpn ovpn_initpki

# 启动OpenVPN
docker run -v /etc/openvpn:/etc/openvpn -d --name openvpn --cap-add=NET_ADMIN -p 1194:1194/udp kylemanna/openvpn

# 生成客户端配置
docker run -v /etc/openvpn:/etc/openvpn --rm -it kylemanna/openvpn easyrsa build-client-full client1 nopass
docker run -v /etc/openvpn:/etc/openvpn --rm kylemanna/openvpn ovpn_getpkg client1
```

### 方式二：手动安装

#### Ubuntu/Debian

1. **安装OpenVPN**

```bash
sudo apt update
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
# 临时启用
sudo sysctl -w net.ipv4.ip_forward=1

# 永久启用
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

### 方式三：使用安装脚本

```bash
# 下载安装脚本
curl -O https://raw.githubusercontent.com/angristan/openvpn-install/master/openvpn-install.sh

# 添加执行权限
chmod +x openvpn-install.sh

# 运行安装脚本
sudo ./openvpn-install.sh
```

脚本会自动：
- 安装OpenVPN和Easy-RSA
- 配置PKI
- 生成证书
- 配置服务端
- 创建客户端配置

## 客户端配置

### Windows

1. 下载OpenVPN客户端：https://openvpn.net/community-downloads/
2. 导入.ovpn配置文件
3. 连接VPN

### macOS

```bash
# 使用Homebrew安装
brew install openvpn

# 导入配置
sudo openvpn --config client.ovpn
```

### iOS/Android

1. 下载OpenVPN Connect应用
2. 导入.ovpn配置文件
3. 连接VPN

### Linux

```bash
# 安装OpenVPN
sudo apt install openvpn

# 导入配置
sudo openvpn --config client.ovpn

# 或使用systemd
sudo systemctl enable openvpn@client
sudo systemctl start openvpn@client
```

## 管理命令

### 查看状态

```bash
# 查看服务状态
sudo systemctl status openvpn@server

# 查看日志
sudo journalctl -u openvpn@server -f

# 查看连接
sudo cat /var/log/openvpn/openvpn-status.log
```

### 管理客户端

```bash
# 生成新客户端证书
cd ~/openvpn-ca
./easyrsa build-client-full client2 nopass

# 撤销客户端证书
./easyrsa revoke client1

# 生成CRL
./easyrsa gen-crl

# 更新CRL到服务端
sudo cp pki/crl.pem /etc/openvpn/crl.pem
```

### 配置管理

```bash
# 备份配置
sudo cp /etc/openvpn/server.conf /etc/openvpn/server.conf.backup

# 恢复配置
sudo cp /etc/openvpn/server.conf.backup /etc/openvpn/server.conf

# 重启服务
sudo systemctl restart openvpn@server
```

## 高级配置

### TCP模式

```ini
port 443
proto tcp
dev tun
```

### 多客户端配置

```ini
# 客户端1
[Peer]
PublicKey = <client1-public-key>
AllowedIPs = 10.0.0.2/32

# 客户端2
[Peer]
PublicKey = <client2-public-key>
AllowedIPs = 10.0.0.3/32
```

### 路由配置

```ini
# 只路由特定IP
push "route 192.168.1.0 255.255.255.0"

# 排除特定IP
push "route-nopull"
push "route 10.0.0.0 255.0.0.0 vpn_gateway"
push "route 192.168.0.0 255.255.0.0 vpn_gateway"
```

### DNS配置

```ini
# 使用自定义DNS
push "dhcp-option DNS 1.1.1.1"
push "dhcp-option DNS 1.0.0.1"

# 使用本地DNS
push "dhcp-option DNS 10.0.0.1"
```

## 故障排除

### 常见问题

1. **无法连接**
   ```bash
   # 检查端口
   sudo netstat -tulpn | grep 1194
   
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

3. **证书错误**
   ```bash
   # 检查证书
   openssl x509 -in server.crt -text -noout
   
   # 检查CRL
   openssl crl -in crl.pem -text -noout
   ```

### 日志查看

```bash
# 查看OpenVPN日志
sudo journalctl -u openvpn@server -f

# 查看系统日志
sudo tail -f /var/log/syslog | grep openvpn
```

## 性能优化

1. **使用UDP协议**：比TCP更快
2. **调整加密算法**：使用AES-256-GCM
3. **优化MTU值**：根据网络情况调整
4. **使用压缩**：启用LZ4压缩
5. **调整keepalive参数**：减少心跳间隔

## 安全建议

1. **使用强密码**：为CA和客户端证书设置强密码
2. **定期轮换证书**：建议每6个月轮换一次
3. **启用TLS认证**：增加额外的安全层
4. **限制访问IP**：只允许特定IP连接
5. **监控连接**：定期检查连接日志
6. **更新软件**：保持OpenVPN为最新版本