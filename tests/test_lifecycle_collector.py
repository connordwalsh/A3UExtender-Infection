"""A deleted object must never gain kill credit from locality or later cleanup."""
from pathlib import Path
import runpy
import unittest

classify = runpy.run_path(str(Path(__file__).resolve().parents[1] / "Tools/dev/collect-lifecycle.py"))["classify"]
DELETED = [True, False, False, 0, 0, -1]
DEAD = [False, False, True, 2, 1, -1]


class LifecycleClassificationTests(unittest.TestCase):
    def test_deleted_nonlocal_object_without_kill(self):
        self.assertEqual(classify(DELETED, [["Deleted", 1, "trial", DEAD]]),
                         "deleted_without_recorded_death")

    def test_only_death_before_deletion_counts(self):
        killed = ["Killed", 1, "trial", DEAD]
        deleted = ["Deleted", 2, "trial", DEAD]
        self.assertEqual(classify(DELETED, [killed, deleted]), "deleted_after_recorded_death")
        self.assertEqual(classify(DELETED, [deleted, killed]), "deleted_without_recorded_death")

    def test_cleanup_death_never_counts_as_combat(self):
        self.assertEqual(classify(DELETED, [["Killed", 1, "cleanup", DEAD],
                                            ["Deleted", 2, "cleanup", DEAD]]),
                         "deleted_without_recorded_death")


if __name__ == "__main__":
    unittest.main()
