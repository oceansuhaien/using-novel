---
description: "把小说开发请求分流到建书脚手架、大纲、剧情、人物或共享规则技能，并在当前技能完成后继续检查是否需要补齐相关设定与落盘。用法：/using-novel 先帮我创建一本新书工作区，再整理成可连载大纲。"
disable-model-invocation: true
---
调用 `novel-driver:using-novel` 技能，并严格遵循该技能。
如果用户在 `/using-novel` 后没有提供具体小说任务，询问他们想先处理哪个故事问题，或者是否要先创建单本书工作区。
