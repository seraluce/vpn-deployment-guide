# 云平台部署指南

利用云服务商的一键部署功能，可以快速搭建VPN服务。

## 云平台选择

### 主流云服务商

| 云服务商 | 优势 | 适用场景 |
|----------|------|----------|
| AWS | 全球覆盖、功能丰富 | 企业级应用 |
| Google Cloud | 性价比高、网络质量好 | 开发测试 |
| Azure | 与微软生态集成 | 企业环境 |
| DigitalOcean | 简单易用、价格实惠 | 个人项目 |
| Vultr | 多地区节点、按小时计费 | 短期使用 |
| 阿里云 | 国内访问快、中文支持 | 国内用户 |
| 腾讯云 | 国内生态、性价比高 | 国内用户 |

### 选择建议

- **国内用户**：阿里云、腾讯云、华为云
- **海外用户**：AWS、Google Cloud、DigitalOcean
- **预算有限**：DigitalOcean、Vultr、Linode
- **企业环境**：AWS、Azure、Google Cloud

## AWS 部署

### 创建EC2实例

1. **登录AWS控制台**

访问 https://console.aws.amazon.com/

2. **启动EC2实例**

- 选择Amazon Linux 2或Ubuntu
- 选择实例类型（t3.micro免费套餐）
- 配置安全组，开放VPN端口
- 创建或选择密钥对

3. **连接实例**

```bash
# 使用SSH连接
ssh -i your-key.pem ec2-user@your-public-ip

# 或使用EC2 Instance Connect（网页版）
```

### 使用CloudFormation

1. **创建CloudFormation模板**

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: 'VPN Server Deployment'

Parameters:
  InstanceType:
    Type: String
    Default: t3.micro
  KeyName:
    Type: AWS::EC2::KeyPair::KeyName
  VpcCidr:
    Type: String
    Default: 10.0.0.0/16

Resources:
  VPNServer:
    Type: AWS::EC2::Instance
    Properties:
      InstanceType: !Ref InstanceType
      KeyName: !Ref KeyName
      ImageId: ami-0c55b159cbfafe1f0
      SecurityGroups:
        - !Ref VPNSecurityGroup
      Tags:
        - Key: Name
          Value: VPN-Server

  VPNSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: VPN Security Group
      SecurityGroupIngress:
        - IpProtocol: udp
          FromPort: 51820
          ToPort: 51820
          CidrIp: 0.0.0.0/0
        - IpProtocol: udp
          FromPort: 1194
          ToPort: 1194
          CidrIp: 0.0.0.0/0
        - IpProtocol: tcp
          FromPort: 8388
          ToPort: 8388
          CidrIp: 0.0.0.0/0
        - IpProtocol: tcp
          FromPort: 443
          ToPort: 443
          CidrIp: 0.0.0.0/0
```

2. **部署模板**

```bash
# 使用AWS CLI部署
aws cloudformation create-stack \
  --stack-name vpn-server \
  --template-body file://template.yaml \
  --parameters ParameterKey=KeyName,ParameterValue=your-key-name \
  --capabilities CAPABILITY_IAM
```

### 使用Lightsail

1. **创建Lightsail实例**

访问 https://lightsail.aws.amazon.com/

- 选择操作系统（Ubuntu）
- 选择计划（$3.5/月起）
- 配置SSH密钥

2. **配置防火墙**

在Lightsail控制台配置网络防火墙，开放VPN端口。

## Google Cloud 部署

### 创建Compute Engine实例

1. **登录Google Cloud控制台**

访问 https://console.cloud.google.com/

2. **创建VM实例**

- 选择地区和区域
- 选择机器类型（e2-micro免费套餐）
- 选择操作系统（Ubuntu）
- 配置防火墙规则

3. **连接实例**

```bash
# 使用gcloud命令
gcloud compute ssh instance-name --zone=us-central1-a

# 或使用网页SSH
```

### 使用Deployment Manager

1. **创建配置文件**

```yaml
resources:
- name: vpn-server
  type: compute.v1.instance
  properties:
    zone: us-central1-a
    machineType: zones/us-central1-a/machineTypes/e2-micro
    disks:
    - deviceName: boot
      type: PERSISTENT
      boot: true
      initializeParams:
        diskImage: projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20210618
    networkInterfaces:
    - network: global/networks/default
      accessConfigs:
      - name: External NAT
        type: ONE_TO_ONE_NAT
