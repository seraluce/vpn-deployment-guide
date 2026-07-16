# Docker 部署指南

使用Docker可以快速、一致地部署VPN服务，避免环境依赖问题。

## Docker 简介

### 优势

- **环境隔离**：每个服务运行在独立容器中
- **易于管理**：使用Docker Compose管理多容器应用
- **快速部署**：一键启动所有服务
- **易于更新**：更新镜像即可升级服务
- **资源控制**：可以限制CPU、内存等资源

### 安装Docker

#### Ubuntu/Debian

```bash
# 更新系统
sudo apt update

# 安装依赖
sudo apt install apt-transport-https ca-certificates curl gnupg-agent software-properties-common

# 添加Docker官方GPG密钥
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# 添加Docker仓库
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# 安装Docker
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io

# 启动Docker
sudo systemctl start docker
sudo systemctl enable docker
```

#### CentOS/RHEL

```bash
# 安装依赖
sudo yum install -y yum-utils device-mapper-persistent-data lvm2

# 添加Docker仓库
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# 安装Docker
sudo yum install docker-ce docker-ce-cli containerd.io

# 启动Docker
sudo systemctl start docker
sudo systemctl enable docker
```

### 安装Docker Compose

```bash
# 下载Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# 添加执行权限
sudo chmod +x /usr/local/bin/docker-compose

# 验证安装
docker-compose --version
```

## Docker Compose 配置

### 基本结构

```yaml
version: '3.8'

services:
  vpn-service:
    image: image-name
    container_name: container-name
    environment:
      - ENV_VAR=value
    volumes:
      - ./local-path:/container-path
    ports:
      - "host-port:container-port"
    restart: unless-stopped
```

### 常用配置项

```yaml
services:
  vpn-service:
    image: image-name
    container_name: container-name
    # 环境变量
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Asia/Shanghai
    # 数据卷
    volumes:
      - ./config:/config
      - /lib/modules:/lib/modules
    # 端口映射
    ports:
      - "51820:51820/udp"
      - "1194:1194/udp"
    # 网络配置
    networks:
      - vpn-network
    # 权限配置
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    # 系统参数
    sysctls:
      - net.ipv4.conf.all.src_valid_mark=1
    # 重启策略
    restart: unless-stopped
    # 依赖关系
    depends_on:
      - other-service
    # 日志配置
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

## VPN服务部署

### WireGuard Docker部署

```yaml
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
      - PEERDNS=auto
      - INTERNAL_SUBNET=10.13.13.0
    volumes:
      - ./config:/config
      - /lib/modules:/lib/modules
    ports:
      - 51820:51820/udp
    sysctls:
      - net.ipv4.conf.all.src_valid_mark=1
    restart: unless-stopped
```

### OpenVPN Docker部署

```yaml
version: '3.8'

services:
  openvpn:
    image: kylemanna/openvpn
    container_name: openvpn
    cap_add:
      - NET_ADMIN
    environment:
      - OVPN_DATA=/etc/openvpn
      - OVPN_CN=your-server-ip
      - OVPN_PORT=1194
    volumes:
      - ./data:/etc/openvpn
    ports:
      - 1194:1194/udp
    restart: unless-stopped
```

### Shadowsocks Docker部署

```yaml
version: '3.8'

services:
  shadowsocks:
    image: shadowsocks/shadowsocks-libev
    container_name: shadowsocks
    environment:
      - SERVER_PORT=8388
      - PASSWORD=your-password
      - METHOD=aes-256-gcm
      - TIMEOUT=300
    ports:
      - 8388:8388/tcp
      - 8388:8388/udp
    restart: unless-stopped
```

### V2Ray Docker部署

```yaml
version: '3.8'

services:
  v2ray:
    image: v2fly/v2ray-core
    container_name: v2ray
    volumes:
      - ./config.json:/etc/v2ray/config.json
    ports:
      - "443:443"
      - "443:443/udp"
    restart: unless-stopped
