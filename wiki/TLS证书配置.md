# TLS证书配置指南

TLS证书用于加密VPN客户端和服务端之间的通信，保护数据传输安全。

## TLS简介

### 什么是TLS

TLS（Transport Layer Security）是一种加密协议，用于在网络通信中提供安全性和数据完整性。

### 证书类型

| 类型 | 说明 | 适用场景 |
|------|------|----------|
| 自签名证书 | 自己生成的证书 | 测试环境 |
| Let's Encrypt | 免费自动证书 | 生产环境 |
| 商业证书 | 付费证书 | 企业环境 |

## Let's Encrypt 证书

### 安装Certbot

#### Ubuntu/Debian

```bash
# 安装Certbot
sudo apt update
sudo apt install certbot

# 安装Nginx插件
sudo apt install python3-certbot-nginx

# 安装Apache插件
sudo apt install python3-certbot-apache
```

#### CentOS/RHEL

```bash
# 安装Certbot
sudo yum install epel-release -y
sudo yum install certbot

# 安装Nginx插件
sudo yum install python2-certbot-nginx

# 安装Apache插件
sudo yum install python2-certbot-apache
```

### 获取证书

#### 使用Nginx插件

```bash
# 自动配置Nginx
sudo certbot --nginx -d your-domain.com

# 手动配置
sudo certbot certonly --nginx -d your-domain.com
```

#### 使用Apache插件

```bash
# 自动配置Apache
sudo certbot --apache -d your-domain.com

# 手动配置
sudo certbot certonly --apache -d your-domain.com
```

#### 使用Standalone模式

```bash
# 停止Web服务器
sudo systemctl stop nginx

# 获取证书
sudo certbot certonly --standalone -d your-domain.com

# 启动Web服务器
sudo systemctl start nginx
```

### 证书管理

#### 查看证书

```bash
# 查看证书列表
sudo certbot certificates

# 查看证书详情
sudo openssl x509 -in /etc/letsencrypt/live/your-domain.com/fullchain.pem -text -noout
```

#### 更新证书

```bash
# 自动更新
sudo certbot renew

# 手动更新
sudo certbot renew --force-renewal
```

#### 删除证书

```bash
# 删除证书
sudo certbot delete --cert-name your-domain.com
```

### 自动续期

#### 设置定时任务

```bash
# 编辑crontab
sudo crontab -e

# 添加以下行
0 12 * * * /usr/bin/certbot renew --quiet
```

#### 测试续期

```bash
# 测试续期流程
sudo certbot renew --dry-run
```

## 自签名证书

### 生成根证书

```bash
# 生成私钥
openssl genrsa -out root.key 4096

# 生成证书
openssl req -x509 -new -nodes -key root.key -sha256 -days 3650 -out root.crt -subj "/CN=VPN Root CA"
```

### 生成服务器证书

```bash
# 生成私钥
openssl genrsa -out server.key 2048

# 生成CSR
openssl req -new -key server.key -out server.csr -subj "/CN=your-domain.com"

# 使用根证书签署
openssl x509 -req -in server.csr -CA root.crt -CAkey root.key -CAcreateserial -out server.crt -days 3650 -sha256
```

### 生成客户端证书

```bash
# 生成私钥
openssl genrsa -out client.key 2048

# 生成CSR
openssl req -new -key client.key -out client.csr -subj "/CN=client"

# 使用根证书签署
openssl x509 -req -in client.csr -CA root.crt -CAkey root.key -CAcreateserial -out client.crt -days 3650 -sha256
```

### 验证证书

```bash
# 验证证书链
openssl verify -CAfile root.crt server.crt

# 查看证书信息
openssl x509 -in server.crt -text -noout
```

## VPN服务端TLS配置

### WireGuard + TLS

WireGuard本身不使用TLS，但可以通过Stunnel或Nginx代理实现TLS加密。

#### 使用Nginx代理

```nginx
# /etc/nginx/conf.d/wireguard.conf
stream {
    upstream wireguard {
        server 127.0.0.1:51820;
    }

    server {
        listen 443 ssl;
        proxy_pass wireguard;
        
        ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;
        
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers HIGH:!aNULL:!MD5;
    }
}
```

### OpenVPN + TLS

OpenVPN原生支持TLS。

#### 服务端配置

```ini
# /etc/openvpn/server.conf
port 443
proto tcp
dev tun

ca ca.crt
cert server.crt
key server.key
dh dh2048.pem

tls-auth ta.key 0

cipher AES-256-GCM
auth SHA256

# TLS安全选项
tls-version-min 1.2
tls-cipher TLS-ECDHE-RSA-WITH-AES-256-GCM-SHA384

# 压缩
compress lz4-v2
push "compress lz4-v2"
```

### V2Ray/Xray + TLS

V2Ray/Xray原生支持TLS。

#### VMess + TLS配置