```

2. **部署配置**

```bash
gcloud deployment-manager deployments create vpn-server --config config.yaml
```

### 使用Cloud Shell

1. **启动Cloud Shell**

在Google Cloud控制台点击Cloud Shell图标。

2. **部署VPN**

```bash
# 下载安装脚本
wget https://raw.githubusercontent.com/angristan/wireguard-install/master/wireguard-install.sh

# 运行安装
chmod +x wireguard-install.sh
sudo ./wireguard-install.sh
```

## DigitalOcean 部署

### 创建Droplet

1. **登录DigitalOcean控制台**

访问 https://cloud.digitalocean.com/

2. **创建Droplet**

- 选择区域（纽约、旧金山、新加坡等）
- 选择镜像（Ubuntu）
- 选择计划（$5/月起）
- 添加SSH密钥

3. **连接Droplet**

```bash
ssh root@your-droplet-ip
```

### 使用API

```bash
# 创建Droplet
curl -X POST -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"name":"vpn-server","region":"nyc3","size":"s-1vcpu-1gb","image":"ubuntu-20-04-x64"}' \
  "https://api.digitalocean.com/v2/droplets"
```

### 一键部署

```bash
# 使用安装脚本
wget https://raw.githubusercontent.com/angristan/wireguard-install/master/wireguard-install.sh
chmod +x wireguard-install.sh
sudo ./wireguard-install.sh
```

## 阿里云 部署

### 创建ECS实例

1. **登录阿里云控制台**

访问 https://ecs.console.aliyun.com/

2. **创建实例**

- 选择地域（华北、华东、华南等）
- 选择实例规格（ecs.t6-c1m1.large）
- 选择镜像（Ubuntu）
- 配置安全组

3. **连接实例**

```bash
# 使用SSH连接
ssh -i your-key.pem root@your-public-ip
```

### 配置安全组

1. **创建安全组**

- 协议：UDP
- 端口：51820, 1194, 8388
- 授权对象：0.0.0.0/0

2. **配置规则**

```bash
# 使用aliyun CLI配置
aliyun ecs AuthorizeSecurityGroup \
  --SecurityGroupId sg-xxxxxxxx \
  --IpProtocol udp \
  --PortRange 51820/51820 \
  --SourceCidrIp 0.0.0.0/0
```

### 使用ROS部署

1. **创建ROS模板**

```yaml
ROSTemplateFormatVersion: '2019-09-09'
Description: 'VPN Server'

Parameters:
  InstanceType:
    Type: String
    Default: ecs.t6-c1m1.large

Resources:
  VPNServer:
    Type: 'ALIYUN::ECS::Instance'
    Properties:
      InstanceType: !Ref InstanceType
      ImageId: ubuntu_20_04_x64_20G
      SecurityGroupId: !Ref SecurityGroup
      Tags:
        - Key: Name
          Value: VPN-Server
```

2. **部署模板**

```bash
aliyun ros CreateStack \
  --TemplateBody file://template.yaml \
  --StackName vpn-server
```

## 腾讯云 部署

### 创建CVM实例

1. **登录腾讯云控制台**

访问 https://console.cloud.tencent.com/cvm

2. **创建实例**

- 选择地域（广州、北京、上海等）
- 选择机型（S5.LARGE8）
- 选择镜像（Ubuntu）
- 配置安全组

3. **连接实例**

```bash
ssh -i your-key.pem root@your-public-ip
```

### 配置安全组

1. **创建安全组**

- 协议：UDP
- 端口：51820, 1194, 8388
- 来源：0.0.0.0/0

2. **配置规则**

```bash
# 使用tccli配置
tccli cvm AuthorizeSecurityGroup \
  --SecurityGroupId sg-xxxxxxxx \
  --Protocol udp \
  --Port 51820 \
  --CidrBlock 0.0.0.0/0
