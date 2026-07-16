# 客户端配置指南

本指南介绍如何在不同平台上配置VPN客户端使用订阅链接。

## Windows 配置

### Clash for Windows

1. **下载安装**

访问 https://github.com/Fndroid/clash_for_windows/releases 下载最新版本。

2. **添加订阅链接**

- 打开Clash for Windows
- 点击"Profiles"选项卡
- 在URL输入框中粘贴订阅链接
- 点击"Download"按钮

3. **配置代理**

- 点击"General"选项卡
- 开启"System Proxy"选项
- 选择合适的代理模式（Rule/Global/Direct）

4. **测试连接**

- 访问 https://ip.sb 检查IP地址
- 尝试访问被限制的网站

### v2rayN

1. **下载安装**

访问 https://github.com/2dust/v2rayN/releases 下载最新版本。

2. **添加订阅链接**

- 打开v2rayN
- 右键点击系统托盘图标
- 选择"订阅" → "订阅设置"
- 点击"添加"按钮
- 输入订阅链接
- 点击"确定"

3. **更新订阅**

- 右键点击系统托盘图标
- 选择"订阅" → "更新订阅"

4. **启动代理**

- 右键点击系统托盘图标
- 选择"系统代理" → "自动配置系统代理"

### Shadowsocks-windows

1. **下载安装**

访问 https://github.com/shadowsocks/shadowsocks-windows/releases 下载最新版本。

2. **添加服务器**

- 打开Shadowsocks
- 右键点击系统托盘图标
- 选择"服务器" → "编辑服务器"
- 输入服务器信息
- 点击"确定"

3. **启动代理**

- 右键点击系统托盘图标
- 选择"启用系统代理"

## macOS 配置

### ClashX

1. **下载安装**

```bash
# 使用Homebrew安装
brew install --cask clashx
```

2. **添加订阅链接**

- 打开ClashX
- 点击菜单栏ClashX图标
- 选择"配置" → "订阅"
- 点击"+"按钮
- 输入订阅链接
- 点击"下载"

3. **配置代理**

- 点击菜单栏ClashX图标
- 选择"设置" → "代理"
- 选择合适的代理模式

### Surge

1. **下载安装**

访问 https://nssurge.com/ 下载最新版本。

2. **添加订阅链接**

- 打开Surge
- 点击"配置"选项卡
- 点击"从URL导入配置"
- 输入订阅链接
- 点击"导入"

3. **启动代理**

- 点击"常规"选项卡
- 开启"系统代理"

### Quantumult X

1. **下载安装**

从App Store下载Quantumult X。

2. **添加订阅链接**

- 打开Quantumult X
- 点击左上角图标
- 选择"配置" → "引用"
- 点击"添加引用"
- 输入订阅链接
- 点击"确定"

3. **启用代理**

- 返回主界面
- 开启"启用代理"

## iOS 配置

### Shadowrocket

1. **下载安装**

从App Store下载Shadowrocket（付费应用）。

2. **添加订阅链接**

- 打开Shadowrocket
- 点击右上角"+"按钮
- 选择"类型"为"Subscribe"
- 输入订阅链接
- 点击"完成"

3. **启用代理**

- 点击右上角开关
- 允许VPN配置

### Quantumult X

1. **下载安装**

从App Store下载Quantumult X（付费应用）。

2. **添加订阅链接**

- 打开Quantumult X
- 点击右下角图标
- 选择"配置" → "引用"
- 点击"添加引用"
- 输入订阅链接
- 点击"确定"

3. **启用代理**

- 返回主界面
- 点击右上角开关

### Surge

1. **下载安装**

从App Store下载Surge（付费应用）。

2. **添加订阅链接**

- 打开Surge
- 点击"配置"选项卡
- 点击"从URL导入配置"
- 输入订阅链接
- 点击"导入"

3. **启用代理**

- 点击"常规"选项卡
- 开启"系统代理"

## Android 配置

### Clash for Android

1. **下载安装**

访问 https://github.com/MetaCubeXD/ClashMetaForAndroid/releases 下载最新版本。

2. **添加订阅链接**

- 打开Clash for Android
- 点击"配置"选项卡
- 点击"在线导入"
- 输入订阅链接
- 点击"导入"

3. **启动代理**

- 点击"通用"选项卡
- 开启"系统代理"

### V2RayNG

1. **下载安装**

访问 https://github.com/2dust/v2rayNG/releases 下载最新版本。

2. **添加订阅链接**

- 打开V2RayNG
- 点击右上角"+"按钮
- 选择"从剪贴板导入"
- 粘贴订阅链接
- 点击"确定"

3. **启动代理**

- 点击右上角开关

