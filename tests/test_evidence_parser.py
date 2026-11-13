"""Regression cases taken from the dedicated combat log's SQF array format."""
from pathlib import Path
import runpy
import unittest

parse_array = runpy.run_path(str(Path(__file__).resolve().parents[1] / "Tools/dev/collect-probe.py"))["parse_array"]


class EvidenceParserTests(unittest.TestCase):
    def test_nested_side_values_from_damage_record(self):
        raw = '["check","combat_damage_observer",true,[[true,true],[["site",GUER,WEST,false,false]]]]'
        self.assertEqual(parse_array(raw), ["check", "combat_damage_observer", True,
                                          [[True, True], [["site", "GUER", "WEST", False, False]]]])

    def test_strings_keep_literal_backslashes_and_doubled_quotes(self):
        self.assertEqual(parse_array(r'["WEST \\folder\name ""quoted""",WEST]'),
                         [r'WEST \\folder\name "quoted"', "WEST"])

    def test_unknown_bare_tokens_are_rejected(self):
        with self.assertRaises(ValueError):
            parse_array('["check",UNEXPECTED_TOKEN,true]')


if __name__ == "__main__":
    unittest.main()
