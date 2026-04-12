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
scripts/
  validate_repo.sh                     # 本地校验仓库文件
  sync_to_router.sh                    # 一键同步到路由器
public/
  openclash.public.reference.yaml      # 脱敏参考配置
README.md
```

> 说明：规则内容主源已统一迁移到 `Aioneas/Surge/List/*.list` 与 `*.clash.yaml`，OpenClash 仓库只维护覆写逻辑、策略组与规则顺序。

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
  - `Economist`
  - `NewYorkTimes`
  - `Caixin`
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

### 2. 路由器后台建议保持的状态（重要）

为了避免 OpenClash 在 Ruby 覆写前提前注入自定义规则 / 规则集，导致出现“因未找到对应的策略组或代理”的假警告，建议长期保持以下约定：

- `openclash.config.enable_custom_clash_rules='0'`
- OpenClash 后台「Other Rule Providers Append / 其他规则集追加」保持为空
- OpenClash 后台「Rule Providers / 自定义规则集追加」保持为空
- 不在 LuCI 后台零散维护 `AI Suite` 一类附加项；统一回收到仓库维护
- 订阅本身只负责提供节点，不负责维护最终分流结构

### 3. 当前唯一推荐的生效链路

1. OpenClash 拉取原始 Clash 订阅；
2. OpenClash 生成基础配置；
3. `/etc/openclash/custom/openclash_custom_overwrite.sh` 被调用；
4. `aioneas_openclash_overwrite.rb` 重建最终 `proxy-groups` / `rule-providers` / `rules`；
5. OpenClash 启动最终生成的 `clash.yaml`。

也就是说，当前方案的核心是：

> **保留原订阅拉节点，只用 Ruby 覆写重建分流。**

### 4. 将本仓库的自定义文件同步到路由器

需要同步到：

- `/etc/openclash/custom/openclash_custom_overwrite.sh`
- `/etc/openclash/custom/aioneas_openclash_overwrite.rb`
- `/etc/openclash/custom/openclash_custom_rules.list`
- `/etc/openclash/custom/openclash_custom_rules_2.list`

### 5. 重启 OpenClash

OpenClash 在处理配置时会自动调用：

- `openclash_custom_overwrite.sh`
- 然后由它调用 `aioneas_openclash_overwrite.rb`

覆写后的最终配置会在 OpenClash 运行配置中生效。

### 6. 启动后快速验收

启动后看到以下日志，一般说明链路正常：

- `Tip: Start Running Aioneas OpenClash Custom Overwrite...`
- `Info: Aioneas OpenClash overwrite applied successfully.`
- `OpenClash Start Successful!`

如果再次出现以下症状，优先检查后台设置是否被改回：

- `因未找到对应的策略组或代理`
- `AI Suite`
- 某个 `RULE-SET` 或 `MATCH,Final` 被跳过

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

后续如果要把 Surge 新增分流同步到 OpenClash，请固定按下面这条链路维护：

- `Aioneas/Surge`：规则内容主源
- `openclash/custom/aioneas_openclash_overwrite.rb`：OpenClash 侧 `proxy-groups` + `rule-providers`
- `openclash/custom/openclash_custom_rules.list`：最终规则顺序
- `public/openclash.public.reference.yaml`：公开参考配置
- `docs/rule-providers.csv`：规则映射清单
- `README.md` / `docs/MAINTENANCE.md`：维护说明

### 规则内容变更

如果只是改某个规则集的域名、补丁、来源：

- 优先在 `Aioneas/Surge/List/*.list` 与 `*.clash.yaml` 维护
- OpenClash 优先复用 `Aioneas/Surge` 的 Clash 版输出，避免双头维护

### 情况 1：只是调整规则顺序

直接修改：

- `openclash/custom/openclash_custom_rules.list`

说明：

- 若只是调整规则顺序、增删某个 `RULE-SET` 的位置，改这里；
- 若规则内容本身需要打补丁，优先回到 `Aioneas/Surge` 的自托管规则主源修改；
- 只有 OpenClash 专属逻辑，才直接写进这里。

### 情况 2：新增独立规则集（已有现成策略组）

按顺序操作：

1. 优先在 `Aioneas/Surge` 维护主规则源（如 `List/apple.list` / `List/apple.clash.yaml`）
2. 在 `openclash/custom/aioneas_openclash_overwrite.rb` 增加对应 `rule-provider`
3. 在 `openclash/custom/openclash_custom_rules.list` 插入对应 `RULE-SET`
4. 更新 `docs/rule-providers.csv`
5. 运行：
   - `./scripts/validate_repo.sh`
   - `./scripts/sync_to_router.sh <ip> <user> <password>`

### 情况 3：新增独立策略组

例如 Surge 新增：

- Gemini
- Perplexity
- News
- Reddit

则需要至少同时改以下几处：

1. `aioneas_openclash_overwrite.rb`：新增 `proxy-group`
2. `aioneas_openclash_overwrite.rb`：新增 `rule-provider`
3. `openclash_custom_rules.list`：新增 `RULE-SET`
4. `public/openclash.public.reference.yaml`：补参考分组
5. `README.md` / `docs/MAINTENANCE.md`：补迁移范围与维护说明

### 情况 4：仅 OpenClash 专属规则

只有当某条规则无法自然落回 `Aioneas/Surge` 主规则源，或者它就是 OpenClash 本地专属逻辑时，才考虑：

- 直接写进 `openclash_custom_rules.list`
- 或在 `ruleset/` 下维护仅供 OpenClash 使用的补充规则

默认仍然优先维护 `Aioneas/Surge` 主规则源，避免公开规则源分叉。

### 同步后验收

每次同步后，至少确认：

1. `./scripts/validate_repo.sh` 通过
2. 路由器日志出现：
   - `Tip: Start Running Aioneas OpenClash Custom Overwrite...`
   - `Info: Aioneas OpenClash overwrite applied successfully.`
   - `OpenClash Start Successful!`
3. 没有再次出现：
   - `因未找到对应的策略组或代理`
   - `AI Suite`
4. 新增分组 / `rule-provider` / `RULE-SET` 已出现在最终 `clash.yaml`

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
