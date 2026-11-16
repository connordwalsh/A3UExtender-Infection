"""Collect real-campaign forced-spawn lifecycle checks without suppressing errors."""
from collections import Counter
import argparse
import hashlib
import json
from pathlib import Path
import re
import runpy

parse_array=runpy.run_path(str(Path(__file__).with_name('collect-probe.py')))['parse_array']
EXPECTED={'eligible_targets','public_dispatch','task_registered','infected_target','native_package',
 'native_task_created','hq_package_paused','native_town_capture','ownership_cancelled','native_cleanup',
 'native_task_removed','supply_lock_released','no_support_penalty','no_resource_penalty',
 'captured_town_ineligible','hq_intact'}

SUCCESS_EXPECTED={'eligible_targets','public_dispatch','task_registered','infected_target','native_package',
 'native_task_created','hq_package_paused','capable_native_escort','escort_activates_town','full_town_population',
 'nearby_infected_pause','town_clearance','clearance_resumes_unloading','native_unloading_succeeded',
 'timer_not_shortened','native_task_succeeded','native_support_reward','package_cleanup','supply_lock_released',
 'reward_stable','town_despawns_after_escort','escort_cleanup','hq_intact'}

def collect(path,success=False):
    expected=SUCCESS_EXPECTED if success else EXPECTED
    raw=Path(path).read_bytes();checks=[];finishes=[];errors=[];malformed=[];starts=0
    for number,line in enumerate(raw.decode('utf-8-sig',errors='replace').splitlines(),1):
        if re.search(r'\bError(?::|\s+(?:in expression|Undefined|Missing|Generic|Type))|\| Error \|',line,re.I):errors.append({'line':number,'message':line})
        if '[INFECTION_CAMPAIGN_AID] ' not in line:continue
        payload=line.split('[INFECTION_CAMPAIGN_AID] ',1)[1].strip()
        if payload.rstrip('"')=='start':starts+=1;continue
        if payload.endswith('"'):payload=payload[:-1].replace('""','"')
        try:
            row=parse_array(payload)
            if len(row)==4 and row[0]=='check' and isinstance(row[1],str) and type(row[2]) is bool and isinstance(row[3],list):checks.append(row)
            elif len(row)==3 and row[0]=='complete' and type(row[1]) is int and isinstance(row[2],list):finishes.append(row)
            else:raise ValueError('Malformed lifecycle record')
        except (ValueError,TypeError):malformed.append(number)
    failed=[r[1] for r in checks if not r[2]]
    valid={'one_run':starts==len(finishes)==1,'schema':not malformed,
           'expected_checks_once':Counter(r[1] for r in checks)==Counter(expected),
           'checks_pass':not failed,'no_engine_or_native_errors':not errors,
           'complete_matches':len(finishes)==1 and finishes[0][1:]==[len(checks),failed]}
    return {'status':'passed' if all(valid.values()) else 'failed' if finishes else 'incomplete',
            'scope':('Native Aid controlled delivery, real AI town activation, controlled clearance and unshortened unloading/rewards; not player transport, combat, UI or multiplayer acceptance' if success else 'Native Aid request, HQ package, Invader town capture cancellation and cleanup; not unloading, player transport, UI or multiplayer acceptance'),
            'source_log_sha256':hashlib.sha256(raw).hexdigest(),'validation':valid,'records':checks,'failed':failed,'errors':errors,'malformed':malformed}

if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('log');parser.add_argument('output');parser.add_argument('--success',action='store_true');args=parser.parse_args()
    report=collect(args.log,args.success);Path(args.output).write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps({'status':report['status'],'checks':len(report['records']),'failed':report['failed'],'errors':len(report['errors'])}))
    raise SystemExit(0 if report['status']=='passed' else 1)
