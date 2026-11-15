"""Collect native Redux campaign smoke checks without hiding engine/native errors."""
from __future__ import annotations
import argparse
from collections import Counter
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import re
import runpy

parse_array = runpy.run_path(str(Path(__file__).with_name("collect-probe.py")))["parse_array"]
COMMON = {"background_ready", "campaign_initialized", "infection_selected", "native_hq_ready", "redux_parking_slots", "redux_orphan_reconnected", "black_market_only_hq_absent", "black_market_only_native_quote", "background_window_completed"}
EXPECTED = {
    "write": COMMON | {"fresh_profile", "real_sites_available", "dealer_unlocked", "native_save_completed", "native_save_has_campaign", "loot_crate_fixture", "loot_crate_refund_exact"},
    "read": COMMON | {"saved_receipt_present", "town_extras_restored", "admin_extras_restored", "dealer_restored", "hq_restored", "save_identity_restored", "saved_crate_resources_restored"},
}

def collect(path: Path, phase: str) -> dict:
    raw = path.read_bytes()
    records, malformed, errors = [], [], []
    for number, line in enumerate(raw.decode("utf-8", errors="replace").splitlines(), 1):
        if re.search(r"Error(?::|\s+(?:in expression|Undefined|Missing|Generic|Type))|\| Error \|", line):
            errors.append({"line": number, "message": line})
        if "[INFECTION_CAMPAIGN] " not in line:
            continue
        payload = line.split("[INFECTION_CAMPAIGN] ", 1)[1].strip()
        if payload.endswith('"'):
            payload = payload[:-1].replace('""', '"')
        try:
            item = parse_array(payload)
            if not item or len(item) != {"start": 5, "check": 4, "complete": 4}.get(item[0], -1):
                raise ValueError("Bad campaign record")
            if item[0] == "check" and type(item[2]) is not bool:
                raise ValueError("Check verdict must be boolean")
            records.append(item)
        except (ValueError, json.JSONDecodeError):
            malformed.append(number)
    starts = [x for x in records if x[0] == "start"]
    finishes = [x for x in records if x[0] == "complete"]
    assertions = [x for x in records if x[0] == "check"]
    failed = [x[1] for x in assertions if not x[2]]
    complete = len(starts) == len(finishes) == 1
    checks = {
        "one_start_and_completion": complete,
        "schema_valid": not malformed,
        "correct_phase_and_terrain": len(starts) == 1 and starts[0][1:3] == [phase, "chernarusredux"],
        "all_expected_checks_once": Counter(x[1] for x in assertions) == Counter(EXPECTED[phase]),
        "runtime_checks_pass": not failed,
        "completion_matches": complete and finishes[0][1:] == [phase, len(assertions), failed],
        "no_engine_or_native_errors": not errors,
    }
    repo = Path(__file__).resolve().parents[2]
    sources = list((repo / "tests/arma/campaign_probe").glob("*")) + [Path(__file__), repo / "Tools/dev/start-campaign-probe.ps1"]
    return {
        "schema_version": 1,
        "scope": "Official Redux mission, native server campaign init/save/load; no connected-player, UI, JIP, combat or long-session acceptance",
        "phase": phase,
        "status": "passed" if all(checks.values()) else "failed" if complete else "incomplete",
        "collected_at_utc": datetime.now(timezone.utc).isoformat(),
        "source_log": path.name,
        "source_log_sha256": hashlib.sha256(raw).hexdigest(),
        "source_sha256": {str(p.relative_to(repo)).replace(chr(92), "/"): hashlib.sha256(p.read_bytes()).hexdigest() for p in sources},
        "checks": checks, "failed_checks": failed, "malformed_lines": malformed,
        "errors": errors, "records": records,
    }

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("log", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--phase", choices=EXPECTED, required=True)
    args = parser.parse_args()
    report = collect(args.log, args.phase)
    args.output.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({"status": report["status"], "checks": report["checks"], "error_count": len(report["errors"])}))
    raise SystemExit(0 if report["status"] == "passed" else 1)
