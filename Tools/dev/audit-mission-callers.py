"""Inventory pinned native mission endpoints and textual callers; not a reachability proof."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess

GROUPS = {
    'Elimination': 'AS_Ambush AS_Official AS_Smasher AS_specOP AS_Traitor AS_Zombies RIV_AS_Traitor',
    'Liquidation': 'CON_MilAdmin CON_Outpost CON_Outpost_Compet CON_Outpost_Zombies',
    'Supplies Seizure': 'LOG_Airdrop LOG_Ammo LOG_Bank LOG_Crashsite LOG_Helicrash LOG_Salvage',
    'Extraction': 'RES_Deserters RES_Informer RES_Prisoners RES_Refugees RES_Shipwreck RIV_RES_Prisoners',
    'Humanitarian Aid': 'SUPP_Supplies RIV_SUPP_Salvage',
    'Disabled Destroy': 'DES_Antenna DES_Artillery DES_Heli DES_Vehicle',
    'Disabled infected repair': 'REP_Antenna',
    'Interception or background Invader supply convoy': 'convoy',
    'Dealer unlock without introduction': 'ENC_Trader',
    'Retained gang introduction with narrative adaptation': 'RIV_ENC_Rivals',
    'Retained native gang attack': 'RIV_ATT_Cell RIV_ATT_Hideout RIV_ATT_Transfer',
    'Six-category dispatcher; Random disabled': 'missionRequest',
    'Native shared utility': 'findIfNearAndHostile taskDelete taskSetState taskUpdate',
    'Retained native site defense alert': 'underAttack',
}

def audit(upstream, repo):
    addons=upstream/'A3A/addons'
    owners=sorted((addons/'core/functions/Missions').glob('fn_*.sqf'))
    if not owners:
        raise ValueError('No native mission sources found')
    policy={name.lower():label for label,names in GROUPS.items() for name in names.split()}
    config=(repo/'Infection/addons/core/config.cpp').read_text()
    overrides={p.stem[3:].lower():p for p in (repo/'Infection/addons/core/overrides').glob('fn_*.sqf')}
    files=sorted(p for p in addons.rglob('*') if p.suffix.lower() in {'.sqf','.hpp','.cpp','.ext'})
    contents={p:p.read_text(encoding='utf-8-sig',errors='replace').splitlines() for p in files}
    rows=[]
    for owner in owners:
        name=owner.stem[3:]; key=name.lower()
        pattern=re.compile(r'\bA3A_fnc_'+re.escape(name)+r'\b|\bFUNC(?:MAIN)?\(\s*'+re.escape(name)+r'\s*\)',re.I)
        refs=[]
        for path,content in contents.items():
            for line,text in enumerate(content,1):
                if pattern.search(text):refs.append({'path':path.relative_to(addons).as_posix(),'line':line,'text':text.strip()})
        override=overrides.get(key)
        registered=bool(re.search(r'class\s+'+re.escape(name)+r'\s*\{\s*file\s*=\s*"\\x\\a3i\\addons\\core\\overrides\\fn_'+re.escape(name)+r'\.sqf"',config,re.I))
        rows.append({'endpoint':name,'policy':policy.get(key,'UNCLASSIFIED'),
            'source':owner.relative_to(addons).as_posix(),'source_sha256':hashlib.sha256(owner.read_bytes()).hexdigest(),
            'override':override.relative_to(repo).as_posix() if override else None,
            'override_registered':registered,'override_sha256':hashlib.sha256(override.read_bytes()).hexdigest() if override else None,'references':refs})
    missing=[r['endpoint'] for r in rows if r['policy']=='UNCLASSIFIED' or
        (r['policy'] not in {'Native shared utility','Retained native gang attack','Retained native site defense alert'} and not r['override_registered'])]
    missing.extend('Missing source: '+name for name in sorted(set(policy)-{p.stem[3:].lower() for p in owners}))
    referenced={ref['path'] for row in rows for ref in row['references']}
    return {'scope':'Textual references to every core Missions function across native SQF/HPP/CPP/EXT. Includes comments and self references; does not prove runtime reachability or resolve generated names.',
        'upstream_commit':subprocess.check_output(['git','-C',str(upstream),'rev-parse','HEAD'],text=True).strip(),
        'infection_config_sha256':hashlib.sha256((repo/'Infection/addons/core/config.cpp').read_bytes()).hexdigest(),
        'files_scanned':len(files),'endpoints':rows,'unclassified_or_unregistered':missing,
        'referencing_sources':{p.relative_to(addons).as_posix():hashlib.sha256(p.read_bytes()).hexdigest() for p in files
            if p.relative_to(addons).as_posix() in referenced}}

if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('upstream',type=Path);parser.add_argument('output',type=Path)
    args=parser.parse_args();report=audit(args.upstream,Path(__file__).resolve().parents[2])
    args.output.parent.mkdir(parents=True,exist_ok=True)
    args.output.write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps({'endpoints':len(report['endpoints']),'files_scanned':report['files_scanned'],'gaps':report['unclassified_or_unregistered']}))
    raise SystemExit(bool(report['unclassified_or_unregistered']))
