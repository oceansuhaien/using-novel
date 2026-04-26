from pathlib import Path
import unittest


SKILL_PATH = Path("skills/using-novel/SKILL.md")
AGENT_PATH = Path("skills/using-novel/agents/openai.yaml")
README_PATH = Path("README.md")
MANUAL_TEST_PATH = Path("test/books/demo-book/MANUAL-TEST.md")
CURRENT_BOOK_CONFIG_PATH = Path("test/current-book.yaml")


class UsingNovelSkillContractTests(unittest.TestCase):
    def test_skill_declares_mandatory_book_directory_scan_after_plot_rewrites(self):
        content = SKILL_PATH.read_text(encoding="utf-8")

        self.assertIn("剧情改写后的强制目录检查", content)
        self.assertIn("必须强制检查书籍目录里相关文件是否需要同步修改、补写或新增", content)
        self.assertIn("人物卡、关系卡、人物索引是否要跟着改", content)
        self.assertIn("plot/foreshadowing", content)
        self.assertIn("相关书籍目录文件是否需要修改、补写或新增", content)

    def test_skill_declares_automatic_post_scene_consistency_check(self):
        content = SKILL_PATH.read_text(encoding="utf-8")

        self.assertIn("自动执行一次人物一致性检查", content)
        self.assertIn("先列出 1 到 3 个问题点，再给修正版", content)
        self.assertIn("自动串行转 `novel-character-card-coach`", content)
        self.assertIn("自动串行转 `novel-plot-weaver`", content)

    def test_skill_declares_first_appearance_and_obvious_transition_checks(self):
        content = SKILL_PATH.read_text(encoding="utf-8")

        self.assertIn("首章、首场、新角色首次进场", content)
        self.assertIn("识别锚点是否足够", content)
        self.assertIn("角色发生明显转换时", content)
        self.assertIn("服侍关系、身份地位、情绪立场、性格表现", content)

    def test_skill_keeps_clothing_and_ability_checks_optional(self):
        content = SKILL_PATH.read_text(encoding="utf-8")

        self.assertIn("穿着、外貌呈现、能力边界可按需检查", content)
        self.assertIn("不是每轮默认硬性必检", content)

    def test_skill_does_not_escalate_minor_fluctuations_into_default_alerts(self):
        content = SKILL_PATH.read_text(encoding="utf-8")

        self.assertIn("不把所有轻微状态波动都升级成问题", content)

    def test_agent_metadata_mentions_automatic_post_scene_check(self):
        content = AGENT_PATH.read_text(encoding="utf-8")

        self.assertIn("强制检查书籍目录相关文件", content)
        self.assertIn("人物卡、关系卡、剧情节点、伏笔记录", content)
        self.assertIn("写剧情、续写、扩写、润色、改写", content)
        self.assertIn("自动检查人物一致性", content)
        self.assertIn("首次出场", content)
        self.assertIn("明显转换", content)
        self.assertIn("章节级执行证据", content)

    def test_skill_declares_scene_writer_must_leave_chapter_level_execution_evidence(self):
        content = SKILL_PATH.read_text(encoding="utf-8")

        self.assertIn("正文链路的执行留痕", content)
        self.assertIn("章节级执行证据", content)
        self.assertIn("不在这里维护完整审计模板", content)

    def test_skill_declares_test_mode_current_book_config_priority(self):
        content = SKILL_PATH.read_text(encoding="utf-8")

        self.assertIn("`test/current-book.yaml`", content)
        self.assertIn("显式指定的 book-id 仍然优先于配置文件", content)
        self.assertIn("读取 `test/current-book.yaml`", content)
        self.assertIn("配置文件存在但无效", content)
        self.assertIn("不能静默回退到 `demo-book`", content)
        self.assertIn("修正配置或显式指定 book-id", content)

    def test_docs_explain_test_mode_config_and_fallback(self):
        readme = README_PATH.read_text(encoding="utf-8")
        manual = MANUAL_TEST_PATH.read_text(encoding="utf-8")

        self.assertIn("`test/current-book.yaml`", readme)
        self.assertIn("显式 `book-id` > 配置文件 > `demo-book`", readme)
        self.assertIn("`test/current-book.yaml`", manual)
        self.assertIn("配置文件不存在时，才回退到 `test/books/demo-book/`", manual)
        self.assertIn("配置文件存在但无效时，应停下来提示", manual)

    def test_repo_provides_default_test_mode_current_book_config(self):
        content = CURRENT_BOOK_CONFIG_PATH.read_text(encoding="utf-8")

        self.assertIn("book_id: demo-book", content)


if __name__ == "__main__":
    unittest.main()
