# Aioneas OpenClash Public Config

公开版 OpenClash 规则与覆写脚本仓库。

## 目标

- **保持你自己的 OpenClash 订阅链接不变**
- 使用订阅生成的节点作为 **节点源**
- 再通过 `openclash_custom_overwrite.sh` 把代理组 / 规则集 / 分流逻辑改造成接近 Surge / Sugar 版本的结构

## 本仓库包含

- `openclash/custom/openclash_custom_overwrite.sh`
  - OpenClash 自定义覆写脚本
  - 负责重建代理组、注入 rule-providers、套用规则
- `openclash/custom/openclash_custom_rules.list`
  - 规则顺序清单
  - 由覆写脚本直接读取并写入最终运行配置
- `ruleset/Link.yaml`
  - `Link` 专用 Clash 规则集

## 不包含的内容

本仓库是 **公开版**，已脱敏，不包含：

- 私人订阅链接
- 节点信息
- token / 密码 / 证书
- 本地私有覆盖项

## 设计说明

OpenClash 最稳定的做法不是直接把整份 Surge 配置原样塞进去，而是：

1. 继续使用你原来的 Clash 订阅链接拉取节点；
2. 用 OpenClash 自定义覆写脚本，在每次更新后自动：
   - 重建区域组（HK / JP / SG / TW / US）
   - 重建业务组（Google / Apple / OpenAI / Claude / GitHub / Link / Speedtest 等）
   - 注入 `rule-providers`
   - 按 `openclash_custom_rules.list` 重新写入最终规则顺序

这样既能保留原订阅，又能把策略逻辑迁移到 OpenClash。

## 兼容性说明

- 已适配 **OpenClash + Mihomo(Meta)**
- Surge 的以下能力 **不会直接迁移** 到 OpenClash：
  - MITM
  - URL Rewrite
  - Surge 模块脚本

本仓库只处理 **代理组 / 规则 / 规则集** 迁移。
