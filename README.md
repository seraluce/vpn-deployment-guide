# VPN 服务端部署指南

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

全面的VPN服务端部署教程，涵盖多种协议和部署方式，以及订阅链接配置。

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

### Wiki文档

完整的文档已部署在项目的Wiki中，包括：

- **入门指南**：项目概述、环境要求、快速开始
- **VPN协议部署**：WireGuard、OpenVPN、Shadowsocks、V2Ray/Xray
- **部署方式**：Docker部署、手动安装、云平台部署
- **订阅链接配置**：订阅链接概述、生成、客户端配置
- **安全配置**：防火墙配置、TLS证书、安全加固
- **故障排除**：常见问题、日志分析

### 文档目录

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
│   ├── tls.md                 # TLS证书
│   └── hardening.md           # 安全加固
└── troubleshooting/
    ├── common-issues.md       # 常见问题
    └── logs.md                # 日志分析
```

## 支持的协议

| 协议 | 特点 | 适用场景 | 性能 |
|------|------|----------|------|
| WireGuard | 高性能、简单配置 | 现代VPN首选 | ⭐⭐⭐⭐⭐ |
| OpenVPN | 成熟稳定、兼容性好 | 企业环境 | ⭐⭐⭐⭐ |
| Shadowsocks | 轻量级、抗封锁 | 网络受限环境 | ⭐⭐⭐⭐ |
| V2Ray/Xray | 功能丰富、协议多样 | 复杂网络环境 | ⭐⭐⭐⭐ |

## 部署方式

### Docker部署（推荐）

```bash
# 一键部署WireGuard
bash <(curl -L https://raw.githubusercontent.com/angristan/wireguard-install/master/wireguard-install.sh)
```

### 手动安装

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install wireguard -y
```

### 云平台部署

支持AWS、Google Cloud、Azure、阿里云、腾讯云等主流云平台。

## 客户端支持

- **Windows**：Clash for Windows、v2rayN、Shadowsocks-windows
- **macOS**：ClashX、Surge、Quantumult X
- **iOS**：Shadowrocket、Quantumult X、Surge
- **Android**：Clash for Android、V2RayNG、Shadowsocks Android
- **Linux**：Clash、V2Ray、Shadowsocks

## 订阅链接

订阅链接功能允许为VPN客户端生成配置文件，方便用户管理和分发配置。

```bash
# 生成VMess订阅链接
vmess://base64(config)

# 生成Shadowsocks订阅链接
ss://base64(method:password@server:port)
```

## 安全特性

- **加密算法**：AES-256-GCM、ChaCha20-Poly1305
- **TLS加密**：支持TLS 1.2/1.3
- **防火墙**：iptables、ufw、firewalld
- **访问控制**：IP白名单、Token验证

## 故障排除

### 常见问题

1. **无法连接VPN**
   - 检查防火墙是否开放端口
   - 检查服务是否正常运行
   - 检查客户端配置是否正确

2. **连接后无法上网**
   - 检查IP转发是否启用
   - 检查路由配置是否正确
   - 检查DNS设置

3. **速度慢**
   - 选择离用户近的服务器
   - 调整MTU值
   - 使用性能更好的加密算法

## Wiki文档

完整的文档已部署在GitHub Wiki中：[VPN部署指南Wiki](https://github.com/seraluce/vpn-deployment-guide/wiki)

### 部署Wiki到GitHub

```bash
# 克隆wiki仓库
git clone https://github.com/seraluce/vpn-deployment-guide.wiki.git

# 进入wiki目录
cd vpn-deployment-guide.wiki

# 复制文档
cp ../vpn-deployment-guide/wiki/* .

# 提交并推送
git add .
git commit -m "更新文档"
git push
```

### 自动部署

使用提供的脚本自动部署：

```bash
# 运行部署脚本
./deploy-wiki.sh
```

## 贡献

欢迎提交Issue和Pull Request来完善文档。

## 许可证

MIT License

## 相关资源

- [WireGuard官方文档](https://www.wireguard.com/)
- [OpenVPN官方文档](https://openvpn.net/)
- [V2Ray官方文档](https://www.v2fly.org/)
- [Shadowsocks文档](https://shadowsocks.org/)