```

## 华为云 部署

### 创建ECS实例

1. **登录华为云控制台**

访问 https://console.huaweicloud.com/

2. **创建实例**

- 选择区域（华北、华东、华南等）
- 选择规格（s6.small.1）
- 选择镜像（Ubuntu）
- 配置安全组

3. **连接实例**

```bash
ssh -i your-key.pem root@your-public-ip
```

### 配置安全组

```bash
# 使用hcloud CLI配置
hcloud compute security-group add-rule <security-group-id> \
  --direction ingress \
  --protocol udp \
  --port 51820 \
  --remote-ip 0.0.0.0/0
```

## 一键部署脚本

### WireGuard 一键安装

```bash
# 下载安装脚本
wget https://raw.githubusercontent.com/angristan/wireguard-install/master/wireguard-install.sh

# 添加执行权限
chmod +x wireguard-install.sh

# 运行安装
sudo ./wireguard-install.sh
```

脚本会自动：
- 安装WireGuard
- 配置防火墙
- 生成客户端配置
- 显示连接信息

### OpenVPN 一键安装

```bash
# 下载安装脚本
wget https://raw.githubusercontent.com/angristan/openvpn-install/master/openvpn-install.sh

# 添加执行权限
chmod +x openvpn-install.sh

# 运行安装
sudo ./openvpn-install.sh
```

### Shadowsocks 一键安装

```bash
# 下载安装脚本
wget https://raw.githubusercontent.com/the0demiurge/ShadowsocksR-install/master/shadowsocksR.sh

# 添加执行权限
chmod +x shadowsocksR.sh

# 运行安装
sudo ./shadowsocksR.sh
```

## 成本优化

### 选择合适的实例

1. **按需选择**：根据实际需求选择实例规格
2. **使用抢占式实例**：适合测试环境
3. **使用预留实例**：适合长期使用

### 网络优化

1. **选择合适地域**：选择离用户近的地域
2. **使用CDN**：加速静态资源访问
3. **优化带宽**：根据流量选择带宽计费方式

### 存储优化

1. **使用对象存储**：存储日志和备份
2. **使用SSD硬盘**：提高读写性能
3. **定期清理日志**：避免存储空间不足

## 安全配置

### 基本安全

1. **修改SSH端口**：避免使用默认22端口
2. **禁用密码登录**：只允许密钥登录
3. **配置防火墙**：只开放必要端口
4. **定期更新系统**：保持安全补丁

### 网络安全

1. **使用VPC**：隔离网络环境
2. **配置安全组**：限制访问IP
3. **启用DDoS防护**：防止攻击
4. **使用WAF**：保护Web应用

### 数据安全

1. **加密存储**：敏感数据加密存储
2. **定期备份**：备份重要数据
3. **访问控制**：限制访问权限
4. **审计日志**：记录操作日志

## 监控和告警

### 监控配置

1. **系统监控**：CPU、内存、磁盘
2. **网络监控**：带宽、连接数
3. **应用监控**：服务状态、响应时间

### 告警设置

1. **CPU告警**：CPU使用率超过80%
2. **内存告警**：内存使用率超过85%
3. **磁盘告警**：磁盘使用率超过90%
4. **网络告警**：带宽使用率超过80%

## 故障排除

### 常见问题

1. **实例无法连接**
   ```bash
   # 检查实例状态
   aws ec2 describe-instances --instance-ids i-xxxxxxxx
   
   # 检查安全组
   aws ec2 describe-security-groups --group-ids sg-xxxxxxxx
   ```

2. **网络不通**
   ```bash
   # 检查路由表
   aws ec2 describe-route-tables
   
   # 检查网络ACL
   aws ec2 describe-network-acls
   ```

3. **服务无法启动**
   ```bash
   # 检查日志
   sudo journalctl -u wireguard -f
   
   # 检查配置
   sudo wg show
   ```

### 日志查看

```bash
# 查看系统日志
sudo tail -f /var/log/syslog

# 查看服务日志
sudo journalctl -u service-name -f

# 查看云平台日志
# AWS CloudWatch
# Google Cloud Logging
# 阿里云日志服务
```

## 最佳实践

1. **选择合适地域**：根据用户分布选择
2. **配置高可用**：使用多实例部署
3. **定期备份**：备份配置和数据
4. **监控告警**：及时发现异常
5. **安全加固**：配置防火墙和访问控制
6. **成本优化**：选择合适的计费方式
7. **文档记录**：记录部署和配置
8. **测试验证**：在生产环境前测试