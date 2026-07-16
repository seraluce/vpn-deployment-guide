# 环境要求

## 硬件要求

### 最低配置
- **CPU**：1核
- **内存**：1GB RAM
- **硬盘**：10GB SSD
- **网络**：100Mbps带宽

### 推荐配置
- **CPU**：2核以上
- **内存**：2GB RAM以上
- **硬盘**：20GB SSD以上
- **网络**：1Gbps带宽

## 软件要求

### 操作系统

支持以下Linux发行版：

| 发行版 | 版本要求 | 说明 |
|--------|----------|------|
| Ubuntu | 20.04 LTS或更高 | 推荐使用 |
| Debian | 10 (Buster)或更高 | 稳定版本 |
| CentOS | 7或更高 | 企业级选择 |
| Rocky Linux | 8或更高 | CentOS替代品 |
| Amazon Linux | 2 | AWS环境 |

### 必需软件

```bash
# 基础工具
curl
wget
git
vim/nano

# 编译工具（手动安装时需要）
build-essential
gcc
make

# 网络工具
net-tools
iproute2
iptables
```

### Docker环境（可选）

如果选择Docker部署，需要安装：

```bash
# Docker Engine
docker-ce
docker-ce-cli
containerd.io

# Docker Compose
docker-compose
```

## 网络要求

### 端口开放

根据选择的VPN协议，需要开放以下端口：

| 协议 | 默认端口 | 协议类型 |
|------|----------|----------|
| WireGuard | 51820 | UDP |
| OpenVPN | 1194 | UDP |
| Shadowsocks | 8388 | TCP/UDP |
| V2Ray | 443 | TCP |

### 防火墙配置

```bash
# Ubuntu/Debian
sudo ufw allow 51820/udp
sudo ufw allow 1194/udp
sudo ufw allow 8388/tcp
sudo ufw allow 8388/udp
sudo ufw allow 443/tcp

# CentOS/RHEL
sudo firewall-cmd --permanent --add-port=51820/udp
sudo firewall-cmd --permanent --add-port=1194/udp
sudo firewall-cmd --permanent --add-port=8388/tcp
sudo firewall-cmd --permanent --add-port=8388/udp
sudo firewall-cmd --permanent --add-port=443/tcp
sudo firewall-cmd --reload
```

### 域名和SSL证书（可选但推荐）

- 域名：用于访问订阅链接和配置服务
- SSL证书：Let's Encrypt免费证书或自签名证书

## 云平台要求

### 主流云服务商

| 云服务商 | 推荐实例类型 | 说明 |
|----------|--------------|------|
| AWS | t3.micro | 免费套餐可用 |
| Google Cloud | e2-micro | 免费套餐可用 |
| Azure | B1s | 免费套餐可用 |
| DigitalOcean | Basic Droplet | $5/月起 |
| Vultr | Cloud Compute | $2.5/月起 |
| 阿里云 | ecs.t6-c1m1.large | 按量付费 |

### 云平台配置

1. **安全组设置**：开放所需端口
2. **弹性IP**：分配固定公网IP
3. **VPC配置**：确保网络连通性
4. **监控告警**：设置资源监控

## 开发环境（可选）

如果需要修改或测试配置：

```bash
# Node.js (用于订阅链接生成)
node >= 14.x
npm >= 6.x

# Python (用于辅助脚本)
python >= 3.6
pip >= 20.x

# Go (用于V2Ray插件)
go >= 1.16
```

## 验证环境

运行以下命令验证环境是否满足要求：

```bash
# 检查系统信息
uname -a
lsb_release -a

# 检查网络连接
ping -c 4 google.com
curl -I https://github.com

# 检查端口占用
sudo netstat -tulpn | grep -E ':(51820|1194|8388|443)'

# 检查Docker（如果使用）
docker --version
docker-compose --version
```

## 常见问题

### Q: 云服务器无法连接？
A: 检查安全组是否开放了相应端口，确认服务器有公网IP。

### Q: 端口被占用？
A: 使用 `sudo lsof -i :端口号` 查看占用进程，修改VPN服务端口。

### Q: 防火墙配置不生效？
A: 检查防火墙状态，确认规则已添加，可能需要重启防火墙服务。

### Q: 系统版本不支持？
A: 建议升级到推荐版本，或使用Docker部署以避免兼容性问题。