```json
{
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
                            "certificateFile": "/etc/letsencrypt/live/your-domain.com/fullchain.pem",
                            "keyFile": "/etc/letsencrypt/live/your-domain.com/privkey.pem"
                        }
                    ],
                    "alpn": ["h2", "http/1.1"],
                    "minVersion": "1.2",
                    "maxVersion": "1.3",
                    "ciphers": [
                        "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384",
                        "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384"
                    ]
                }
            }
        }
    ]
}
```

#### VLESS + Reality配置

```json
{
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
    ]
}
```

### Shadowsocks + TLS

Shadowsocks可以通过Stunnel或Nginx代理实现TLS加密。

#### 使用Nginx代理

```nginx
# /etc/nginx/conf.d/shadowsocks.conf
stream {
    upstream shadowsocks {
        server 127.0.0.1:8388;
    }

    server {
        listen 443 ssl;
        proxy_pass shadowsocks;
        
        ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;
        
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers HIGH:!aNULL:!MD5;
    }
}
```

## Nginx TLS配置

### 基本配置

```nginx
# /etc/nginx/conf.d/vpn-proxy.conf
server {
    listen 443 ssl http2;
    server_name your-domain.com;

    ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;

    # TLS安全配置
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;

    # HSTS
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

    # OCSP Stapling
    ssl_stapling on;
    ssl_stapling_verify on;

    # SSL会话配置
    ssl_session_timeout 1d;
    ssl_session_cache shared:SSL:50m;
    ssl_session_tickets off;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### WebSocket配置

```nginx
# /etc/nginx/conf.d/v2ray-ws.conf
server {
    listen 443 ssl http2;
    server_name your-domain.com;

    ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384;

    location /your-path {
        proxy_pass http://127.0.0.1:443;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## 安全加固

### TLS安全配置

```nginx
# TLS安全配置
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384;
ssl_prefer_server_ciphers off;
ssl_session_timeout 1d;
ssl_session_cache shared:SSL:50m;
ssl_session_tickets off;
ssl_stapling on;
ssl_stapling_verify on;
```

### 证书权限设置

```bash
# 设置证书权限
sudo chmod 600 /etc/letsencrypt/live/your-domain.com/privkey.pem
sudo chmod 644 /etc/letsencrypt/live/your-domain.com/fullchain.pem

# 设置目录权限
sudo chmod 700 /etc/letsencrypt/live/your-domain.com
```

### 证书备份

```bash
# 备份证书
sudo tar -czf certs-backup-$(date +%Y%m%d).tar.gz /etc/letsencrypt

# 恢复证书
sudo tar -xzf certs-backup-20240101.tar.gz -C /
```

## 监控和维护

### 证书监控

```bash
#!/bin/bash

# 检查证书过期时间
check_cert_expiry() {
    local cert_file=$1
    local expiry_date=$(openssl x509 -in "$cert_file" -noout -enddate | cut -d= -f2)
    local expiry_epoch=$(date -d "$expiry_date" +%s)
    local current_epoch=$(date +%s)
    local days_left=$(( (expiry_epoch - current_epoch) / 86400 ))
    
    echo "证书文件: $cert_file"
    echo "过期日期: $expiry_date"
    echo "剩余天数: $days_left"
    
    if [ $days_left -lt 30 ]; then
        echo "警告: 证书将在30天内过期！"
        # 发送告警
    fi
}

# 检查所有证书
for cert in /etc/letsencrypt/live/*/fullchain.pem; do
    check_cert_expiry "$cert"
    echo "---"
done
```

### 自动续期监控

```bash
#!/bin/bash

# 测试续期
if sudo certbot renew --dry-run; then
    echo "证书续期测试成功"
else
    echo "证书续期测试失败"
    # 发送告警
fi
```

## 故障排除

### 常见问题

1. **证书无法验证**
   ```bash
   # 检查证书链
   openssl verify -CAfile /etc/letsencrypt/live/your-domain.com/chain.pem /etc/letsencrypt/live/your-domain.com/cert.pem
   
   # 检查证书
   openssl x509 -in /etc/letsencrypt/live/your-domain.com/cert.pem -text -noout
   ```

2. **TLS握手失败**
   ```bash
   # 测试TLS连接
   openssl s_client -connect your-domain.com:443 -servername your-domain.com
   
   # 检查TLS版本
   openssl s_client -connect your-domain.com:443 -tls1_2
   ```

3. **证书过期**
   ```bash
   # 手动更新证书
   sudo certbot renew --force-renewal
   
   # 重启服务
   sudo systemctl restart nginx
   ```

### 日志查看

```bash
# 查看Nginx错误日志
sudo tail -f /var/log/nginx/error.log

# 查看Certbot日志
sudo tail -f /var/log/letsencrypt/letsencrypt.log

# 查看系统日志
sudo journalctl -u nginx -f
```

## 最佳实践

1. **使用Let's Encrypt**：免费、自动续期
2. **启用HSTS**：防止降级攻击
3. **使用强密码套件**：禁用弱加密算法
4. **定期更新证书**：确保证书有效
5. **监控证书过期**：提前告警
6. **备份证书**：定期备份证书文件
7. **测试配置**：修改后测试TLS连接
8. **文档记录**：记录证书配置