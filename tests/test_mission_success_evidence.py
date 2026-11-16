from pathlib import Path
import runpy
import tempfile
import unittest

module=runpy.run_path(str(Path(__file__).resolve().parents[1]/'Tools/dev/collect-success-missions.py'))
class MissionSuccessEvidence(unittest.TestCase):
    def report(self,extra='',omit=None,finish=True):
        names=sorted(module['EXPECTED']-{omit})
        text='[INFECTION_MISSION_SUCCESS] start\n'
        text+='\n'.join(f'[INFECTION_MISSION_SUCCESS] ["check","{name}",true,[]]' for name in names)
        if finish:text+=f'\n[INFECTION_MISSION_SUCCESS] ["complete",{len(names)},[]]'
        with tempfile.TemporaryDirectory() as directory:
            path=Path(directory)/'test.rpt';path.write_text(text+'\n'+extra)
            return module['collect'](path)
    def test_complete(self):self.assertEqual(self.report()['status'],'passed')
    def test_missing_check(self):self.assertEqual(self.report(omit='elim_assets_cleaned')['status'],'failed')
    def test_duplicate_check(self):self.assertEqual(self.report('[INFECTION_MISSION_SUCCESS] ["check","elim_eligible",true,[]]')['status'],'failed')
    def test_error_retained(self):self.assertEqual(self.report('ERROR: unexpected')['status'],'failed')
    def test_incomplete(self):self.assertEqual(self.report(finish=False)['status'],'incomplete')
if __name__=='__main__':unittest.main()
