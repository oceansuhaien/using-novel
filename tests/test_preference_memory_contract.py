from pathlib import Path
import unittest


USING_NOVEL_PATH = Path("skills/using-novel/SKILL.md")
USING_NOVEL_AGENT_PATH = Path("skills/using-novel/agents/openai.yaml")
SYSTEM_SKILL_PATH = Path("skills/novel-system-reference/SKILL.md")
CONTEXT_PROTOCOL_PATH = Path(
    "skills/novel-system-reference/references/context-log-protocol.md"
)
PREFERENCE_PROTOCOL_PATH = Path(
    "skills/novel-system-reference/references/preference-memory-protocol.md"
)


class PreferenceMemoryContractTests(unittest.TestCase):
    def test_shared_reference_exposes_preference_memory_protocol(self):
        skill = SYSTEM_SKILL_PATH.read_text(encoding="utf-8")

        self.assertIn("偏好记忆", skill)
        self.assertIn("`references/preference-memory-protocol.md`", skill)

    def test_preference_memory_protocol_defines_dual_layer_rules(self):
        protocol = PREFERENCE_PROTOCOL_PATH.read_text(encoding="utf-8")

        self.assertIn("作者级", protocol)
        self.assertIn("单书级", protocol)
        self.assertIn("跨书", protocol)
        self.assertIn("只对当前书生效", protocol)

    def test_preference_memory_protocol_distinguishes_candidate_and_stable_rules(self):
        protocol = PREFERENCE_PROTOCOL_PATH.read_text(encoding="utf-8")

        self.assertIn("候选经验", protocol)
        self.assertIn("稳定规则", protocol)
        self.assertIn("默认只作为软提醒", protocol)
        self.assertIn("用户确认后", protocol)

    def test_preference_memory_protocol_declares_evidence_based_intercept_boundary(self):
        protocol = PREFERENCE_PROTOCOL_PATH.read_text(encoding="utf-8")

        self.assertIn("高置信", protocol)
        self.assertIn("证据链", protocol)
        self.assertIn("直接拦截", protocol)
        self.assertIn("模糊感觉不对", protocol)
        self.assertIn("只能提醒", protocol)

    def test_preference_memory_protocol_keeps_long_term_memory_brief(self):
        protocol = PREFERENCE_PROTOCOL_PATH.read_text(encoding="utf-8")

        self.assertIn("短格式", protocol)
        self.assertIn("节约 token", protocol)
        self.assertIn("最短相关摘要", protocol)

    def test_context_protocol_points_preference_rules_to_dedicated_protocol(self):
        protocol = CONTEXT_PROTOCOL_PATH.read_text(encoding="utf-8")

        self.assertIn("作者级偏好", protocol)
        self.assertIn("不属于 `context.md` 的主体协议", protocol)
        self.assertIn("`preference-memory-protocol.md`", protocol)

    def test_using_novel_declares_preference_memory_read_write_workflow(self):
        skill = USING_NOVEL_PATH.read_text(encoding="utf-8")

        self.assertIn("偏好记忆", skill)
        self.assertIn("作者级稳定规则", skill)
        self.assertIn("单书级稳定规则", skill)
        self.assertIn("候选经验", skill)
        self.assertIn("任务前", skill)
        self.assertIn("任务后", skill)

    def test_using_novel_keeps_candidate_rules_non_binding_until_confirmed(self):
        skill = USING_NOVEL_PATH.read_text(encoding="utf-8")

        self.assertIn("默认只作为软提醒", skill)
        self.assertIn("不能自动升级为稳定规则", skill)

    def test_using_novel_agent_metadata_mentions_preference_memory_gate(self):
        agent = USING_NOVEL_AGENT_PATH.read_text(encoding="utf-8")

        self.assertIn("偏好记忆", agent)
        self.assertIn("候选经验", agent)
        self.assertIn("稳定规则", agent)
        self.assertIn("高置信", agent)


if __name__ == "__main__":
    unittest.main()
