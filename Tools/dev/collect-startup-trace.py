"""Collect bounded startup diagnostics, never classify them as campaign acceptance."""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import re


def collect(path):
    raw=Path(path).read_bytes()
    records=[];malformed=[];errors=[]
    lengths={'preInit':3,'activateAddons':9,'activateAddonsResult':3,'observation_complete':4}
    for number,line in enumerate(raw.decode('utf-8',errors='replace').splitlines(),1):
        if re.search(r'\bError(?::|\s+(?:in expression|Undefined|Missing|Generic|Type))|\| Error \|',line,re.IGNORECASE):
            errors.append({'line':number,'message':line})
        if '[INFECTION_TRACE] ' not in line:continue
        payload=line.split('[INFECTION_TRACE] ',1)[1]
        if payload.endswith('"'):payload=payload[:-1].replace('""','"')
        try:
            row=json.loads(payload)
            if not isinstance(row,list) or not row or len(row)!=lengths.get(row[0],-1):raise ValueError('Schema mismatch')
            records.append(row)
        except (ValueError,TypeError):malformed.append(number)
    counts=Counter(r[0] for r in records)
    calls=[r for r in records if r[0]=='activateAddons']
    results=[r for r in records if r[0]=='activateAddonsResult']
    complete=not malformed and counts==Counter({'preInit':1,'activateAddons':2,'activateAddonsResult':2,'observation_complete':1})
    return {'scope':'Instrumented startup diagnosis only; not clean-log or gameplay acceptance',
            'trace_complete':complete,'sha256':hashlib.sha256(raw).hexdigest(),
            'records':records,'malformed_lines':malformed,'errors':errors,
            'calls_after_start':bool(calls) and all(r[1]>0 for r in calls),
            'normalized_missing_counts':[r[6] for r in calls],
            'native_result_counts':[r[2] for r in results]}


if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('rpt');parser.add_argument('output');args=parser.parse_args()
    result=collect(args.rpt)
    Path(args.output).write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({k:v for k,v in result.items() if k not in ('records','errors')}))
    raise SystemExit(0 if result['trace_complete'] else 1)