### Shadowsocks Android

1. **下载安装**

从Google Play下载Shadowsocks。

2. **添加服务器**

- 打开Shadowsocks
- 点击"+"按钮
- 输入服务器信息
- 点击"保存"

3. **连接代理**

- 点击连接按钮

## Linux 配置

### Clash

1. **安装Clash**

```bash
# 下载Clash
wget https://github.com/MetaCubeX/Clash.Meta/releases/download/v1.15.0/clash-meta-linux-amd64-v1.15.0.gz

# 解压
gunzip clash-meta-linux-amd64-v1.15.0.gz

# 移动到/usr/local/bin
sudo mv clash-meta-linux-amd64-v1.15.0 /usr/local/bin/clash

# 添加执行权限
sudo chmod +x /usr/local/bin/clash
```

2. **配置Clash**

```bash
# 创建配置目录
mkdir -p ~/.config/clash

# 下载配置
curl -o ~/.config/clash/config.yaml "http://your-server-ip:8080/subscribe/clash/user1"

# 启动Clash
clash -d ~/.config/clash
```

3. **设置代理**

```bash
# 设置环境变量
export http_proxy=http://127.0.0.1:7890
export https_proxy=http://127.0.0.1:7890
export all_proxy=socks5://127.0.0.1:7891
```

### V2Ray

1. **安装V2Ray**

```bash
bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh)
```

2. **配置V2Ray**

```bash
# 下载配置
curl -o /usr/local/etc/v2ray/config.json "http://your-server-ip:8080/subscribe/v2ray/user1"

# 启动V2Ray
sudo systemctl start v2ray
```

3. **设置代理**

```bash
# 设置环境变量
export http_proxy=socks5://127.0.0.1:1080
export https_proxy=socks5://127.0.0.1:1080
```

### Shadowsocks

1. **安装Shadowsocks**

```bash
sudo apt install shadowsocks-libev
```

2. **配置Shadowsocks**

```bash
# 下载配置
curl -o /etc/shadowsocks-libev/config.json "http://your-server-ip:8080/subscribe/ss/user1"

# 启动Shadowsocks
sudo systemctl start shadowsocks-libev
```

3. **设置代理**

```bash
# 设置环境变量
export http_proxy=socks5://127.0.0.1:1080
export https_proxy=socks5://127.0.0.1:1080
```

## 浏览器配置

### Chrome

1. **安装Proxy SwitchyOmega**

访问Chrome Web Store安装Proxy SwitchyOmega。

2. **配置代理**

- 打开Proxy SwitchyOmega
- 点击"新建情景模式"
- 选择"代理服务器"
- 输入代理地址和端口
- 点击"保存"

3. **启用代理**

- 点击Proxy SwitchyOmega图标
- 选择配置的情景模式

### Firefox

1. **配置代理**

- 打开Firefox
- 点击"菜单" → "设置"
- 滚动到"网络设置"
- 点击"设置"
- 选择"手动代理配置"
- 输入代理地址和端口
- 点击"确定"

## 测试连接

### 检查IP地址

```bash
# 使用curl
curl ifconfig.me

# 使用wget
wget -qO- ifconfig.me
```

### 测试速度

```bash
# 使用speedtest-cli
pip install speedtest-cli
speedtest-cli
```

### 测试延迟

```bash
# ping测试
ping -c 10 8.8.8.8

# traceroute测试
traceroute 8.8.8.8
```

## 故障排除

### 常见问题

1. **无法连接**
   ```bash
   # 检查代理设置
   echo $http_proxy
   echo $https_proxy
   
   # 检查端口
   netstat -tulpn | grep :7890
   ```

2. **连接速度慢**
   ```bash
   # 测试网络延迟
   ping -c 10 your-server-ip
   
   # 测试带宽
   speedtest-cli
   ```

3. **配置无法导入**
   ```bash
   # 检查订阅链接
   curl -v "http://your-server-ip:8080/subscribe/user1"
   
   # 检查配置格式
   cat config.yaml
   ```

### 日志查看

```bash
# Clash日志
tail -f ~/.config/clash/logs/clash.log

# V2Ray日志
sudo journalctl -u v2ray -f

# Shadowsocks日志
sudo journalctl -u shadowsocks-libev -f
```

## 最佳实践

1. **选择合适协议**：根据网络环境选择
2. **定期更新订阅**：保持配置最新
3. **测试连接**：定期测试连接状态
4. **监控流量**：了解流量使用情况
5. **安全使用**：避免访问恶意网站
6. **备份配置**：备份重要配置文件
7. **更新客户端**：保持客户端最新版本
8. **阅读文档**：了解客户端功能