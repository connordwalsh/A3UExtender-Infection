from pathlib import Path
import runpy
import tempfile
import unittest

module=runpy.run_path(str(Path(__file__).resolve().parents[1]/'Tools/dev/collect-campaign-extraction.py'))
class CampaignExtractionEvidence(unittest.TestCase):
    def report(self,extra='',omit=None,finish=True,success=False,mixed=False):
        names=sorted(module['MIXED_EXPECTED' if mixed else 'SUCCESS_EXPECTED' if success else 'EXPECTED']-{omit})
        text='[INFECTION_CAMPAIGN_EXTRACTION] start\n'
        text+='\n'.join(f'[INFECTION_CAMPAIGN_EXTRACTION] ["check","{name}",true,[]]' for name in names)
        if finish:text+=f'\n[INFECTION_CAMPAIGN_EXTRACTION] ["complete",{len(names)},[]]'
        with tempfile.TemporaryDirectory() as directory:
            path=Path(directory)/'test.rpt';path.write_text(text+'\n'+extra)
            return module['collect'](path,success,mixed)
    def test_mixed_complete(self):self.assertEqual(self.report(mixed=True)['status'],'passed')
    def test_mixed_missing(self):self.assertEqual(self.report(mixed=True,omit='mixed_resolved_succeeded')['status'],'failed')
    def test_mixed_error(self):self.assertEqual(self.report('Error in expression',mixed=True)['status'],'failed')
    def test_mixed_duplicate(self):self.assertEqual(self.report('[INFECTION_CAMPAIGN_EXTRACTION] ["check","mixed_resolved_succeeded",true,[]]',mixed=True)['status'],'failed')
    def test_mixed_incomplete(self):self.assertEqual(self.report(mixed=True,finish=False)['status'],'incomplete')
    def test_success_complete(self):self.assertEqual(self.report(success=True)['status'],'passed')
    def test_success_missing(self):self.assertEqual(self.report(success=True,omit='incremental_manpower_exact')['status'],'failed')
    def test_success_incomplete(self):self.assertEqual(self.report(success=True,finish=False)['status'],'incomplete')
    def test_success_error(self):self.assertEqual(self.report('Error in expression',success=True)['status'],'failed')
    def test_success_duplicate(self):self.assertEqual(self.report('[INFECTION_CAMPAIGN_EXTRACTION] ["check","trusted_releases_accepted",true,[]]',success=True)['status'],'failed')
    def test_complete(self):self.assertEqual(self.report()['status'],'passed')
    def test_missing_check(self):self.assertEqual(self.report(omit='native_delayed_asset_cleanup')['status'],'failed')
    def test_duplicate_check(self):self.assertEqual(self.report('[INFECTION_CAMPAIGN_EXTRACTION] ["check","eligible_targets",true,[]]')['status'],'failed')
    def test_error_retained(self):self.assertEqual(self.report('ERROR: unexpected')['status'],'failed')
    def test_incomplete(self):self.assertEqual(self.report(finish=False)['status'],'incomplete')
if __name__=='__main__':unittest.main()
