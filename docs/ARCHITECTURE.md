# Architecture

This repository is an OpenClash runtime adapter for the routing intent maintained in `Aioneas/Surge`.

## Core idea

OpenClash keeps using the original Clash subscription to fetch nodes. This repository does not replace the subscription URL and does not store private nodes.

The final runtime config is rebuilt through one deterministic path:

```text
Original Clash subscription
  -> OpenClash generated base config
  -> /etc/openclash/custom/openclash_custom_overwrite.sh
  -> aioneas_openclash_overwrite.rb
  -> final clash.yaml
```

## Responsibilities

| Area | Source of truth |
|---|---|
| Proxy nodes | Private upstream Clash subscription |
| Rule content | `Aioneas/Surge/List/*.list` and `*.clash.yaml` |
| Proxy-group structure | `openclash/custom/aioneas_openclash_overwrite.rb` |
| Final rule order | `openclash/custom/openclash_custom_rules.list` |
| Public reference example | `public/openclash.public.reference.yaml` |

## Why Ruby overwrite owns the final config

OpenClash can also append rules from LuCI settings, but mixing LuCI-side custom rule providers with repository-side overwrite makes startup order hard to reason about. The repository assumes:

- `enable_custom_clash_rules=0`
- LuCI custom rule-provider append fields are empty
- Subscription provides nodes only
- Ruby overwrite creates the final `proxy-groups`, `rule-providers`, and `rules`

This avoids warnings where OpenClash sees a `RULE-SET` before the target policy group has been created.

## Provider and group consistency

Every `RULE-SET,<provider>,<target>` entry in `openclash_custom_rules.list` should have:

1. a matching `rule-providers` entry in `aioneas_openclash_overwrite.rb`;
2. a valid target group or built-in target such as `DIRECT`;
3. a corresponding Surge-side source rule when it is not OpenClash-specific.

Run the repository validator after every rule or group change:

```sh
./scripts/validate_repo.sh
```

## Downstream update rule

When a service is added to Surge and should also exist in OpenClash, update in this order:

1. `Aioneas/Surge/List/<service>.list`
2. `Aioneas/Surge/List/<service>.clash.yaml`
3. `openclash/custom/aioneas_openclash_overwrite.rb`
4. `openclash/custom/openclash_custom_rules.list`
5. `docs/rule-providers.csv`
6. README / maintenance docs
