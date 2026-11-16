"""Collect real-campaign forced-spawn lifecycle checks without suppressing errors."""
from collections import Counter
import argparse
import hashlib
import json
from pathlib import Path
import re
import runpy

parse_array=runpy.run_path(str(Path(__file__).with_name('collect-probe.py')))['parse_array']
EXPECTED={
    'write':{'write_'+x for x in ['receipt_valid','native_save_completed','campaign_identity','saved_reduced_roster','saved_funds_exact','receipt_written']},
    'read':{'read_'+x for x in ['receipt_valid','campaign_identity','native_roster_restored','ownership_restored','native_dispatch','only_reduced_roster_spawned','valid_infected','native_cleanup','budget_released','roster_unchanged']},
}

def collect(path,phase):
    expected=EXPECTED[phase]
    raw=Path(path).read_bytes();checks=[];finishes=[];errors=[];malformed=[];starts=0
    for number,line in enumerate(raw.decode('utf-8-sig',errors='replace').splitlines(),1):
        if re.search(r'\bError(?::|\s+(?:in expression|Undefined|Missing|Generic|Type))|\| Error \|',line,re.I):errors.append({'line':number,'message':line})
        if '[INFECTION_CASUALTY_SAVE] ' not in line:continue
        payload=line.split('[INFECTION_CASUALTY_SAVE] ',1)[1].strip()
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
            'phase':phase,'scope':'Native campaign casualty save/restart/load and site activation; not player combat or multiplayer acceptance',
            'source_log_sha256':hashlib.sha256(raw).hexdigest(),'validation':valid,'records':checks,'failed':failed,'errors':errors,'malformed':malformed}

if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('log');parser.add_argument('output');parser.add_argument('--phase',choices=EXPECTED,required=True);args=parser.parse_args()
    report=collect(args.log,args.phase);Path(args.output).write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps({'status':report['status'],'checks':len(report['records']),'failed':report['failed'],'errors':len(report['errors'])}))
    raise SystemExit(0 if report['status']=='passed' else 1)
