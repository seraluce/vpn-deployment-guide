# 订阅链接概述

订阅链接功能允许为VPN客户端生成配置文件，方便用户管理和分发配置。

## 订阅链接简介

### 什么是订阅链接

订阅链接是一个URL，客户端可以通过它获取最新的VPN配置文件。用户只需导入一次订阅链接，客户端会自动更新配置。

### 工作原理

```
用户 → 订阅链接 → 服务器 → 生成配置 → 客户端
```

1. 用户在客户端添加订阅链接
2. 客户端定期请求订阅链接
3. 服务器返回最新的配置文件
4. 客户端自动更新配置

### 优势

- **易于管理**：服务器端统一管理配置
- **自动更新**：客户端自动获取最新配置
- **多用户支持**：为不同用户生成不同配置
- **安全可控**：可以随时撤销用户访问权限

## 支持的协议

| 协议 | 订阅格式 | 说明 |
|------|----------|------|
| Shadowsocks | SS链接 | `ss://base64encoded` |
| ShadowsocksR | SSR链接 | `ssr://base64encoded` |
| V2Ray | VMess链接 | `vmess://base64encoded` |
| V2Ray | VLESS链接 | `vless://uuid@server:port` |
| Trojan | Trojan链接 | `trojan://password@server:port` |

## 客户端支持

### Windows

- **Clash for Windows**：支持SS/SSR/V2Ray/Trojan
- **v2rayN**：支持V2Ray/Trojan
- **Shadowsocks-windows**：支持SS

### macOS

- **ClashX**：支持SS/SSR/V2Ray/Trojan
- **Surge**：支持多种协议
- **Quantumult X**：支持多种协议

### iOS

- **Shadowrocket**：支持多种协议
- **Quantumult X**：支持多种协议
- **Surge**：支持多种协议

### Android

- **Clash for Android**：支持SS/SSR/V2Ray/Trojan
- **V2RayNG**：支持V2Ray/Trojan
- **Shadowsocks Android**：支持SS

## 部署架构

### 简单架构

```
订阅服务器 ←→ VPN服务端
     ↓
   客户端
```

### 复杂架构

```
负载均衡 ←→ 订阅服务器集群
                ↓
           数据库 ←→ VPN服务端集群
                ↓
             客户端
```

## 配置文件格式

### Shadowsocks配置

```json
{
    "server": "your-server-ip",
    "server_port": 8388,
    "password": "your-password",
    "method": "aes-256-gcm",
    "timeout": 300
}
```

### V2Ray配置

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
            },
            "streamSettings": {
                "network": "ws",
                "security": "tls"
            }
        }
    ]
}
```

### Clash配置

```yaml
mixed-port: 7890
allow-lan: false
mode: rule
log-level: info

proxies:
  - name: "SS-Proxy"
    type: ss
    server: your-server-ip
    port: 8388
    cipher: aes-256-gcm
    password: your-password

  - name: "V2Ray-Proxy"
    type: vmess
    server: your-server-ip
    port: 443
    uuid: your-uuid
    alterId: 0
    cipher: auto
    tls: true
    network: ws

rules:
  - MATCH,DIRECT
```

## 安全考虑

### 访问控制

1. **IP白名单**：只允许特定IP访问订阅链接
2. **Token验证**：使用随机Token验证用户身份
3. **过期时间**：设置配置文件过期时间
4. **用户隔离**：不同用户使用不同配置

### 数据加密

1. **HTTPS**：使用HTTPS加密传输
2. **配置加密**：加密配置文件内容
3. **密钥管理**：安全存储密钥

### 监控审计

1. **访问日志**：记录所有访问请求
2. **异常检测**：检测异常访问模式
3. **告警通知**：异常时发送告警

## 性能优化

### 缓存策略

1. **CDN缓存**：使用CDN加速订阅链接
2. **本地缓存**：客户端本地缓存配置
3. **服务器缓存**：服务器端缓存配置文件

### 负载均衡

1. **多实例部署**：部署多个订阅服务器
2. **DNS轮询**：使用DNS轮询分发请求
3. **反向代理**：使用Nginx反向代理

## 监控和维护

### 监控指标

1. **请求量**：订阅链接的请求次数
2. **响应时间**：服务器响应时间
3. **错误率**：请求错误比例
4. **用户活跃度**：活跃用户数量

### 维护任务

1. **定期更新**：更新配置文件
2. **清理过期配置**：删除过期配置
3. **备份数据**：定期备份用户数据
4. **安全检查**：定期进行安全检查

## 常见问题

### Q: 订阅链接无法访问？
A: 检查以下项目：
- 服务器是否正常运行
- 防火墙是否开放相关端口
- 域名解析是否正确
- SSL证书是否有效

### Q: 配置更新不及时？
A: 检查以下项目：
- 客户端更新间隔设置
- 服务器缓存配置
- 网络连接状态

### Q: 多用户配置混乱？
A: 检查以下项目：
- 用户ID是否唯一
- 配置文件是否正确生成
- 订阅链接是否正确分发

## 下一步

- [订阅链接生成](generation)：如何生成订阅链接
- [客户端配置](client-config)：如何配置客户端
- [高级配置](../security/tls)：HTTPS和安全配置