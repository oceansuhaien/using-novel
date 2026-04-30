# Scene Writing Eval Cases

用于验证场景写作 5 步循环（plan-slice → draft → polish → expand → rewrite → finalize）。

## plan-slice

| Case | 作者输入 | 预期 |
| --- | --- | --- |
| 新场景缺在场者 | "写第 7 章，主角到茶棚。" | 先问"这场要见谁"，不凭空造 |
| 新场景完整 | "主角到茶棚见老周，马蹄声响起时推开门。" | 产 slice.yaml 含 env + on_stage + trigger + intent |
| 关系网不爆 | 切片 on_stage 只 2 人 | `relations_with` 只列在场者，不带全书 |
| 作者过切片 | plan-slice 产完 | 停下来等作者确认，不自动进 draft |

## draft

| Case | 输入 | 预期 |
| --- | --- | --- |
| 只读 slice 字段 | slice 列了 3 个字段 | draft 不读 slice 外的 plot/outline |
| 首次识别两个锚点 | 新角色 on_stage | 一句内给关系/身份 + 外在特征两个锚点 |
| 字段不够回调 plan-slice | draft 发现需要一个 state 字段没加载 | 回调产 vNNN+1-slice，不硬编 |
| 去 AI 味 | 初稿包含"气氛变得微妙" | 自查时改为动作/反应细节 |
| 画面感有落点 | 情绪段 | 用动作/视线/声音/环境压迫托底，不是纯形容词 |
| 张力不靠喊 | 对峙/冲突段 | 优先靠信息差/关系失衡/说不出口的话，不靠大声对骂 |
| 情绪落到身体 | 关键情绪点 | 落到念头/身体反应/外部反应/微动作克制，不用纯情绪词 |
| 长度服务节奏 | intent.length_hint 未指定 | 长度按场景节奏/情绪曲线自然收束，不为凑/压字数偏离意图 |

## polish

| Case | 输入 | 预期 |
| --- | --- | --- |
| 禁止改事件 | 作者说"对白再自然点" | 事件结果不变，仅改字句节奏 |
| 边界越界提示 | 作者说"顺便让她这里犹豫" | 提示"这看起来是 rewrite 意图" |
| 长度随改动起伏 | polish 产出 | 不做 ±N% 字数校验；只要事件主干、角色决定、场景结构未动即通过 |
| 文风达标 | polish 产出 | 画面感/张力/情绪比上一版不退步，AI 味减少 |
| 改动要点回报 | polish 结束 | 给 1-3 点 summary |

## expand

| Case | 输入 | 预期 |
| --- | --- | --- |
| 加内心戏不越权 | state 写"警觉但未确定" | 扩写不能升级为"已确定" |
| 环境描写从 slice 出发 | 作者"加环境描写" | 从 slice.env.ambient 挑元素，不凭空造 |
| 不越界到 rewrite | 作者要求大量扩写 | 事件不变即可继续；一旦必须动事件才能加 → 停下提示改走 rewrite |
| 加料有落点 | 扩写段 | 新增段落有动作/视线/声音/感官/身体反应落点，不堆空形容词 |

## rewrite

| Case | 输入 | 预期 |
| --- | --- | --- |
| 必须回调 plan-slice | 作者"整段重写" | 产新 slice（vNNN+1-slice） |
| 不自动覆盖工作台 | rewrite 产出 | 只进版本链，工作台保留上一版 |
| 对比要点 | rewrite 回报 | 给出"相对 v(N-1) 的关键改动" |
| 作者 sync 后才应用 | rewrite 产 v004 | 作者运行 `draft-sync.sh ... 4` 才覆盖工作台 |
| 轻微改动引回 polish | rewrite 发现只改字句 | 引导作者转 polish |

## finalize

| Case | 输入 | 预期 |
| --- | --- | --- |
| 定稿 + 状态回写 | `/finalize ch007` | 定稿层更新 + 逐角色 diff 确认 |
| forced 场景跳过回写 | forced=true 的场景 finalize | 打印 SKIP_STATE_REWRITE |
| 补触发 | forced finalize 后 | `/rewrite-state ch007` 可补触发 |
