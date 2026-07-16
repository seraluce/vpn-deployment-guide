# VPN 服务端部署指南

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Deploy VitePress](https://github.com/seraluce/vpn-deployment-guide/actions/workflows/deploy.yml/badge.svg)](https://github.com/seraluce/vpn-deployment-guide/actions/workflows/deploy.yml)

全面的VPN服务端部署教程，涵盖多种协议和部署方式，以及订阅链接配置。

## 在线文档

**[查看在线文档](https://seraluce.github.io/vpn-deployment-guide/)**

## 项目简介

本项目提供详细的VPN服务端部署文档，帮助您快速搭建安全、稳定的VPN服务。

### 特性

- **多协议支持**：WireGuard、OpenVPN、Shadowsocks、V2Ray/Xray
- **多种部署方式**：Docker容器化、手动安装、云平台一键部署
- **订阅链接管理**：为客户端生成配置订阅链接，支持多用户管理
- **安全配置**：防火墙设置、TLS证书配置、安全加固
- **故障排除**：常见问题解答和排查指南

## 快速开始

### 推荐方式：WireGuard + Docker

```bash
# 1. 创建配置目录
mkdir -p ~/wireguard && cd ~/wireguard

# 2. 创建docker-compose.yml
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

# 3. 启动服务
sudo docker-compose up -d

# 4. 查看客户端配置
sudo docker logs wireguard
```

## 文档结构

```
docs/
├── index.md                    # 文档首页
├── guide/
│   ├── overview.md            # 项目概述
│   ├── requirements.md        # 环境要求
│   └── quick-start.md         # 快速开始
├── protocols/
│   ├── wireguard.md           # WireGuard部署
│   ├── openvpn.md             # OpenVPN部署
│   ├── shadowsocks.md         # Shadowsocks部署
│   └── v2ray.md               # V2Ray/Xray部署
├── deployment/
│   ├── docker.md              # Docker部署
│   ├── manual.md              # 手动安装
│   └── cloud.md               # 云平台部署
├── subscription/
│   ├── overview.md            # 订阅链接概述
│   ├── generation.md          # 订阅链接生成
│   └── client-config.md       # 客户端配置
├── security/
│   ├── firewall.md            # 防火墙配置
│   ├── tls.md                 # TLS证书配置
│   └── hardening.md           # 安全加固
└── troubleshooting/
    ├── common-issues.md       # 常见问题
    └── logs.md                # 日志分析
```

## 本地开发

### 安装依赖

```bash
npm install
```

### 启动开发服务器

```bash
npm run dev
```

### 构建生产版本

```bash
npm run build
```

### 预览构建结果

```bash
npm run preview
```

## 部署到GitHub Pages

项目已配置GitHub Actions自动部署。推送到`main`分支后会自动构建并部署到GitHub Pages。

### 手动部署

```bash
# 构建
npm run build

# 部署到GitHub Pages
# 将 docs/.vitepress/dist 目录内容推送到 gh-pages 分支
```

## 支持的协议

| 协议 | 特点 | 适用场景 | 性能 |
|------|------|----------|------|
| WireGuard | 高性能、简单配置 | 现代VPN首选 | ⭐⭐⭐⭐⭐ |
| OpenVPN | 成熟稳定、兼容性好 | 企业环境 | ⭐⭐⭐⭐ |
| Shadowsocks | 轻量级、抗封锁 | 网络受限环境 | ⭐⭐⭐⭐ |
| V2Ray/Xray | 功能丰富、协议多样 | 复杂网络环境 | ⭐⭐⭐⭐ |

## 客户端支持

- **Windows**：Clash for Windows、v2rayN、Shadowsocks-windows
- **macOS**：ClashX、Surge、Quantumult X
- **iOS**：Shadowrocket、Quantumult X、Surge
- **Android**：Clash for Android、V2RayNG、Shadowsocks Android
- **Linux**：Clash、V2Ray、Shadowsocks

## 贡献

欢迎提交Issue和Pull Request来完善文档。

## 许可证

MIT License

## 相关资源

- [WireGuard官方文档](https://www.wireguard.com/)
- [OpenVPN官方文档](https://openvpn.net/)
- [V2Ray官方文档](https://www.v2fly.org/)
- [Shadowsocks文档](https://shadowsocks.org/)