```

## 多服务部署

### 完整VPN解决方案

```yaml
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
      - PEERS=5
    volumes:
      - ./wireguard/config:/config
      - /lib/modules:/lib/modules
    ports:
      - 51820:51820/udp
    sysctls:
      - net.ipv4.conf.all.src_valid_mark=1
    restart: unless-stopped

  openvpn:
    image: kylemanna/openvpn
    container_name: openvpn
    cap_add:
      - NET_ADMIN
    environment:
      - OVPN_DATA=/etc/openvpn
      - OVPN_CN=your-server-ip
    volumes:
      - ./openvpn/data:/etc/openvpn
    ports:
      - 1194:1194/udp
    restart: unless-stopped

  shadowsocks:
    image: shadowsocks/shadowsocks-libev
    container_name: shadowsocks
    environment:
      - SERVER_PORT=8388
      - PASSWORD=your-password
      - METHOD=aes-256-gcm
    ports:
      - 8388:8388/tcp
      - 8388:8388/udp
    restart: unless-stopped

  nginx:
    image: nginx:alpine
    container_name: nginx
    volumes:
      - ./nginx/conf.d:/etc/nginx/conf.d
      - ./nginx/ssl:/etc/nginx/ssl
    ports:
      - "80:80"
      - "443:443"
    restart: unless-stopped
    depends_on:
      - v2ray
```

## 网络配置

### 创建自定义网络

```bash
# 创建网络
docker network create vpn-network

# 查看网络
docker network ls

# 查看网络详情
docker network inspect vpn-network
```

### 使用自定义网络

```yaml
version: '3.8'

services:
  vpn-service:
    image: image-name
    networks:
      - vpn-network

networks:
  vpn-network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
```

### 端口映射

```yaml
# 基本端口映射
ports:
  - "51820:51820/udp"
  - "1194:1194/udp"

# 绑定特定IP
ports:
  - "127.0.0.1:51820:51820/udp"

# 范围端口
ports:
  - "51820-51830:51820-51830/udp"
```

## 数据管理

### 数据卷

```yaml
volumes:
  # 命名卷
  - vpn-data:/data
  
  # 绑定挂载
  - ./config:/config
  
  # 只读挂载
  - ./data:/data:ro
```

### 数据备份

```bash
# 备份数据卷
docker run --rm -v vpn-data:/data -v $(pwd):/backup alpine tar czf /backup/vpn-data.tar.gz /data

# 恢复数据卷
docker run --rm -v vpn-data:/data -v $(pwd):/backup alpine tar xzf /backup/vpn-data.tar.gz -C /
```

### 数据清理

```bash
# 停止所有容器
docker stop $(docker ps -aq)

# 删除所有容器
docker rm $(docker ps -aq)

# 删除所有镜像
docker rmi $(docker images -q)

# 删除所有数据卷
docker volume rm $(docker volume ls -q)
```

## 监控和日志

### 查看日志

```bash
# 查看容器日志
docker logs container-name

# 实时查看日志
docker logs -f container-name

# 查看最近100行日志
docker logs --tail 100 container-name
```

### 监控资源

```bash
# 查看容器资源使用
docker stats

# 查看特定容器
docker stats container-name
```

### 健康检查

```yaml
services:
  vpn-service:
    image: image-name
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

## 安全配置

### 限制容器权限

```yaml
services:
  vpn-service:
    image: image-name
    # 只读文件系统
    read_only: true
    # 临时文件系统
    tmpfs:
      - /tmp
    # 禁用权限提升
    security_opt:
      - no-new-privileges:true
```

### 网络隔离

```yaml
services:
  vpn-service:
    image: image-name
    networks:
      - vpn-network
    # 禁用网络
    # network_mode: none
```

### 资源限制

```yaml
services:
  vpn-service:
    image: image-name
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M
```

## 故障排除

### 常见问题

1. **容器无法启动**
   ```bash
   # 查看容器状态
   docker ps -a
   
   # 查看容器日志
   docker logs container-name
   ```

2. **网络连接问题**
   ```bash
   # 检查网络
   docker network ls
   docker network inspect vpn-network
   
   # 检查端口
   netstat -tulpn | grep :51820
   ```

3. **权限问题**
   ```bash
   # 检查文件权限
   ls -la ./config
   
   # 修复权限
   sudo chown -R 1000:1000 ./config
   ```

### 日志分析

```bash
# 查看Docker守护进程日志
sudo journalctl -u docker.service

# 查看容器日志
docker logs container-name 2>&1 | grep -i error
```

## 最佳实践

1. **使用.dockerignore**：排除不必要的文件
2. **使用多阶段构建**：减小镜像大小
3. **使用健康检查**：确保服务可用性
4. **使用资源限制**：避免资源耗尽
5. **使用日志管理**：避免日志文件过大
6. **定期更新镜像**：保持安全补丁
7. **使用版本控制**：管理docker-compose.yml
8. **备份重要数据**：定期备份配置和数据