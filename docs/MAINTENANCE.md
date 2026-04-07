# 维护说明

## 后续新增 Surge 分流时怎么同步到 OpenClash

### 情况 1：只是新增规则

直接修改：

- `openclash/custom/openclash_custom_rules.list`

说明：

- 若只是调整规则顺序、增删某个 `RULE-SET` 的位置，改这里；
- 若规则内容本身需要打补丁，优先回到 `Aioneas/Surge` 的自托管规则主源修改；
- 只有 OpenClash 专属逻辑，才直接写进这里。

### 情况 2：新增独立服务规则集

按顺序操作：

1. 优先在 `Aioneas/Surge` 维护主规则源（如 `List/apple.list` / `List/apple.clash.yaml`）
2. 在 `ruleset/` 新增 `XXX.yaml` 仅用于 OpenClash 专属规则时再单独放这里
3. 在 `openclash/custom/aioneas_openclash_overwrite.rb` 增加对应 `rule-provider`
4. 在 `openclash/custom/openclash_custom_rules.list` 插入：
   - `RULE-SET,XXX,对应分组`
5. 运行：
   - `./scripts/validate_repo.sh`
   - `./scripts/sync_to_router.sh <ip> <user> <password>`

### 情况 3：新增独立策略组

例如 Surge 新增：

- Gemini
- Perplexity
- News
- Reddit

则需要同时改三处：

1. `aioneas_openclash_overwrite.rb`：新增 `proxy-group`
2. `aioneas_openclash_overwrite.rb`：新增 `rule-provider`
3. `openclash_custom_rules.list`：新增 `RULE-SET`

## 公开仓库提交前检查

必须确认不包含：

- 私人订阅链接
- token
- 节点信息
- 证书
- 本地私有覆盖项
