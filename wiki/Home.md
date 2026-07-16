# VPN 服务端部署指南

欢迎使用VPN服务端部署指南！本项目提供全面的VPN服务端部署教程，帮助您快速搭建安全可靠的VPN服务。

## 目录

### 入门指南
- [[项目概述]]
- [[环境要求]]
- [[快速开始]]

### VPN协议部署
- [[WireGuard部署]]
- [[OpenVPN部署]]
- [[Shadowsocks部署]]
- [[V2Ray部署]]

### 部署方式
- [[Docker部署]]
- [[手动安装]]
- [[云平台部署]]

### 订阅链接配置
- [[订阅链接概述]]
- [[订阅链接生成]]
- [[客户端配置]]

### 安全配置
- [[防火墙配置]]
- [[TLS证书配置]]
- [[安全加固]]

### 故障排除
- [[常见问题]]
- [[日志分析]]

## 选择建议

**新手推荐**：从[[快速开始]]入手，使用Docker一键部署WireGuard。

**生产环境**：参考[[安全加固]]和[[TLS证书配置]]。

**多用户场景**：了解[[订阅链接概述]]以便为不同用户生成配置。

## 技术栈

- VPN协议：WireGuard、OpenVPN、Shadowsocks、V2Ray/Xray
- 部署工具：Docker、Docker Compose
- 系统要求：Linux (Ubuntu/Debian/CentOS)
- 客户端支持：Windows、macOS、iOS、Android

## 快速开始

### WireGuard Docker部署

```bash
# 创建配置目录
mkdir -p ~/wireguard && cd ~/wireguard

# 创建docker-compose.yml
cat > docker-compose.yml << EOF
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
    volumes:
      - ./config:/config
      - /lib/modules:/lib/modules
    ports:
      - 51820:51820/udp
    sysctls:
      - net.ipv4.conf.all.src_valid_mark=1
    restart: unless-stopped
EOF

# 启动服务
sudo docker-compose up -d

# 查看客户端配置
sudo docker logs wireguard
```

### 客户端配置

1. 下载WireGuard客户端
2. 导入配置文件或扫描二维码
3. 连接VPN

## 相关资源

- [WireGuard官方文档](https://www.wireguard.com/)
- [OpenVPN官方文档](https://openvpn.net/)
- [V2Ray官方文档](https://www.v2fly.org/)
- [Shadowsocks文档](https://shadowsocks.org/)