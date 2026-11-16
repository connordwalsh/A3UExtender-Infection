"""Collect real-campaign forced-spawn lifecycle checks without suppressing errors."""
from collections import Counter
import argparse
import hashlib
import json
from pathlib import Path
import re
import runpy

parse_array=runpy.run_path(str(Path(__file__).with_name('collect-probe.py')))['parse_array']
SUFFIXES={'native_dispatch','new_controller','full_roster_accounted','valid_infected',
          'native_cleanup','asset_cleanup','budget_released','roster_preserved'}
KINDS=['city','resource','factory','outpost','seaport','milbase','airport']
EXPECTED={'seven_native_targets'}|{f'{kind}_{visit}_{name}' for kind in KINDS for visit in [1,2] for name in SUFFIXES}
BASIC_EXPECTED={'two_native_targets'}|{f'{kind}_{visit}_{name}' for kind in ['city','resource'] for visit in [1,2] for name in SUFFIXES-{'asset_cleanup'}}

def collect(path,coverage='all'):
    if coverage not in {'all','basic'}:raise ValueError('Unknown coverage')
    expected=EXPECTED if coverage=='all' else BASIC_EXPECTED
    raw=Path(path).read_bytes();checks=[];finishes=[];errors=[];malformed=[];starts=0
    for number,line in enumerate(raw.decode('utf-8-sig',errors='replace').splitlines(),1):
        if re.search(r'\bError(?::|\s+(?:in expression|Undefined|Missing|Generic|Type))|\| Error \|',line,re.I):errors.append({'line':number,'message':line})
        if '[INFECTION_CAMPAIGN_SITES] ' not in line:continue
        payload=line.split('[INFECTION_CAMPAIGN_SITES] ',1)[1].strip()
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
            'coverage':coverage,'scope':('Town and six permanent-site types' if coverage=='all' else 'Legacy town and resource only')+'; two native forced-spawn visits per category; no player, town civilian-distance, combat, JIP or performance acceptance',
            'source_log_sha256':hashlib.sha256(raw).hexdigest(),'validation':valid,'records':checks,'failed':failed,'errors':errors,'malformed':malformed}

if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('log');parser.add_argument('output');parser.add_argument('--coverage',choices=['all','basic'],default='all');args=parser.parse_args()
    report=collect(args.log,args.coverage);Path(args.output).write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps({'status':report['status'],'checks':len(report['records']),'failed':report['failed'],'errors':len(report['errors'])}))
    raise SystemExit(0 if report['status']=='passed' else 1)
