"""Collect search availability, preserving unsuccessful searches as observations."""
import argparse
from collections import Counter
import hashlib
import json
import math
from pathlib import Path
import re
import runpy

parse_array = runpy.run_path(str(Path(__file__).with_name('collect-probe.py')))['parse_array']


def collect(path, baseline=False):
    raw = Path(path).read_bytes()
    tag = '[INFECTION_SUPPLY_PARKING_BASELINE] ' if baseline else '[INFECTION_SUPPLY_PARKING] '
    starts, plans, results, finishes, errors, malformed = [], [], [], [], [], []
    for number, line in enumerate(raw.decode('utf-8-sig', errors='replace').splitlines(), 1):
        if re.search(r'\bError(?::|\s+(?:in expression|Undefined|Missing|Generic|Type))|\| Error \|', line, re.I):
            errors.append({'line': number, 'message': line})
        if tag not in line:
            continue
        payload = line.split(tag, 1)[1].strip()
        if payload.endswith('"'):
            payload = payload[:-1].replace('""', '"')
        try:
            row = parse_array(payload)
            if row[0] == 'start' and len(row) == 3 and row[1] == 'chernarusredux' and type(row[2]) is int:
                starts.append(row)
            elif row[0] == 'planned' and len(row) == 4 and all(isinstance(x, str) and x for x in row[1:]):
                plans.append(tuple(row[1:]))
            elif row[0] == 'result' and len(row) == 8 and all(isinstance(x, str) and x for x in row[1:4]) and all(type(x) is bool for x in row[4:6]) and isinstance(row[6], list) and type(row[7]) in (int, float) and row[7] >= 0:
                parking = row[6]
                finite_number = lambda x: type(x) in (int, float) and math.isfinite(x)
                if len(parking) != 2 or not finite_number(parking[1]) or not finite_number(row[7]):
                    raise ValueError('Invalid parking record')
                if row[4]:
                    if not isinstance(parking[0], list) or len(parking[0]) != 3 or not all(finite_number(x) for x in parking[0]):
                        raise ValueError('Invalid available position')
                elif parking[0] != []:
                    raise ValueError('Unavailable result contains position')
                results.append(row)
            elif row[0] == 'complete' and len(row) == 5 and all(type(x) is int and x >= 0 for x in row[1:]):
                finishes.append(row)
            else:
                raise ValueError('Invalid record')
        except (ValueError, TypeError, IndexError):
            malformed.append(number)
    found = sum(r[4] for r in results)
    invalid = sum(not r[5] for r in results)
    counts = [len(results), found, len(results) - found, invalid]
    checks = {
        'one_run': len(starts) == len(finishes) == 1,
        'schema': not malformed,
        'nonempty_unique_plan': bool(plans) and len(set(plans)) == len(plans),
        'planned_count': len(starts) == 1 and starts[0][2] == len(plans),
        'complete_coverage': Counter(plans) == Counter(tuple(r[1:4]) for r in results),
        'completion_matches': len(finishes) == 1 and finishes[0][1:] == counts,
        'returned_positions_valid': not invalid,
        'no_errors': not errors,
    }
    return {'status': 'complete' if all(checks.values()) else 'failed' if finishes else 'incomplete',
            'scope': ('Historical search, revalidated against candidate clearance; ' if baseline else 'Candidate native search; ') + 'one search per current infected site/kind/class; not vehicle survival or performance acceptance',
            'source_log_sha256': hashlib.sha256(raw).hexdigest(), 'validation': checks,
            'counts': dict(zip(['searches', 'available', 'unavailable', 'invalid'], counts)),
            'unavailable': [r[1:4] for r in results if not r[4]],
            'results': results, 'errors': errors, 'malformed': malformed}


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('log'); parser.add_argument('output')
    parser.add_argument('--baseline', action='store_true')
    args = parser.parse_args()
    report = collect(args.log, args.baseline)
    Path(args.output).write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps({key: report[key] for key in ['status', 'counts', 'validation']}))
    raise SystemExit(0 if report['status'] == 'complete' else 1)
