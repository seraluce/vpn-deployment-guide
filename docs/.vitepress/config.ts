import { defineConfig } from 'vitepress'

export default defineConfig({
  title: 'VPN 服务端部署指南',
  description: '全面的VPN服务端部署教程，涵盖多种协议和部署方式',
  
  head: [
    ['link', { rel: 'icon', type: 'image/svg+xml', href: '/logo.svg' }],
    ['meta', { name: 'theme-color', content: '#646cff' }],
    ['meta', { name: 'og:type', content: 'website' }],
    ['meta', { name: 'og:title', content: 'VPN 服务端部署指南' }],
    ['meta', { name: 'og:description', content: '全面的VPN服务端部署教程，涵盖多种协议和部署方式' }]
  ],

  themeConfig: {
    logo: '/logo.svg',
    
    nav: [
      { text: '首页', link: '/' },
      { text: '快速开始', link: '/guide/quick-start' },
      { 
        text: 'VPN协议',
        items: [
          { text: 'WireGuard', link: '/protocols/wireguard' },
          { text: 'OpenVPN', link: '/protocols/openvpn' },
          { text: 'Shadowsocks', link: '/protocols/shadowsocks' },
          { text: 'V2Ray/Xray', link: '/protocols/v2ray' }
        ]
      },
      {
        text: '部署方式',
        items: [
          { text: 'Docker部署', link: '/deployment/docker' },
          { text: '手动安装', link: '/deployment/manual' },
          { text: '云平台部署', link: '/deployment/cloud' }
        ]
      },
      {
        text: '更多',
        items: [
          { text: '订阅链接', link: '/subscription/overview' },
          { text: '安全配置', link: '/security/firewall' },
          { text: '故障排除', link: '/troubleshooting/common-issues' }
        ]
      }
    ],

    sidebar: {
      '/guide/': [
        {
          text: '入门指南',
          items: [
            { text: '项目概述', link: '/guide/overview' },
            { text: '环境要求', link: '/guide/requirements' },
            { text: '快速开始', link: '/guide/quick-start' }
          ]
        }
      ],
      '/protocols/': [
        {
          text: 'VPN协议',
          items: [
            { text: 'WireGuard', link: '/protocols/wireguard' },
            { text: 'OpenVPN', link: '/protocols/openvpn' },
            { text: 'Shadowsocks', link: '/protocols/shadowsocks' },
            { text: 'V2Ray/Xray', link: '/protocols/v2ray' }
          ]
        }
      ],
      '/deployment/': [
        {
          text: '部署方式',
          items: [
            { text: 'Docker部署', link: '/deployment/docker' },
            { text: '手动安装', link: '/deployment/manual' },
            { text: '云平台部署', link: '/deployment/cloud' }
          ]
        }
      ],
      '/subscription/': [
        {
          text: '订阅链接',
          items: [
            { text: '订阅链接概述', link: '/subscription/overview' },
            { text: '订阅链接生成', link: '/subscription/generation' },
            { text: '客户端配置', link: '/subscription/client-config' }
          ]
        }
      ],
      '/security/': [
        {
          text: '安全配置',
          items: [
            { text: '防火墙配置', link: '/security/firewall' },
            { text: 'TLS证书配置', link: '/security/tls' },
            { text: '安全加固', link: '/security/hardening' }
          ]
        }
      ],
      '/troubleshooting/': [
        {
          text: '故障排除',
          items: [
            { text: '常见问题', link: '/troubleshooting/common-issues' },
            { text: '日志分析', link: '/troubleshooting/logs' }
          ]
        }
      ]
    },

    socialLinks: [
      { icon: 'github', link: 'https://github.com/seraluce/vpn-deployment-guide' }
    ],

    footer: {
      message: '基于 MIT 许可证发布',
      copyright: '© 2024 VPN部署指南'
    },

    search: {
      provider: 'local'
    },

    outline: {
      level: [2, 3],
      label: '页面导航'
    },

    lastUpdated: {
      text: '最后更新于'
    },

    docFooter: {
      prev: '上一篇',
      next: '下一篇'
    },

    returnToTopLabel: '回到顶部',
    sidebarMenuLabel: '菜单',
    darkModeSwitchLabel: '主题',
    lightModeSwitchTitle: '切换到浅色模式',
    darkModeSwitchTitle: '切换到深色模式'
  }
})