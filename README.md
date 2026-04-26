# Proxy Rules（Clash/Mihomo / Surge / Loon）

本仓库用于维护三端可用的分流规则（Clash/Mihomo、Surge、Loon），并通过 GitHub Actions 定时同步上游规则。

## 目录结构

```
clash/
  rules/
    proxy/
    game/
    reject/
    direct/
    custom/
  config/
    template.yaml
surge/
  rules/
    proxy/
    game/
    reject/
    direct/
    custom/
  config/
    template.conf
loon/
  rules/
    proxy/
    game/
    reject/
    direct/
    custom/
  config/
    template.conf
scripts/
  update.sh
.github/workflows/
  update.yml
```

## 规则文件格式

- Clash/Mihomo：`clash/rules/**.yaml`，内容为：
  - `payload:` 下逐行列出 `DOMAIN-SUFFIX` / `DOMAIN-KEYWORD`（以及 `cn-ip` 使用 `IP-CIDR`）。
- Surge / Loon：`**.list`，每行一条规则，内容与 Clash 一致，只是不带 `payload` 和缩进。

## jsDelivr CDN 引用

本仓库默认使用：

- `https://cdn.jsdelivr.net/gh/kyle1417/proxy-rules@main/clash/rules/...`
- `https://cdn.jsdelivr.net/gh/kyle1417/proxy-rules@main/surge/rules/...`
- `https://cdn.jsdelivr.net/gh/kyle1417/proxy-rules@main/loon/rules/...`

示例：

- Clash/Mihomo：`https://cdn.jsdelivr.net/gh/kyle1417/proxy-rules@main/clash/rules/proxy/ai.yaml`
- Surge：`https://cdn.jsdelivr.net/gh/kyle1417/proxy-rules@main/surge/rules/proxy/ai.list`
- Loon：`https://cdn.jsdelivr.net/gh/kyle1417/proxy-rules@main/loon/rules/proxy/ai.list`

## 自定义规则

- 自定义代理：`*/rules/custom/my-proxy.*`
- 自定义直连：`*/rules/custom/my-direct.*`

## 自动更新

- 脚本：`scripts/update.sh`
- 工作流：`.github/workflows/update.yml`（每天定时运行，规则变化时自动提交推送）

## 上游来源

- blackmatrix7/ios_rule_script
- ACL4SSR/ACL4SSR
