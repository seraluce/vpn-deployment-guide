# VPN 服务端部署指南

全面的VPN服务端部署教程，涵盖多种协议和部署方式，以及订阅链接配置。

## 项目内容

本项目提供详细的VPN服务端部署文档，包括：

- **VPN协议介绍**：WireGuard、OpenVPN、Shadowsocks、V2Ray/Xray等
- **部署方式**：Docker容器化部署、手动安装、云平台一键部署
- **订阅链接**：为客户端生成配置订阅链接，支持多种客户端
- **安全配置**：防火墙设置、TLS证书配置、安全优化
- **故障排除**：常见问题解答和排查指南

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
│   ├── tls.md                 # TLS证书
│   └── hardening.md           # 安全加固
└── troubleshooting/
    ├── common-issues.md       # 常见问题
    └── logs.md                # 日志分析
```

## 快速导航

- [快速开始](docs/guide/quick-start.md)
- [WireGuard部署](docs/protocols/wireguard.md)
- [订阅链接配置](docs/subscription/overview.md)
- [Docker部署](docs/deployment/docker.md)

## 贡献

欢迎提交Issue和Pull Request来完善文档。

## 许可证

MIT License