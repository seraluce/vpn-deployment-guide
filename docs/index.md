# VPN 服务端部署指南

欢迎使用VPN服务端部署指南！本项目提供全面的VPN服务端部署教程，帮助您快速搭建安全可靠的VPN服务。

## 目录

### 入门指南
- [项目概述](guide/overview.md)
- [环境要求](guide/requirements.md)
- [快速开始](guide/quick-start.md)

### VPN协议部署
- [WireGuard](protocols/wireguard.md)
- [OpenVPN](protocols/openvpn.md)
- [Shadowsocks](protocols/shadowsocks.md)
- [V2Ray/Xray](protocols/v2ray.md)

### 部署方式
- [Docker部署](deployment/docker.md)
- [手动安装](deployment/manual.md)
- [云平台部署](deployment/cloud.md)

### 订阅链接配置
- [订阅链接概述](subscription/overview.md)
- [订阅链接生成](subscription/generation.md)
- [客户端配置](subscription/client-config.md)

### 安全配置
- [防火墙配置](security/firewall.md)
- [TLS证书配置](security/tls.md)
- [安全加固](security/hardening.md)

### 故障排除
- [常见问题](troubleshooting/common-issues.md)
- [日志分析](troubleshooting/logs.md)

## 选择建议

**新手推荐**：从[快速开始](guide/quick-start.md)入手，使用Docker一键部署WireGuard。

**生产环境**：参考[安全加固](security/hardening.md)和[TLS证书配置](security/tls.md)。

**多用户场景**：了解[订阅链接配置](subscription/overview.md)以便为不同用户生成配置。

## 技术栈

- VPN协议：WireGuard、OpenVPN、Shadowsocks、V2Ray/Xray
- 部署工具：Docker、Docker Compose
- 系统要求：Linux (Ubuntu/Debian/CentOS)
- 客户端支持：Windows、macOS、iOS、Android