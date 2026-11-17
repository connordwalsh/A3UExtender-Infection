"""Collect real-campaign forced-spawn lifecycle checks without suppressing errors."""
from collections import Counter
import argparse
import hashlib
import json
from pathlib import Path
import re
import runpy

parse_array=runpy.run_path(str(Path(__file__).with_name('collect-probe.py')))['parse_array']
EXPECTED={'eligible_targets','public_dispatch','task_registered','source_eligible',
          'survivor_contract','guard_contract','native_task_created','all_dead_failed',
          'native_task_failed','no_rescue_credit','native_delayed_asset_cleanup','budget_released','hq_intact'}

SUCCESS_EXPECTED=(EXPECTED-{'all_dead_failed','native_task_failed','no_rescue_credit'}) | {
    'server_ai_rescuer','public_player_action_rejects_ai','trusted_releases_accepted',
    'survivors_join_ai_group','native_recruit_initialization','delivered_survivors_removed',
    'partial_rescues_keep_task','incremental_manpower_exact','inventory_returns_to_hq',
    'all_rescued_succeeded','native_task_succeeded','completion_reward_exact',
    'rewards_stable','rescuer_cleanup'}

MIXED_EXPECTED=(SUCCESS_EXPECTED-{'all_rescued_succeeded'}) | {'mixed_resolved_succeeded'}

def collect(path,success=False,mixed=False):
    expected=MIXED_EXPECTED if mixed else SUCCESS_EXPECTED if success else EXPECTED
    raw=Path(path).read_bytes();checks=[];finishes=[];errors=[];malformed=[];starts=0
    for number,line in enumerate(raw.decode('utf-8-sig',errors='replace').splitlines(),1):
        if re.search(r'\bError(?::|\s+(?:in expression|Undefined|Missing|Generic|Type))|\| Error \|',line,re.I):errors.append({'line':number,'message':line})
        if '[INFECTION_CAMPAIGN_EXTRACTION] ' not in line:continue
        payload=line.split('[INFECTION_CAMPAIGN_EXTRACTION] ',1)[1].strip()
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
            'scope':('Native Redux one trusted AI rescue followed by remaining survivor deaths, scaled rewards and cleanup; not player escort, deadline or multiplayer acceptance' if mixed else 'Native Redux trusted server AI release, controlled HQ placement, incremental manpower, inventory, success rewards and asset cleanup; not player interaction, travel, deadline or multiplayer acceptance' if success else 'Native Redux public Extraction request, scene, all-survivors-dead failure and asset cleanup; not player rescue, success, task-retirement timer or multiplayer acceptance'),
            'source_log_sha256':hashlib.sha256(raw).hexdigest(),'validation':valid,'records':checks,'failed':failed,'errors':errors,'malformed':malformed}

if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('log');parser.add_argument('output');parser.add_argument('--success',action='store_true');parser.add_argument('--mixed',action='store_true');args=parser.parse_args()
    report=collect(args.log,args.success,args.mixed);Path(args.output).write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps({'status':report['status'],'checks':len(report['records']),'failed':report['failed'],'errors':len(report['errors'])}))
    raise SystemExit(0 if report['status']=='passed' else 1)
