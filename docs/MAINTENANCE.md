# 维护说明

## 后续新增 Surge 分流时怎么同步到 OpenClash

### 情况 1：只是新增规则

直接修改：

- `openclash/custom/openclash_custom_rules.list`

说明：

- 少量上游规则缺口（例如校园网下个别 Apple 域名）优先直接写在 `openclash_custom_rules.list` 顶部；
- 只有当自定义域名很多、已经形成独立服务时，才考虑新增单独 `ruleset/*.yaml`。

### 情况 2：新增独立服务规则集

按顺序操作：

1. 在 `ruleset/` 新增 `XXX.yaml`
2. 在 `openclash/custom/aioneas_openclash_overwrite.rb` 增加对应 `rule-provider`
3. 在 `openclash/custom/openclash_custom_rules.list` 插入：
   - `RULE-SET,XXX,对应分组`
4. 运行：
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
