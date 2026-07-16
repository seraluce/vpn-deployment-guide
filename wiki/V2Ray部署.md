# V2Ray/Xray 部署指南

V2Ray是一个功能丰富的代理工具，支持多种协议和传输方式。Xray是V2Ray的增强分支，提供更多功能和更好的性能。

## V2Ray/Xray 简介

### 特点

- **功能丰富**：支持多种协议和传输方式
- **高度可定制**：灵活的配置选项
- **抗封锁**：设计用于绕过网络限制
- **高性能**：优化的代码实现
- **跨平台**：支持几乎所有操作系统

### 工作原理

V2Ray工作在OSI模型的第7层（应用层），支持多种传输协议。

```
客户端 ←→ V2Ray/Xray服务端 ←→ 互联网
```

## 部署方式

### 方式一：Docker部署

#### 使用Docker Compose

1. **创建项目目录**

```bash
mkdir -p ~/v2ray && cd ~/v2ray
```

2. **创建docker-compose.yml**

```yaml
version: '3.8'

services:
  v2ray:
    image: v2fly/v2ray-core
    container_name: v2ray
    volumes:
      - ./config.json:/etc/v2ray/config.json
    ports:
      - "443:443"
      - "443:443/udp"
    restart: unless-stopped
```

3. **创建配置文件**

```bash
nano config.json
```

配置内容（VMess + WebSocket + TLS）：

```json
{
    "log": {
        "loglevel": "warning"
    },
    "routing": {
        "domainStrategy": "AsIs",
        "rules": [
            {
                "type": "field",
                "outboundTag": "direct",
                "domain": ["geosite:cn"]
            }
        ]
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

4. **启动服务**

```bash
sudo docker-compose up -d
```

5. **查看日志**

```bash
sudo docker logs -f v2ray
```

#### 使用Xray

```bash
# 创建配置目录
mkdir -p ~/xray && cd ~/xray

# 创建docker-compose.yml
cat > docker-compose.yml << EOF
version: '3.8'

services:
  xray:
    image: teddysun/xray
    container_name: xray
    volumes:
      - ./config.json:/etc/xray/config.json
    ports:
      - "443:443"
      - "443:443/udp"
    restart: unless-stopped
EOF

# 创建配置文件（与V2Ray类似）
# 启动服务
sudo docker-compose up -d
```

### 方式二：手动安装

#### Ubuntu/Debian

1. **安装V2Ray**

```bash
# 下载安装脚本
bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh)
```

2. **创建配置文件**

```bash
sudo nano /usr/local/etc/v2ray/config.json
```

3. **启动V2Ray**

```bash
sudo systemctl enable v2ray
sudo systemctl start v2ray
```

#### 使用Xray

```bash
# 下载Xray安装脚本
bash <(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)

# 创建配置文件
sudo nano /usr/local/etc/xray/config.json

# 启动Xray
sudo systemctl enable xray
sudo systemctl start xray
```

### 方式三：使用安装脚本

```bash
# 下载V2Ray安装脚本
wget https://raw.githubusercontent.com/FunctionClub/V2Ray-Bash/master/install.sh

# 添加执行权限
chmod +x install.sh

# 运行安装脚本
sudo ./install.sh
```

## 客户端配置

### Windows

1. 下载V2RayN客户端：https://github.com/2dust/v2rayN/releases
2. 导入配置文件
3. 连接代理

### macOS

```bash
# 使用Homebrew安装
brew install v2ray

# 配置客户端
cat > ~/.config/v2ray/config.json << EOF
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
            },
            "streamSettings": {
                "network": "ws",
                "security": "tls",
                "tlsSettings": {
                    "serverName": "your-domain"
                },
                "wsSettings": {
                    "path": "/your-path"
                }
            }
        }
    ]
}
EOF

# 启动客户端
v2ray -config ~/.config/v2ray/config.json
```

### iOS/Android

1. 下载V2Ray应用（如Shadowrocket、Quantumult X、V2RayNG）
2. 导入配置文件
3. 连接代理

### Linux

```bash
# 安装V2Ray
sudo apt install v2ray

# 配置客户端
cat > ~/.config/v2ray/config.json << EOF
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
            },
            "streamSettings": {
                "network": "ws",
                "security": "tls",
                "tlsSettings": {
                    "serverName": "your-domain"
                },
                "wsSettings": {
                    "path": "/your-path"
                }
            }
        }
    ]
}
EOF

