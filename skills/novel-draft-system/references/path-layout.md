# 草稿层目录契约

本文件是 `novel-draft-system` 的按需读取参考。仅在需要确认目录命名、迁移规则或路径解析时读取。

## 书籍工作区目录

```
<book-root>/
├── summary.md                         # 定稿：高层稳定结论
├── context.md                         # 定稿：决策/冲突/待确认
├── outline/ plot/ characters/ canon/ chapters/   # 定稿层
├── drafts/                            # 草稿层
│   ├── outline/
│   ├── plot/
│   ├── characters/<id>/state.md       # 角色当前状态快照
│   ├── characters/<id>/state.drafts/  # state 历史快照
│   ├── chapters/<scene>.md            # 章节工作台
│   ├── chapters/<scene>.drafts/       # 章节版本链
│   └── chapters/<scene>.slice.yaml    # 场景切片清单（由 plan-slice 产出）
├── inbox/                             # 原始灵感/素材
└── .draft-index.yaml                  # 草稿索引（脚本维护）
```

## category 定义（asset 第一段路径）

草稿系统接受的 category 白名单：

- `outline`
- `plot`
- `characters`
- `canon`
- `chapters`

例：`asset=chapters/ch007` 对应 `drafts/chapters/ch007.md` + `drafts/chapters/ch007.drafts/vNNN-*.md`。

## 状态资产的特殊路径

角色 state 用复合路径 `characters/<id>/state`：

- 工作台：`drafts/characters/<id>/state.md`
- 版本链：`drafts/characters/<id>/state.drafts/vNNN-<kind>.md`
- 定稿层：**无**（state 本身是草稿概念，不存在定稿版本；finalize 场景时只 diff 更新 state.md）

## 切片资产的特殊路径

场景切片 slice.yaml 也走版本链：

- 工作台：`drafts/chapters/<scene>.slice.yaml`
- 版本链：`drafts/chapters/<scene>.slice.drafts/vNNN-slice.md`（kind 永远 slice）
- 定稿层：无。slice 随 finalize 的场景一起冻结在版本链里。

## .gitignore 约定

- `drafts/` 主工作区进 git：作者能看到当前草稿演进。
- `drafts/**/*.drafts/` 历史快照**不进 git**：量大且价值随时间衰减，靠脚本和本地快照兜底。
- `.draft-index.yaml` 进 git：作为跨端可感知的进度指标。

## 迁移规则（从旧结构到新结构）

旧结构（阶段 C 之前）把所有内容直接写在定稿层。迁移时：

1. 所有定稿层已有文件**保留不动**。它们被当作"最早一次 finalize 的锚点"。
2. 新增的草稿资产一律落 `drafts/`。
3. 作者对旧定稿文件的修改 → 首次修改时复制该文件到 `drafts/<category>/<asset>.md` 并生成 `v001-manual.md` 快照。

## .draft-index.yaml 格式

```yaml
book_id: demo-book
updated_at: 2026-04-28T16:00:00Z
assets:
  chapters/ch007:
    current_ver: 4
    last_kind: rewrite
    forced: false
    finalized: true
    finalized_at: 2026-04-28T16:00:00Z
  characters/lin_wan/state:
    current_ver: 2
    last_kind: manual
    forced: false
    finalized: false
stats:
  total_assets: 12
  forced_count: 0
  forced_ratio: 0.0
```

由 `scripts/draft-index-update.sh` 全量重扫生成。AI 禁止直接编辑此文件。
