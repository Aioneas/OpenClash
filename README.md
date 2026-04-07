# Aioneas / OpenClash

公开版 OpenClash 配置仓库，用于把 **Surge / Sugar 的分流逻辑** 迁移到 **OpenClash**，同时保持你的 **订阅链接不变**。

## 设计目标

本仓库解决的是这类需求：

- 节点仍然由你原来的 Clash 订阅提供；
- OpenClash 继续使用原订阅链接自动更新；
- 但最终运行时的 **代理组 / 规则 / rule-providers**，按你的 Surge / Sugar 逻辑重建。

也就是说：

- **节点来源不变**
- **分流结构重建**
- **公开仓库脱敏**

---

## 仓库结构

```text
openclash/
  custom/
    openclash_custom_overwrite.sh      # OpenClash 调用入口
    aioneas_openclash_overwrite.rb     # 实际覆写逻辑
    openclash_custom_rules.list        # 主规则顺序
    openclash_custom_rules_2.list      # 预留扩展规则
ruleset/
  Link.yaml                            # 自定义 Clash 规则集
scripts/
  validate_repo.sh                     # 本地校验仓库文件
  sync_to_router.sh                    # 一键同步到路由器
public/
  openclash.public.reference.yaml      # 脱敏参考配置
README.md
```

---

## 当前迁移范围

已迁移的核心能力：

- 代理组（proxy-groups）
- 规则集（rule-providers）
- 规则顺序（rules）
- 区域节点组自动归类：
  - `HK`
  - `JP`
  - `SG`
  - `TW`
  - `US`
- 业务分组：
  - `Final`
  - `Google`
  - `Apple`
  - `OpenAI`
  - `Claude`
  - `YouTube`
  - `Netflix`
  - `Disney`
  - `HBOMax`
  - `Bahamut`
  - `BiliBili`
  - `Spotify`
  - `Steam`
  - `Telegram`
  - `Microsoft`
  - `GitHub`
  - `PayPal`
  - `Link`
  - `Speedtest`

---

## 不在本仓库迁移范围内

以下是 Surge / Sugar 特有能力，不会直接迁移到 OpenClash：

- MITM
- URL Rewrite
- Surge Module
- Surge Script / Sugar 专有脚本逻辑

所以本仓库的定位是：

> **迁移可稳定维护的代理分流逻辑，不迁移 Surge 私有能力。**

---

## 使用方式

### 1. OpenClash 订阅链接保持原样

在 OpenClash 中继续使用你原来的 Clash 订阅地址，不需要改成这个仓库地址。

### 2. 将本仓库的自定义文件同步到路由器

需要同步到：

- `/etc/openclash/custom/openclash_custom_overwrite.sh`
- `/etc/openclash/custom/aioneas_openclash_overwrite.rb`
- `/etc/openclash/custom/openclash_custom_rules.list`
- `/etc/openclash/custom/openclash_custom_rules_2.list`

### 3. 重启 OpenClash

OpenClash 在处理配置时会自动调用：

- `openclash_custom_overwrite.sh`
- 然后由它调用 `aioneas_openclash_overwrite.rb`

覆写后的最终配置会在 OpenClash 运行配置中生效。

---

## 一键同步脚本

仓库自带：

- `scripts/validate_repo.sh`
- `scripts/sync_to_router.sh`

### 校验仓库

```sh
./scripts/validate_repo.sh
```

### 同步到路由器

```sh
./scripts/sync_to_router.sh 192.168.10.1 root root
```

参数依次为：

1. 路由器 IP
2. SSH 用户名
3. SSH 密码

同步脚本会：

- 上传自定义文件
- 校验 Ruby 语法
- 测试当前 OpenClash 配置
- 重启 OpenClash
- 输出最近运行日志

---

## 维护约定

后续如果要把 Surge 新增分流同步到 OpenClash，建议按以下原则维护：

- **规则主源优先放在 `Aioneas/Surge`**：若某个上游规则集需要补丁（如 Apple），优先在 Surge 仓库自托管，再由 OpenClash 复用其 Clash 版输出。

### 规则新增

如果只是新增规则顺序：

- 优先改 `openclash/custom/openclash_custom_rules.list`

### 新增自定义规则集

如果 Surge 有新的自定义服务：

1. 在 `ruleset/` 下新增对应 `*.yaml`
2. 在 `aioneas_openclash_overwrite.rb` 里新增对应 `rule-provider`
3. 在 `openclash_custom_rules.list` 里插入对应 `RULE-SET`
4. 如果需要单独策略组，再在 Ruby 覆写脚本里新增分组

### 分组新增

如果 Surge 新增了类似 `Gemini`、`Perplexity`、`News` 这类独立组：

1. 在 Ruby 脚本中增加新的 `proxy-group`
2. 增加对应 `rule-provider`
3. 在规则顺序里插入新的 `RULE-SET`

---

## 隐私与公开仓库规则

本仓库默认是 **公开版**，必须保持脱敏：

- 不上传私人订阅链接
- 不上传节点信息
- 不上传 token / 密码 / 证书
- 不上传私有本地覆盖项

如果有本地私有配置，请只保留在路由器本地，不要提交到 GitHub。

---

## 现状说明

当前方案已经在 OpenClash + Mihomo(Meta) 环境中验证通过，适合作为后续持续维护的 OpenClash 公共规则仓库。
