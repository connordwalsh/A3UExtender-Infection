"""A completed campaign report must not hide native errors or missing checks."""
from pathlib import Path
import runpy
import tempfile
import unittest

module=runpy.run_path(str(Path(__file__).resolve().parents[1]/"Tools/dev/collect-campaign.py"))
collect=module["collect"]
expected=module["EXPECTED"]["write"]

class CampaignEvidenceTests(unittest.TestCase):
    def report(self, extra="", omit_complete=False, duplicate=False):
        rows=['[INFECTION_CAMPAIGN] ["start","write","chernarusredux",[],[]]']
        rows += [f'[INFECTION_CAMPAIGN] ["check","{key}",true,[]]' for key in sorted(expected)]
        if duplicate:
            rows.append(rows[-1])
        if not omit_complete:
            rows.append(f'[INFECTION_CAMPAIGN] ["complete","write",{len(expected)},[]]')
        with tempfile.TemporaryDirectory() as directory:
            path=Path(directory)/"test.rpt"
            path.write_text("\n".join(rows)+"\n"+extra,encoding="utf-8")
            return collect(path,"write")

    def test_clean_complete_report_passes(self):
        self.assertEqual(self.report()["status"],"passed")

    def test_native_error_rejects_passing_assertions(self):
        result=self.report('00:00:00 | Antistasi | Error | File: vehiclePrice | invalid price')
        self.assertEqual(result["status"],"failed")
        self.assertTrue(result["checks"]["runtime_checks_pass"])

    def test_missing_completion_is_incomplete(self):
        self.assertEqual(self.report(omit_complete=True)["status"],"incomplete")

    def test_duplicate_cannot_replace_missing_evidence(self):
        self.assertEqual(self.report(duplicate=True)["status"],"failed")
