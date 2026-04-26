from pathlib import Path
import unittest


SCENE_SKILL_PATH = Path("skills/novel-scene-writer/SKILL.md")
SCENE_AGENT_PATH = Path("skills/novel-scene-writer/agents/openai.yaml")
SYSTEM_SKILL_PATH = Path("skills/novel-system-reference/SKILL.md")
CONTEXT_PROTOCOL_PATH = Path(
    "skills/novel-system-reference/references/context-log-protocol.md"
)
DIRECTORY_CONTRACT_PATH = Path(
    "skills/novel-system-reference/references/directory-contract.md"
)
USING_NOVEL_PATH = Path("skills/using-novel/SKILL.md")


class NovelSceneAuditContractTests(unittest.TestCase):
    def test_scene_writer_declares_complete_audit_for_direct_and_routed_requests(self):
        content = SCENE_SKILL_PATH.read_text(encoding="utf-8")

        self.assertIn("完整审计记录", content)
        self.assertIn("direct", content)
        self.assertIn("using-novel", content)
        self.assertIn("都必须留下", content)

    def test_scene_writer_keeps_audit_records_out_of_default_user_visible_reply(self):
        skill = SCENE_SKILL_PATH.read_text(encoding="utf-8")
        agent = SCENE_AGENT_PATH.read_text(encoding="utf-8")

        self.assertIn("默认不直接展示给用户", skill)
        self.assertIn("只有用户显式要求查看原因或开发调试时", skill)
        self.assertNotIn("默认附带完整审计", agent)

    def test_shared_protocol_places_execution_audit_in_chapter_level_evidence_location(self):
        protocol = CONTEXT_PROTOCOL_PATH.read_text(encoding="utf-8")
        directory_contract = DIRECTORY_CONTRACT_PATH.read_text(encoding="utf-8")

        self.assertIn("执行证据", protocol)
        self.assertIn("章节级证据", protocol)
        self.assertIn("chapters/notes/", protocol)
        self.assertIn("chapters/", directory_contract)
        self.assertIn("证据", directory_contract)

    def test_shared_protocol_keeps_context_and_summary_out_of_full_execution_audit_body(self):
        protocol = CONTEXT_PROTOCOL_PATH.read_text(encoding="utf-8")
        directory_contract = DIRECTORY_CONTRACT_PATH.read_text(encoding="utf-8")

        self.assertIn("不写进 `context.md` / `summary.md` 主体", protocol)
        self.assertIn("`context.md`", directory_contract)
        self.assertIn("`summary.md`", directory_contract)

    def test_shared_protocol_declares_audit_filename_convention_and_template_fields(self):
        protocol = CONTEXT_PROTOCOL_PATH.read_text(encoding="utf-8")

        self.assertIn("scene-audit-", protocol)
        self.assertIn("任务类型", protocol)
        self.assertIn("触发原因", protocol)
        self.assertIn("读取的上下文", protocol)
        self.assertIn("首次出场 / 识别锚点检查", protocol)
        self.assertIn("判定理由", protocol)
        self.assertIn("后续动作", protocol)

    def test_system_reference_exposes_scene_audit_protocol_as_shared_rule(self):
        content = SYSTEM_SKILL_PATH.read_text(encoding="utf-8")

        self.assertIn("正文执行审计", content)
        self.assertIn("`references/context-log-protocol.md`", content)

    def test_using_novel_only_passes_audit_constraint_without_becoming_audit_center(self):
        content = USING_NOVEL_PATH.read_text(encoding="utf-8")

        self.assertIn("章节级执行证据", content)
        self.assertIn("遵守", content)
        self.assertNotIn("完整审计模板", content)

    def test_scene_writer_declares_same_audit_filename_convention_for_writes(self):
        content = SCENE_SKILL_PATH.read_text(encoding="utf-8")

        self.assertIn("scene-audit-", content)
        self.assertIn("YYYYMMDD-", content)


if __name__ == "__main__":
    unittest.main()
