from pathlib import Path
import unittest


USING_NOVEL_PATH = Path("skills/using-novel/SKILL.md")
USING_NOVEL_AGENT_PATH = Path("skills/using-novel/agents/openai.yaml")
SCENE_WRITER_PATH = Path("skills/novel-scene-writer/SKILL.md")
SYSTEM_SKILL_PATH = Path("skills/novel-system-reference/SKILL.md")
DIRECTORY_CONTRACT_PATH = Path(
    "skills/novel-system-reference/references/directory-contract.md"
)
CONTEXT_PROTOCOL_PATH = Path(
    "skills/novel-system-reference/references/context-log-protocol.md"
)
REWRITE_BRANCH_PROTOCOL_PATH = Path(
    "skills/novel-system-reference/references/rewrite-branch-protocol.md"
)
AFFECTED_PACKAGE_PROTOCOL_PATH = Path(
    "skills/novel-system-reference/references/affected-file-package-protocol.md"
)


class RewriteBranchContractTests(unittest.TestCase):
    def test_shared_reference_exposes_rewrite_branch_protocols(self):
        skill = SYSTEM_SKILL_PATH.read_text(encoding="utf-8")

        self.assertIn("改稿分支", skill)
        self.assertIn("受影响文件包", skill)
        self.assertIn("`references/rewrite-branch-protocol.md`", skill)
        self.assertIn("`references/affected-file-package-protocol.md`", skill)

    def test_directory_contract_declares_branch_and_package_related_locations(self):
        contract = DIRECTORY_CONTRACT_PATH.read_text(encoding="utf-8")

        self.assertIn("主线", contract)
        self.assertIn("改稿分支", contract)
        self.assertIn("受影响文件包", contract)

    def test_context_protocol_declares_mainline_and_branch_separation(self):
        protocol = CONTEXT_PROTOCOL_PATH.read_text(encoding="utf-8")

        self.assertIn("主线", protocol)
        self.assertIn("改稿分支", protocol)
        self.assertIn("不边改边局部回灌主线", protocol)

    def test_rewrite_branch_protocol_defines_lightweight_branch_and_merge_boundary(self):
        protocol = REWRITE_BRANCH_PROTOCOL_PATH.read_text(encoding="utf-8")

        self.assertIn("轻量版本分支", protocol)
        self.assertIn("冻结仅读", protocol)
        self.assertIn("整包确认后", protocol)
        self.assertIn("一次性合并回主线", protocol)
        self.assertIn("不自动全书联动改写", protocol)

    def test_affected_file_package_protocol_defines_package_scope_and_dependency(self):
        protocol = AFFECTED_PACKAGE_PROTOCOL_PATH.read_text(encoding="utf-8")

        self.assertIn("受影响文件包", protocol)
        self.assertIn("章节", protocol)
        self.assertIn("人物卡", protocol)
        self.assertIn("plot", protocol)
        self.assertIn("context.md", protocol)
        self.assertIn("跨包依赖", protocol)

    def test_using_novel_declares_branch_first_rewrite_flow(self):
        skill = USING_NOVEL_PATH.read_text(encoding="utf-8")

        self.assertIn("轻量版本分支", skill)
        self.assertIn("影响面分析", skill)
        self.assertIn("受影响文件包", skill)
        self.assertIn("不自动大面积改写", skill)
        self.assertIn("一次性合并回主线", skill)

    def test_using_novel_agent_metadata_mentions_rewrite_branch_model(self):
        agent = USING_NOVEL_AGENT_PATH.read_text(encoding="utf-8")

        self.assertIn("轻量版本分支", agent)
        self.assertIn("受影响文件包", agent)
        self.assertIn("影响面分析", agent)
        self.assertIn("合并回主线", agent)

    def test_scene_writer_declares_branch_reads_current_branch_context_not_old_mainline_by_default(self):
        skill = SCENE_WRITER_PATH.read_text(encoding="utf-8")

        self.assertIn("改稿分支", skill)
        self.assertIn("当前有效改稿事实", skill)
        self.assertIn("旧主线", skill)
        self.assertIn("不再默认作为当前有效写作输入", skill)


if __name__ == "__main__":
    unittest.main()
