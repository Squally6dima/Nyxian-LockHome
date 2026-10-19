import importlib.util
import unittest
from pathlib import Path

SCRIPT = Path(__file__).resolve().parents[1] / "Tools" / "apply-host-patch.py"
SPEC = importlib.util.spec_from_file_location("apply_host_patch", SCRIPT)
MODULE = importlib.util.module_from_spec(SPEC)
assert SPEC.loader is not None
SPEC.loader.exec_module(MODULE)


class PatchScriptTests(unittest.TestCase):
    def test_anchors_are_unique_in_fixture(self):
        fixture = MODULE.IMPORT_ANCHOR + "\n@implementation NXWindowServer\n"
        fixture += "- (void)makeKeyAndVisible {\n"
        fixture += MODULE.FRONT_ANCHOR + "\n"
        self.assertEqual(fixture.count(MODULE.IMPORT_ANCHOR), 1)
        self.assertEqual(fixture.count(MODULE.FRONT_ANCHOR), 1)

    def test_patch_markers_are_distinct(self):
        self.assertNotEqual(MODULE.IMPORT_LINE, MODULE.HOOK_LINE)
        self.assertIn("nx_showLockHomeOnFirstPresentation", MODULE.HOOK_LINE)


if __name__ == "__main__":
    unittest.main()
