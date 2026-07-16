# 如何将文档部署到GitHub Wiki

本指南说明如何将wiki目录中的文档部署到GitHub Wiki。

## 步骤1：创建GitHub Wiki仓库

1. 访问GitHub仓库页面：https://github.com/seraluce/vpn-deployment-guide
2. 点击右上角的"Wiki"标签
3. 点击"Create the first page"按钮
4. 保存页面

## 步骤2：克隆Wiki仓库

```bash
# 克隆wiki仓库
git clone https://github.com/seraluce/vpn-deployment-guide.wiki.git

# 进入wiki目录
cd vpn-deployment-guide.wiki
```

## 步骤3：复制文档

```bash
# 从主仓库复制wiki文档
cp /path/to/vpn-deployment-guide/wiki/* .

# 或者使用相对路径（如果在同一目录下）
cp ../vpn-deployment-guide/wiki/* .
```

## 步骤4：提交并推送

```bash
# 添加所有文件
git add .

# 提交更改
git commit -m "添加VPN部署指南文档"

# 推送到GitHub
git push
```

## 步骤5：验证

1. 访问GitHub Wiki页面：https://github.com/seraluce/vpn-deployment-guide/wiki
2. 检查所有页面是否正确显示
3. 测试所有链接是否正常工作

## 文档结构

部署后的Wiki将包含以下页面：

- **Home**：首页，包含目录和快速开始指南
- **项目概述**：项目介绍和目标
- **环境要求**：系统和网络要求
- **快速开始**：5分钟快速部署指南
- **WireGuard部署**：WireGuard详细部署指南
- **OpenVPN部署**：OpenVPN详细部署指南
- **Shadowsocks部署**：Shadowsocks详细部署指南
- **V2Ray部署**：V2Ray/Xray详细部署指南
- **Docker部署**：Docker容器化部署指南
- **手动安装**：手动安装指南
- **云平台部署**：云平台部署指南
- **订阅链接概述**：订阅链接功能介绍
- **订阅链接生成**：如何生成订阅链接
- **客户端配置**：如何配置客户端
- **防火墙配置**：防火墙配置指南
- **TLS证书配置**：TLS证书配置指南
- **安全加固**：安全加固指南
- **常见问题**：常见问题解答
- **日志分析**：日志分析指南

## 自动化部署

如果您希望自动化部署Wiki，可以使用以下脚本：

```bash
#!/bin/bash

# 配置
WIKI_REPO="https://github.com/seraluce/vpn-deployment-guide.wiki.git"
WIKI_DIR="/tmp/vpn-wiki"
SOURCE_DIR="/path/to/vpn-deployment-guide/wiki"

# 克隆wiki仓库
if [ -d "$WIKI_DIR" ]; then
    rm -rf "$WIKI_DIR"
fi
git clone "$WIKI_REPO" "$WIKI_DIR"

# 复制文档
cp "$SOURCE_DIR"/* "$WIKI_DIR"/

# 提交并推送
cd "$WIKI_DIR"
git add .
git commit -m "自动更新文档 $(date +%Y-%m-%d)"
git push

# 清理
rm -rf "$WIKI_DIR"

echo "Wiki文档部署完成！"
```

将此脚本保存为`deploy-wiki.sh`，然后运行：

```bash
chmod +x deploy-wiki.sh
./deploy-wiki.sh
```

## 注意事项

1. **页面命名**：Wiki页面使用中文命名，确保链接格式正确
2. **链接格式**：使用`[[页面名称]]`格式链接到其他页面
3. **图片链接**：如果包含图片，请使用相对路径
4. **更新维护**：定期更新Wiki文档以保持内容最新

## 故障排除

### 问题1：无法克隆Wiki仓库

**解决方案**：
- 确保已登录GitHub
- 检查仓库权限
- 尝试使用SSH协议：`git clone git@github.com:seraluce/vpn-deployment-guide.wiki.git`

### 问题2：链接无法工作

**解决方案**：
- 检查链接格式是否正确
- 确保目标页面存在
- 使用完整的页面名称

### 问题3：中文显示乱码

**解决方案**：
- 确保文件使用UTF-8编码
- 在git中设置编码：`git config core.quotepath false`

## 更多资源

- [GitHub Wiki帮助文档](https://docs.github.com/en/communities/documenting-your-project-with-wikis)
- [Markdown语法指南](https://www.markdownguide.org/)
- [GitHub Wiki API](https://docs.github.com/en/rest/reference/wikis)