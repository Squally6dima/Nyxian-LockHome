import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
PATCHER = REPO_ROOT / "Tools" / "apply_nyxian_patch.py"
SERVER_REL = Path("Nyxian/LindChain/WindowServer/NXWindowServer.m")
ANCHOR = "    [_windowLayer setUserInteractionEnabled:YES];"
IMPORT = '#import <LindChain/WindowServer/LockHome/NXWindowServer+LockHome.h>'
HOOK = "    [self nx_showLockHomeOnFirstPresentation];"


class PatcherTests(unittest.TestCase):
    def make_fixture(self, root: Path) -> Path:
        server = root / SERVER_REL
        server.parent.mkdir(parents=True)
        server.write_text(
            '#import <UIKit/UIKit.h>\n'
            '@implementation NXWindowServer\n'
            '- (void)makeKeyAndVisible {\n'
            + ANCHOR + '\n'
            '}\n@end\n',
            encoding="utf-8",
        )
        return server

    def run_patcher(self, root: Path, *args: str) -> subprocess.CompletedProcess:
        return subprocess.run(
            [sys.executable, str(PATCHER), str(root), *args],
            text=True,
            capture_output=True,
            check=False,
        )

    def test_dry_run_does_not_modify_source(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            server = self.make_fixture(root)
            before = server.read_text(encoding="utf-8")
            result = self.run_patcher(root, "--dry-run")
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(server.read_text(encoding="utf-8"), before)
            self.assertFalse((server.parent / "LockHome").exists())

    def test_apply_and_repeat_are_idempotent(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            server = self.make_fixture(root)
            first = self.run_patcher(root)
            self.assertEqual(first.returncode, 0, first.stderr)
            patched = server.read_text(encoding="utf-8")
            self.assertEqual(patched.count(IMPORT), 1)
            self.assertEqual(patched.count(HOOK), 1)
            for filename in (
                "NXLockHomeOverlayView.h",
                "NXLockHomeOverlayView.m",
                "NXWindowServer+LockHome.h",
                "NXWindowServer+LockHome.m",
            ):
                self.assertTrue((server.parent / "LockHome" / filename).is_file())

            second = self.run_patcher(root)
            self.assertEqual(second.returncode, 0, second.stderr)
            self.assertEqual(server.read_text(encoding="utf-8"), patched)

    def test_missing_anchor_refuses_without_copying(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            server = self.make_fixture(root)
            server.write_text("@implementation NXWindowServer\n@end\n", encoding="utf-8")
            result = self.run_patcher(root)
            self.assertEqual(result.returncode, 5)
            self.assertFalse((server.parent / "LockHome").exists())


if __name__ == "__main__":
    unittest.main()
