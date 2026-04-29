---
description: "进入小说场景写作循环，由入口集中识别意图（写新场景→plan-slice+draft；改字句→polish；加细节→expand；改事件/结构→rewrite；定稿→finalize；回滚→rollback）。用户自然语言表达即可，不需记命令。"
disable-model-invocation: true
---
调用 `novel-driver:using-novel` 技能，让它按意图识别表把本轮请求路由到对应的场景子技能或草稿协议操作。
如果用户没有提供具体场景、片段或操作意图，询问他们现在想写新场景、润色已有章节、扩写细节、重写结构、定稿，还是回滚。
