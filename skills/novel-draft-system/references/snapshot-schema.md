# 快照 yaml schema

本文件是 `novel-draft-system` 的按需读取参考。仅在需要确认快照头字段完整性时读取。

## 必填字段

```yaml
---
ver: 3                                  # 正整数，跨 kind 连续递增
kind: rewrite                           # 白名单值
from_ver: 2                             # 上一版；v001 时为 null 或缺省
timestamp: 2026-04-28T15:30:00Z         # ISO 8601 UTC
forced: false                           # 是否走强制后门
---
```

## 可选字段

```yaml
slice_ref: chapters/ch007.slice.drafts/v001-slice.md
                                        # 本版是基于哪份 slice 生成的；场景 draft/rewrite 必填
author_note: "重写对峙段，让老周更保守"
                                        # 作者在触发本版时给的指令摘要，≤200 字
forced_directive: "让林婉当场拔剑"     # forced=true 时记录作者原始指令
reviewer_check: ["id-anchor", "voice-fit"]
                                        # 一致性检查脚本的检查项（通过才写这行）
```

## kind 白名单说明

| kind | 使用场景 | 输入 | 输出体积要求 |
|------|---------|------|-------------|
| `draft` | novel-scene-draft 的初稿产出 | slice.yaml | 按 intent.length_hint |
| `polish` | novel-scene-polish 不改结构 | 上一版正文 | 与上一版 ±10% |
| `expand` | novel-scene-expand 加细节 | 上一版正文 | 比上一版大，但 ≤1.5× |
| `rewrite` | novel-scene-rewrite 改结构 | 重跑的 slice.yaml | 按 intent.length_hint |
| `manual` | 作者手动触发的快照 | 工作台当前内容 | 不限 |
| `finalized` | finalize 流程补写的锚点 | = 当前工作台 | = 当前工作台 |
| `forced` | 强制后门产出 | slice.yaml + 强制指令 | 按 intent.length_hint |
| `slice` | novel-scene-plan-slice 产出 | 环境+角色清单 | 短 yaml |

## 强制模式额外要求

forced=true 的快照正文必须在末尾附带：

```markdown
## 合理性偏离说明

- 与 `characters/lin_wan.md` 的"谨慎"特质冲突：本段她公开拔剑。
- 与 `plot/ch007-outline.md` 的节奏设计冲突：本应在 ch008 才对峙。
- 建议回补：在 ch006 末尾加一场被跟踪的刺激事件，让本次爆发更合理。
```

3-5 条，不少于 3 条、不多于 5 条。少于 3 条说明作者的强制其实并不偏离，不该走后门；多于 5 条说明偏离过大，应改用 rewrite 循环而非强制。
