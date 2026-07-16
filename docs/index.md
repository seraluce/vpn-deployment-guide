---
layout: home

hero:
  name: "VPN 服务端部署指南"
  text: "全面的VPN部署教程"
  tagline: 覆盖多种VPN协议和部署方式，帮助您快速搭建安全可靠的VPN服务
  actions:
    - theme: brand
      text: 快速开始
      link: /guide/quick-start
    - theme: alt
      text: GitHub
      link: https://github.com/seraluce/vpn-deployment-guide

features:
  - icon: 🛡️
    title: 多协议支持
    details: 支持 WireGuard、OpenVPN、Shadowsocks、V2Ray/Xray 等主流VPN协议
  - icon: 🐳
    title: Docker部署
    details: 容器化部署，一键启动，易于管理和扩展
  - icon: ☁️
    title: 云平台支持
    details: 支持 AWS、阿里云、腾讯云、Google Cloud 等主流云平台
  - icon: 🔗
    title: 订阅链接
    details: 自动生成客户端配置订阅链接，支持多用户管理
  - icon: 🔒
    title: 安全配置
    details: 防火墙、TLS证书、安全加固，全方位保护您的VPN服务
  - icon: 📖
    title: 详细文档
    details: 从入门到进阶，提供完整的部署指南和故障排除
---

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
```

## 文档导航

<div class="cards">

<div class="card">

### 入门指南

- [项目概述](guide/overview)
- [环境要求](guide/requirements)
- [快速开始](guide/quick-start)

</div>

<div class="card">

### VPN协议

- [WireGuard](protocols/wireguard)
- [OpenVPN](protocols/openvpn)
- [Shadowsocks](protocols/shadowsocks)
- [V2Ray/Xray](protocols/v2ray)

</div>

<div class="card">

### 部署方式

- [Docker部署](deployment/docker)
- [手动安装](deployment/manual)
- [云平台部署](deployment/cloud)

</div>

<div class="card">

### 高级配置

- [订阅链接](subscription/overview)
- [安全配置](security/firewall)
- [故障排除](troubleshooting/common-issues)

</div>

</div>
