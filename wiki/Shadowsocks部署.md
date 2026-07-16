# Shadowsocks 部署指南

Shadowsocks是一个轻量级的代理协议，以其简单性和抗封锁能力著称。

## Shadowsocks 简介

### 特点

- **轻量级**：资源占用小
- **抗封锁**：设计用于绕过网络限制
- **简单易用**：配置简单，客户端丰富
- **高性能**：低延迟，高吞吐量
- **跨平台**：支持几乎所有操作系统

### 工作原理

Shadowsocks工作在OSI模型的第5层（会话层），使用加密的TCP或UDP连接。

```
客户端 ←→ Shadowsocks服务端 ←→ 互联网
```

## 部署方式

### 方式一：Docker部署

#### 使用Docker Compose

1. **创建项目目录**

```bash
mkdir -p ~/shadowsocks && cd ~/shadowsocks
```

2. **创建docker-compose.yml**

```yaml
version: '3.8'

services:
  shadowsocks:
    image: shadowsocks/shadowsocks-libev
    container_name: shadowsocks
    environment:
      - SERVER_PORT=8388
      - PASSWORD=your-password
      - METHOD=aes-256-gcm
      - TIMEOUT=300
    ports:
      - 8388:8388/tcp
      - 8388:8388/udp
    restart: unless-stopped
```

3. **启动服务**

```bash
sudo docker-compose up -d
```

4. **查看日志**

```bash
sudo docker logs -f shadowsocks
```

#### 使用Docker命令

```bash
# 启动Shadowsocks
docker run -d \
  --name shadowsocks \
  -p 8388:8388/tcp \
  -p 8388:8388/udp \
  -e SERVER_PORT=8388 \
  -e PASSWORD=your-password \
  -e METHOD=aes-256-gcm \
  -e TIMEOUT=300 \
  --restart=unless-stopped \
  shadowsocks/shadowsocks-libev
```

### 方式二：手动安装

#### Ubuntu/Debian

1. **安装Shadowsocks**

```bash
sudo apt update
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

#### CentOS/RHEL

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

### 方式三：使用安装脚本

```bash
# 下载安装脚本
wget https://raw.githubusercontent.com/the0demiurge/ShadowsocksR-install/master/shadowsocksR.sh

# 添加执行权限
chmod +x shadowsocksR.sh

# 运行安装脚本
sudo ./shadowsocksR.sh
```

## 客户端配置

### Windows

1. 下载Shadowsocks Windows客户端：https://github.com/shadowsocks/shadowsocks-windows/releases
2. 输入服务器信息
3. 连接代理

### macOS

```bash
# 使用Homebrew安装
brew install shadowsocks-libev

# 配置客户端
cat > ~/.config/shadowsocks-libev/config.json << EOF
{
    "server": "your-server-ip",
    "server_port": 8388,
    "password": "your-password",
    "method": "aes-256-gcm",
    "timeout": 300
}
EOF

# 启动客户端
ss-local -c ~/.config/shadowsocks-libev/config.json
```

### iOS/Android

1. 下载Shadowsocks应用
2. 输入服务器信息
3. 连接代理

### Linux

```bash
# 安装Shadowsocks
sudo apt install shadowsocks-libev

# 配置客户端
cat > ~/.config/shadowsocks-libev/config.json << EOF
{
    "server": "your-server-ip",
    "server_port": 8388,
    "password": "your-password",
    "method": "aes-256-gcm",
    "timeout": 300
}
EOF

# 启动客户端
ss-local -c ~/.config/shadowsocks-libev/config.json
```

## 管理命令

### 查看状态

```bash
# 查看服务状态
sudo systemctl status shadowsocks-libev

# 查看日志
sudo journalctl -u shadowsocks-libev -f

# 查看进程
ps aux | grep ss-server
```

### 管理连接

```bash
# 查看连接数
ss -antlp | grep 8388

# 查看流量
iftop -i eth0 -f "port 8388"
```

### 配置管理

```bash
# 备份配置
sudo cp /etc/shadowsocks-libev/config.json /etc/shadowsocks-libev/config.json.backup

# 恢复配置
sudo cp /etc/shadowsocks-libev/config.json.backup /etc/shadowsocks-libev/config.json

# 重启服务
sudo systemctl restart shadowsocks-libev
```

## 高级配置

### 多用户配置

```json
{
    "server": "0.0.0.0",
    "server_port": 8388,
    "password": "default-password",
    "timeout": 300,
    "method": "aes-256-gcm",
    "fast_open": false,
    "mode": "tcp_and_udp",
    "no_delay": true,
    "users": [
        {
            "username": "user1",
            "password": "user1-password"
        },
        {
            "username": "user2",
            "password": "user2-password"
        }
    ]
}
```

### 路由配置

```json
{
    "server": "0.0.0.0",
    "server_port": 8388,
    "password": "your-password",
    "timeout": 300,
    "method": "aes-256-gcm",
    "fast_open": false,
    "mode": "tcp_and_udp",
    "no_delay": true,
    "route": {
        "enabled": true,
        "bypass": [
            "127.0.0.0/8",
            "10.0.0.0/8",
            "172.16.0.0/12",
            "192.168.0.0/16"
        ],
        "block": [],
        "proxy": []
    }
}
```

### DNS配置

```json
{
    "server": "0.0.0.0",
    "server_port": 8388,
    "password": "your-password",
    "timeout": 300,
    "method": "aes-256-gcm",
    "fast_open": false,
    "mode": "tcp_and_udp",
    "no_delay": true,
    "dns": {
        "server": [
            "8.8.8.8",
            "8.8.4.4",
            "1.1.1.1"
        ],
        "timeout": 5
    }
}
```

## 故障排除

### 常见问题

1. **无法连接**
   ```bash
   # 检查端口
   sudo netstat -tulpn | grep 8388
   
   # 检查防火墙
   sudo ufw status
   ```

2. **连接速度慢**
   ```bash
   # 检查网络延迟
   ping -c 10 your-server-ip
   
   # 检查服务器负载
   top
   ```

3. **密码错误**
   ```bash
   # 检查配置文件
   cat /etc/shadowsocks-libev/config.json
   ```

### 日志查看

```bash
# 查看Shadowsocks日志
sudo journalctl -u shadowsocks-libev -f

# 查看系统日志
sudo tail -f /var/log/syslog | grep shadowsocks
```

## 性能优化

1. **使用快速TCP算法**：
   ```json
   {
       "fast_open": true,
       "no_delay": true
   }
   ```

2. **优化缓冲区大小**：
   ```json
   {
       "buffer_size": 65535
   }
   ```

3. **使用UDP转发**：
   ```json
   {
       "mode": "tcp_and_udp"
   }
   ```

4. **调整超时时间**：
   ```json
   {
       "timeout": 600
   }
   ```

## 安全建议

1. **使用强密码**：建议使用16位以上随机密码
2. **定期更换密码**：建议每月更换一次
3. **使用加密算法**：推荐aes-256-gcm
4. **限制访问IP**：只允许特定IP连接
5. **启用日志记录**：监控连接情况
6. **更新软件**：保持Shadowsocks为最新版本