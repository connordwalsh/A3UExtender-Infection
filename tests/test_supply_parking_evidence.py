from pathlib import Path
import runpy
import tempfile
import unittest

collect = runpy.run_path(str(Path(__file__).resolve().parents[1] / 'Tools/dev/collect-supply-parking.py'))['collect']


class ParkingEvidence(unittest.TestCase):
    def report(self, available=True, omit=False, extra='', valid=True):
        rows = ['["start","chernarusredux",1]', '["planned","milbase","fuel","truck"]']
        result = '["result","milbase","fuel","truck",%s,%s,[%s,0],0.1]' % (str(available).lower(), str(valid).lower(), '[1000,2000,0]' if available else '[]')
        if not omit:
            rows.append(result)
        rows.append('["complete",1,%d,%d,%d]' % (available, not available, not valid))
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / 'probe.rpt'
            path.write_text('\n'.join('[INFECTION_SUPPLY_PARKING] ' + r for r in rows) + '\n' + extra)
            return collect(path)

    def test_complete(self): self.assertEqual(self.report()['status'], 'complete')
    def test_missing_result(self): self.assertEqual(self.report(omit=True)['status'], 'failed')
    def test_invalid_position(self): self.assertEqual(self.report(valid=False)['status'], 'failed')
    def test_errors_retained(self): self.assertEqual(self.report(extra='Error: native failure')['status'], 'failed')
    def test_duplicate_result(self):
        extra = '[INFECTION_SUPPLY_PARKING] ["result","milbase","fuel","truck",true,true,[[1000,2000,0],0],0.1]'
        self.assertEqual(self.report(extra=extra)['status'], 'failed')
    def test_unavailable_preserved(self):
        report = self.report(available=False)
        self.assertEqual(report['status'], 'complete')
        self.assertEqual(report['unavailable'], [['milbase', 'fuel', 'truck']])


if __name__ == '__main__': unittest.main()
