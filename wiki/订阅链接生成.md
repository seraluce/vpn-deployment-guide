# 订阅链接生成指南

本指南介绍如何为不同VPN协议生成订阅链接。

## 生成方式

### 方式一：使用现有工具

#### V2Ray订阅生成

1. **安装V2Ray**

```bash
# 下载安装脚本
bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh)
```

2. **创建订阅生成脚本**

```bash
mkdir -p ~/v2ray-sub
cd ~/v2ray-sub

# 创建订阅生成脚本
cat > generate-subscription.sh << 'EOF'
#!/bin/bash

# 配置信息
SERVER_IP="your-server-ip"
SERVER_PORT="443"
UUID=$(cat /proc/sys/kernel/random/uuid)
PATH="/your-path"

# 生成VMess链接
generate_vmess_link() {
    local config=$(cat << EOF
{
    "v": "2",
    "ps": "V2Ray-Server",
    "add": "${SERVER_IP}",
    "port": "${SERVER_PORT}",
    "id": "${UUID}",
    "aid": "0",
    "scy": "auto",
    "net": "ws",
    "type": "none",
    "host": "",
    "path": "${PATH}",
    "tls": "tls",
    "sni": "",
    "alpn": ""
}
EOF
)
    
    echo -n "$config" | base64 -w0
}

# 生成链接
VMESS_LINK="vmess://$(generate_vmess_link)"

# 输出配置
echo "VMess配置链接："
echo "$VMESS_LINK"
echo ""
echo "UUID: $UUID"
EOF

# 添加执行权限
chmod +x generate-subscription.sh
```

3. **生成订阅链接**

```bash
./generate-subscription.sh
```

#### Shadowsocks订阅生成

```bash
#!/bin/bash

# 配置信息
SERVER_IP="your-server-ip"
SERVER_PORT="8388"
PASSWORD="your-password"
METHOD="aes-256-gcm"

# 生成SS链接
generate_ss_link() {
    local config="${METHOD}:${PASSWORD}@${SERVER_IP}:${SERVER_PORT}"
    local encoded=$(echo -n "$config" | base64 -w0)
    echo "ss://${encoded}"
}

# 生成链接
SS_LINK=$(generate_ss_link)

# 输出配置
echo "Shadowsocks配置链接："
echo "$SS_LINK"
```

### 方式二：使用订阅面板

#### SSPanel-UIM

1. **安装SSPanel**

```bash
# 下载SSPanel
git clone https://github.com/SSPanel-Network/SSPanel-Uim.git
cd SSPanel-Uim

# 安装依赖
composer install

# 配置数据库
cp .env.example .env
nano .env

# 运行安装
php artisan panel:install
```

2. **配置VPN服务端**

```bash
# 安装Shadowsocks后端
git clone https://github.com/shadowsocks/shadowsocks.git
cd shadowsocks

# 编译安装
./configure && make && sudo make install
```

3. **访问面板**

```
http://your-server-ip
```

#### V2Ray面板

1. **安装V2Ray面板**

```bash
# 下载面板
git clone https://github.com/funcgo/v2ray-panel.git
cd v2ray-panel

# 安装依赖
npm install

# 配置
cp config.example.js config.js
nano config.js

# 启动面板
npm start
```

2. **访问面板**

```
http://your-server-ip:3000
```

### 方式三：自建订阅服务器

#### Python订阅服务器

1. **安装依赖**

```bash
pip install flask
```

2. **创建订阅服务器**

```python
from flask import Flask, request, jsonify
import json
import base64

app = Flask(__name__)

# 用户配置
users = {
    "user1": {
        "server": "your-server-ip",
        "port": 443,
        "uuid": "your-uuid",
        "path": "/your-path"
    }
}

@app.route('/subscribe/<user_id>')
def subscribe(user_id):
    if user_id not in users:
        return "User not found", 404
    
    user = users[user_id]
    
    # 生成V2Ray配置
    config = {
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
                            "address": user["server"],
                            "port": user["port"],
                            "users": [
                                {
                                    "id": user["uuid"],
                                    "alterId": 0
                                }
                            ]
                        }
                    ]
                },
                "streamSettings": {
                    "network": "ws",
                    "security": "tls",
                    "wsSettings": {
                        "path": user["path"]
                    }
                }
            }
        ]
    }
    
    # 返回配置
    return jsonify(config)

@app.route('/subscribe/base64/<user_id>')
def subscribe_base64(user_id):
    if user_id not in users:
        return "User not found", 404
    
    user = users[user_id]
    
    # 生成VMess链接
    vmess_config = {
        "v": "2",
        "ps": f"V2Ray-{user_id}",
        "add": user["server"],
        "port": user["port"],
        "id": user["uuid"],
        "aid": "0",
        "scy": "auto",
        "net": "ws",
        "type": "none",
        "host": "",
        "path": user["path"],
        "tls": "tls",
        "sni": "",
        "alpn": ""
    }
    
    # 编码
    encoded = base64.b64encode(json.dumps(vmess_config).encode()).decode()
    link = f"vmess://{encoded}"
    
    return link

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
```

3. **启动订阅服务器**

```bash
python app.py
```

4. **访问订阅链接**

```
http://your-server-ip:8080/subscribe/user1
http://your-server-ip:8080/subscribe/base64/user1
```

## 订阅链接格式

### V2Ray VMess格式

```
vmess://base64(config)
```

