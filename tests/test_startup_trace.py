from pathlib import Path
import runpy
import tempfile
import unittest

ROOT=Path(__file__).resolve().parents[1]
collect=runpy.run_path(str(ROOT/'Tools/dev/collect-startup-trace.py'))['collect']


class StartupTraceTests(unittest.TestCase):
    def test_complete_trace_records_redundant_requests(self):
        result=collect(ROOT/'evidence/sprint-4/startup-trace-dev4/probe.rpt')
        self.assertTrue(result['trace_complete'])
        self.assertEqual(result['normalized_missing_counts'],[0,0])
        self.assertEqual(result['native_result_counts'],[0,0])
        self.assertTrue(result['calls_after_start'])
        self.assertEqual(len(result['errors']),4)

    def test_truncated_first_attempt_not_accepted(self):
        self.assertFalse(collect(ROOT/'evidence/sprint-4/startup-trace-dev1-rejected/probe.rpt')['trace_complete'])

    def test_missing_completion_and_duplicates_rejected(self):
        source=(ROOT/'evidence/sprint-4/startup-trace-dev4/probe.rpt').read_text(encoding='utf-8')
        for altered in [source.replace('observation_complete','interrupted'),source+source]:
            with tempfile.TemporaryDirectory() as directory:
                path=Path(directory)/'probe.rpt';path.write_text(altered,encoding='utf-8')
                self.assertFalse(collect(path)['trace_complete'])


if __name__=='__main__':unittest.main()
