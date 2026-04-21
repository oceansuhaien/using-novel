# Novel Driver

`novel-driver` 是一个可安装的 Codex 插件，用于中文网文开发流程。

它把大纲、剧情、人物和共享 canon 规则拆成多个聚焦技能，避免把故事工作区误当成插件仓库的一部分。

## 安装

把仓库克隆到本地插件目录：

```powershell
git clone <repo-url-or-local-path> C:\path\to\plugins\novel-driver
```

在 marketplace 配置里注册为本地插件源：

```json
{
  "plugins": [
    {
      "name": "novel-driver",
      "source": {
        "source": "local",
        "path": "C:/path/to/plugins/novel-driver"
      },
      "policy": {
        "installation": "AVAILABLE",
        "authentication": "ON_INSTALL"
      },
      "category": "Writing"
    }
  ]
}
```

## 命令

- `/using-novel`：为混合或不明确的小说开发请求自动分流，也可先分流到建书脚手架。
- `/novel-outline`：直接处理题材前提、大纲、卷纲和世界观结构。
- `/novel-plot`：直接处理剧情节点、悬念、反转、伏笔和推进修复。
- `/novel-character`：直接处理人物卡、关系卡、人物弧线和人物总表。

## 仓库结构

```text
novel-driver/
|- .codex-plugin/          插件元数据
|- assets/                 图标和展示资源
|- commands/               轻量命令适配层
|- evals/                  手工回归用例
|- scripts/                校验和同步脚本
|- skills/                 技能创作唯一事实来源
|- AGENTS.md               插件维护规则
|- CLAUDE.md               Claude 适配入口
|- README.md               安装和开发说明
```

## 开发

校验插件结构：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\quick-validate.ps1
```

列出手工评测用例：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\run-evals.ps1
```

预览单向同步到另一个技能目录：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\sync-to-codex-skills.ps1 -TargetRoot C:\path\to\skills-mirror
```

确认执行同步：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\sync-to-codex-skills.ps1 -TargetRoot C:\path\to\skills-mirror -Apply
```

## 非目标

- 这不是故事项目仓库。
- 本仓库不保存故事资料或故事状态目录。
- 本仓库不保存 `.omx` 或 `.omc` 运行时状态。
- `.codex/skills/` 镜像是生成产物，不是创作源目录。
