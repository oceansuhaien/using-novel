import importlib.util
import tempfile
import unittest
from pathlib import Path


SCRIPT_PATH = Path("d:/code/uncompany/using-novel/skills/novel-book-scaffold/scripts/create_book_scaffold.py")
SPEC = importlib.util.spec_from_file_location("create_book_scaffold", SCRIPT_PATH)
MODULE = importlib.util.module_from_spec(SPEC)
assert SPEC.loader is not None
SPEC.loader.exec_module(MODULE)


class CreateBookScaffoldTests(unittest.TestCase):
    def test_dry_run_plans_context_md(self):
        with tempfile.TemporaryDirectory() as temp_dir:
            target, planned, skipped = MODULE.create_scaffold(
                title="测试书",
                root=Path(temp_dir),
                folder_id="demo-book",
                allow_existing=False,
                dry_run=True,
            )

            self.assertEqual(skipped, [])
            self.assertEqual(target, Path(temp_dir).resolve() / "test" / "books" / "demo-book")
            self.assertIn(target / "context.md", planned)


if __name__ == "__main__":
    unittest.main()
