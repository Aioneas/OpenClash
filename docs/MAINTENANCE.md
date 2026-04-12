# 维护说明

## 已固化的运行约定

当前 OpenClash 方案已经固定为：

- OpenClash 继续使用原始订阅拉节点
- `enable_custom_clash_rules` 必须保持为 `0`
- LuCI 后台的 `rule_provider_config` / `rule_providers` 保持为空
- 只允许 `/etc/openclash/custom/openclash_custom_overwrite.sh` + `aioneas_openclash_overwrite.rb` 负责最终分流生成

这意味着：

> **订阅负责提供节点，Ruby 覆写负责重建最终分流。**

## 为什么要这样约定

如果重新打开 `enable_custom_clash_rules=1`，或者在 LuCI 后台追加了零散的 rule-provider / 规则集，OpenClash 会先尝试把这些规则注入到基础配置里。

但此时 Ruby 还没有开始重建 `proxy-groups`，就容易出现：

- `因未找到对应的策略组或代理`
- `MATCH,Final` 被跳过
- `RULE-SET,OpenAI,OpenAI` 被跳过
- 残留 `AI Suite` 一类历史配置反复报警

因此，后续不要把分流逻辑拆成“后台零散维护 + 仓库覆写”两套入口，统一只走仓库覆写。

## Surge → OpenClash 同步 checklist

### A. 只调整规则顺序

直接修改：

- `openclash/custom/openclash_custom_rules.list`

适用场景：

- 调整某个 `RULE-SET` 顺序
- 增删某个已有分组对应的规则
- 调整 `MATCH,Final`、`GEOIP,CN,DIRECT` 等兜底位置

### B. 规则内容主源变更

如果只是某个规则集内容变了：

1. 优先修改 `Aioneas/Surge/List/*.list`
2. 如需 Clash 版同步，确保 `*.clash.yaml` 一并更新
3. 若 OpenClash 侧 provider 名称不变，通常不需要改 Ruby 覆写脚本

### C. 新增独立服务 / 独立策略组

如果 Surge 新增了一个独立分组（如 `Gemini` / `Perplexity` / `News` / `Reddit`），至少同步以下几处：

1. `Aioneas/Surge`：补主规则源
2. `openclash/custom/aioneas_openclash_overwrite.rb`：补 `proxy-group`
3. `openclash/custom/aioneas_openclash_overwrite.rb`：补 `rule-provider`
4. `openclash/custom/openclash_custom_rules.list`：补 `RULE-SET`
5. `public/openclash.public.reference.yaml`：补公开参考分组
6. `docs/rule-providers.csv`：补规则映射
7. `README.md` / `docs/MAINTENANCE.md`：补文档说明

### D. 仅 OpenClash 专属逻辑

只有当某条逻辑不适合落回 `Aioneas/Surge` 主规则源时，才考虑：

- 直接写进 `openclash_custom_rules.list`
- 或在 `ruleset/` 下维护仅供 OpenClash 使用的补充规则

默认优先避免分叉维护。

## 发布 / 同步流程

每次修改建议固定按这个顺序：

1. `./scripts/validate_repo.sh`
2. `git commit`
3. `git push`
4. `./scripts/sync_to_router.sh <ip> <user> <password>`
5. 查看 OpenClash 运行日志

## 启动后验收

同步并重启后，至少确认：

- 日志出现：
  - `Tip: Start Running Aioneas OpenClash Custom Overwrite...`
  - `Info: Aioneas OpenClash overwrite applied successfully.`
  - `OpenClash Start Successful!`
- 不再出现：
  - `因未找到对应的策略组或代理`
  - `AI Suite`
- 最终 `clash.yaml` 中能看到：
  - 新增的 `proxy-groups`
  - 新增的 `rule-providers`
  - 新增的 `RULE-SET`

## 公开仓库提交前检查

必须确认不包含：

- 私人订阅链接
- token
- 节点信息
- 证书
- 本地私有覆盖项