# 启动客户端
v2ray -config ~/.config/v2ray/config.json
```

## 管理命令

### 查看状态

```bash
# 查看服务状态
sudo systemctl status v2ray

# 查看日志
sudo journalctl -u v2ray -f

# 查看进程
ps aux | grep v2ray
```

### 管理连接

```bash
# 查看连接数
ss -antlp | grep 443

# 查看流量
iftop -i eth0 -f "port 443"
```

### 配置管理

```bash
# 备份配置
sudo cp /usr/local/etc/v2ray/config.json /usr/local/etc/v2ray/config.json.backup

# 恢复配置
sudo cp /usr/local/etc/v2ray/config.json.backup /usr/local/etc/v2ray/config.json

# 重启服务
sudo systemctl restart v2ray
```

## 高级配置

### VMess + TCP + Mux

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
                "network": "tcp",
                "security": "tls",
                "tlsSettings": {
                    "certificates": [
                        {
                            "certificateFile": "/etc/ssl/certs/your-cert.pem",
                            "keyFile": "/etc/ssl/private/your-key.pem"
                        }
                    ]
                }
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom",
            "tag": "direct"
        }
    ]
}
```

### VLESS + Reality

```json
{
    "log": {
        "loglevel": "warning"
    },
    "inbounds": [
        {
            "listen": "0.0.0.0",
            "port": 443,
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": "your-uuid",
                        "flow": "xtls-rprx-vision"
                    }
                ],
                "decryption": "none"
            },
            "streamSettings": {
                "network": "tcp",
                "security": "reality",
                "realitySettings": {
                    "show": false,
                    "dest": "www.microsoft.com:443",
                    "xver": 0,
                    "serverNames": [
                        "www.microsoft.com"
                    ],
                    "privateKey": "your-private-key",
                    "shortIds": [
                        ""
                    ]
                }
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom",
            "tag": "direct"
        }
    ]
}
```

### 多用户配置

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
                        "id": "user1-uuid",
                        "alterId": 0
                    },
                    {
                        "id": "user2-uuid",
                        "alterId": 0
                    }
                ]
            },
            "streamSettings": {
                "network": "ws",
                "security": "tls"
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom",
            "tag": "direct"
        }
    ]
}
```

### 路由配置

```json
{
    "log": {
        "loglevel": "warning"
    },
    "routing": {
        "domainStrategy": "AsIs",
        "rules": [
            {
                "type": "field",
                "outboundTag": "direct",
                "domain": ["geosite:cn"]
            },
            {
                "type": "field",
                "outboundTag": "blocked",
                "domain": ["geosite:category-ads"]
            },
            {
                "type": "field",
                "outboundTag": "direct",
                "ip": ["geoip:cn"]
            }
        ]
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

## 故障排除

### 常见问题

1. **无法连接**
   ```bash
   # 检查端口
   sudo netstat -tulpn | grep 443
   
   # 检查防火墙
   sudo ufw status
   ```

2. **TLS证书错误**
   ```bash
   # 检查证书
   openssl x509 -in your-cert.pem -text -noout
   
   # 检查证书链
   openssl verify -CAfile ca-cert.pem your-cert.pem
   ```

3. **配置语法错误**
   ```bash
   # 验证配置
   v2ray -test -config /usr/local/etc/v2ray/config.json
   ```

### 日志查看

```bash
# 查看V2Ray日志
sudo journalctl -u v2ray -f

# 查看系统日志
sudo tail -f /var/log/syslog | grep v2ray
```

## 性能优化

1. **使用WebSocket传输**：更好的兼容性
2. **启用Mux多路复用**：减少连接数
3. **使用TCP Fast Open**：减少连接延迟
4. **优化缓冲区大小**：根据网络情况调整
5. **使用UDP转发**：提高实时应用性能

## 安全建议

1. **使用强UUID**：建议使用随机生成的UUID
2. **启用TLS加密**：使用有效的TLS证书
3. **使用Reality协议**：更好的抗封锁能力
4. **定期更换配置**：建议每月更换一次
5. **限制访问**：只允许特定用户连接
6. **监控日志**：定期检查连接日志
7. **更新软件**：保持V2Ray/Xray为最新版本