配置内容：
```json
{
    "v": "2",
    "ps": "备注",
    "add": "服务器地址",
    "port": "端口",
    "id": "UUID",
    "aid": "AlterID",
    "scy": "加密方式",
    "net": "传输协议",
    "type": "类型",
    "host": "伪装域名",
    "path": "路径",
    "tls": "TLS",
    "sni": "SNI",
    "alpn": "ALPN"
}
```

### V2Ray VLESS格式

```
vless://uuid@server:port?encryption=none&flow=xtls-rprx-vision&security=reality&sni=www.microsoft.com&fp=chrome&pbk=public_key&sid=short_id&type=tcp&headerType=none#备注
```

### Shadowsocks格式

```
ss://base64(method:password@server:port)#备注
```

### ShadowsocksR格式

```
ssr://base64(encoded)
```

编码内容：
```
server:port:protocol:method:obfs:base64pass/?params=base64
```

## 批量生成

### 使用脚本批量生成

```bash
#!/bin/bash

# 用户列表
USERS=("user1" "user2" "user3")

# 服务器信息
SERVER_IP="your-server-ip"
SERVER_PORT="443"
PATH="/your-path"

# 为每个用户生成配置
for user in "${USERS[@]}"; do
    # 生成UUID
    UUID=$(cat /proc/sys/kernel/random/uuid)
    
    # 生成VMess链接
    CONFIG=$(cat << EOF
{
    "v": "2",
    "ps": "${user}",
    "add": "${SERVER_IP}",
    "port": "${SERVER_PORT}",
    "id": "${UUID}",
    "aid": "0",
    "scy": "auto",
    "net": "ws",
    "type": "none",
    "host": "",
    "path": "${PATH}",
    "tls": "tls",
    "sni": "",
    "alpn": ""
}
EOF
)
    
    ENCODED=$(echo -n "$CONFIG" | base64 -w0)
    LINK="vmess://${ENCODED}"
    
    echo "用户: ${user}"
    echo "UUID: ${UUID}"
    echo "链接: ${LINK}"
    echo "---"
done
```

### 使用数据库管理

```sql
-- 创建用户表
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL,
    uuid VARCHAR(36) NOT NULL,
    server_ip VARCHAR(45) NOT NULL,
    port INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 插入用户
INSERT INTO users (username, uuid, server_ip, port) 
VALUES ('user1', 'your-uuid', 'your-server-ip', 443);
```

## 安全配置

### HTTPS配置

```nginx
server {
    listen 443 ssl;
    server_name subscription.your-domain.com;

    ssl_certificate /etc/letsencrypt/live/subscription.your-domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/subscription.your-domain.com/privkey.pem;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### Token验证

```python
from flask import Flask, request, abort
import hashlib
import time

app = Flask(__name__)

# Token密钥
SECRET_KEY = "your-secret-key"

def generate_token(user_id, expiry):
    """生成Token"""
    data = f"{user_id}:{expiry}"
    return hashlib.sha256(f"{data}:{SECRET_KEY}".encode()).hexdigest()

def verify_token(user_id, token, expiry):
    """验证Token"""
    if time.time() > expiry:
        return False
    expected = generate_token(user_id, expiry)
    return token == expected

@app.route('/subscribe/<user_id>')
def subscribe(user_id):
    token = request.args.get('token')
    expiry = request.args.get('expiry', type=int)
    
    if not token or not expiry:
        return "Missing parameters", 400
    
    if not verify_token(user_id, token, expiry):
        return "Invalid token", 403
    
    # 生成配置...
```

## 监控和日志

### 访问日志

```python
import logging
from flask import request

# 配置日志
logging.basicConfig(
    filename='subscription.log',
    level=logging.INFO,
    format='%(asctime)s %(message)s'
)

@app.route('/subscribe/<user_id>')
def subscribe(user_id):
    # 记录访问
    logging.info(f"Access: user={user_id} ip={request.remote_addr} time={time.time()}")
    
    # 生成配置...
```

### 监控脚本

```bash
#!/bin/bash

# 监控订阅服务器
while true; do
    # 检查服务状态
    if ! curl -s http://localhost:8080/health > /dev/null; then
        echo "Subscription server is down"
        # 发送告警
        send_alert "Subscription server is down"
    fi
    
    # 检查日志
    tail -n 100 /var/log/subscription.log | grep -i error
    
    sleep 60
done
```

## 故障排除

### 常见问题

1. **订阅链接无法访问**
   ```bash
   # 检查服务状态
   systemctl status subscription-server
   
   # 检查端口
   netstat -tulpn | grep 8080
   
   # 检查防火墙
   ufw status
   ```

2. **配置格式错误**
   ```bash
   # 验证JSON
   python -m json.tool config.json
   
   # 验证Base64
   echo "base64string" | base64 -d
   ```

3. **客户端无法导入**
   ```bash
   # 检查链接格式
   echo "$LINK" | base64 -d
   
   # 测试链接
   curl -v "$LINK"
   ```

### 日志查看

```bash
# 查看订阅服务器日志
tail -f /var/log/subscription.log

# 查看Nginx日志
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log
```

## 最佳实践

1. **使用HTTPS**：加密传输配置
2. **定期更新**：定期更新配置文件
3. **用户隔离**：不同用户使用不同配置
4. **监控日志**：记录所有访问请求
5. **备份数据**：定期备份用户数据
6. **安全检查**：定期进行安全检查
7. **性能优化**：使用CDN和缓存
8. **文档记录**：记录所有配置和操作