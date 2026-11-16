from pathlib import Path
import runpy
import tempfile
import unittest

module=runpy.run_path(str(Path(__file__).resolve().parents[1]/'Tools/dev/collect-casualty-save.py'))
class CasualtySaveEvidence(unittest.TestCase):
    def report(self,extra='',omit=None,finish=True,phase='write',collect_phase=None):
        names=sorted(module['EXPECTED'][phase]-{omit})
        text='[INFECTION_CASUALTY_SAVE] start\n'
        text+='\n'.join(f'[INFECTION_CASUALTY_SAVE] ["check","{name}",true,[]]' for name in names)
        if finish:text+=f'\n[INFECTION_CASUALTY_SAVE] ["complete",{len(names)},[]]'
        with tempfile.TemporaryDirectory() as directory:
            path=Path(directory)/'test.rpt';path.write_text(text+'\n'+extra)
            return module['collect'](path,collect_phase or phase)
    def test_complete(self):self.assertEqual(self.report()['status'],'passed')
    def test_missing_check(self):self.assertEqual(self.report(omit='write_saved_reduced_roster')['status'],'failed')
    def test_duplicate_check(self):self.assertEqual(self.report('[INFECTION_CASUALTY_SAVE] ["check","write_receipt_valid",true,[]]')['status'],'failed')
    def test_error_retained(self):self.assertEqual(self.report('ERROR: unexpected')['status'],'failed')
    def test_incomplete(self):self.assertEqual(self.report(finish=False)['status'],'incomplete')
    def test_read_complete(self):self.assertEqual(self.report(phase='read')['status'],'passed')
    def test_wrong_phase(self):self.assertEqual(self.report(collect_phase='read')['status'],'failed')

if __name__=='__main__':unittest.main()
