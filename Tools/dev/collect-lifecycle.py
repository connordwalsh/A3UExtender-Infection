"""Keep special-creature death, deletion and cleanup evidence distinct."""
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


def fixture_array(path: Path) -> list:
    return parse_array("\n".join(line.split("//", 1)[0]
                                for line in path.read_text(encoding="utf-8").splitlines()))


def classify(snapshot: list, events: list) -> str:
    trial = [event[0] for event in events if event[2] == "trial"]
    killed = "Killed" in trial and ("Deleted" not in trial or trial.index("Killed") < trial.index("Deleted"))
    if snapshot[0]:
        return "deleted_after_recorded_death" if killed else "deleted_without_recorded_death"
    if snapshot[1]:
        return "alive"
    return "dead_with_recorded_death" if killed else "dead_without_recorded_death"


def collect(log: Path, repo: Path) -> dict:
    raw = log.read_bytes()
    records, malformed, errors, warnings = [], [], [], []
    current = ["startup", "startup"]
    sizes = {"start": 7, "begin": 4, "setup": 5, "sample": 6,
             "result": 6, "cleanup": 7, "event": 4, "abort": 5, "complete": 3}
    for number, line in enumerate(raw.decode("utf-8", errors="replace").splitlines(), 1):
        if "Error:" in line or re.search(r"Error\s+(?:in expression|Undefined|Missing|Generic|Type)", line):
            errors.append({"line": number, "trial": list(current), "message": line})
        elif re.search(r"Warning|not found|not multiple|Attempt to override", line, re.I):
            warnings.append({"line": number, "trial": list(current), "message": line})
        if "[INFECTION_LIFECYCLE] " not in line:
            continue
        payload = line.split("[INFECTION_LIFECYCLE] ", 1)[1].strip()
        if payload.endswith('"'):
            payload = payload[:-1].replace('""', '"')
        try:
            record = parse_array(payload)
            if not record or record[0] not in sizes or len(record) != sizes[record[0]]:
                raise ValueError("Record shape")
            if record[0] in {"setup", "sample", "result", "cleanup"}:
                snapshot = record[{"setup": 4, "sample": 3, "result": 4, "cleanup": 5}[record[0]]]
                if not isinstance(snapshot, list) or len(snapshot) != 6:
                    raise ValueError("Snapshot shape")
                if any(type(v) is not bool for v in snapshot[:3]):
                    raise ValueError("Snapshot flags")
            events = record[5] if record[0] == "result" else (record[6] if record[0] == "cleanup" else [])
            if record[0] == "event":
                events = [record[3]]
            if not isinstance(events, list) or any(
                not isinstance(e, list) or len(e) != 4 or e[0] not in {"Killed", "Deleted"}
                or e[2] not in {"initializing", "trial", "cleanup", "finished"}
                or not isinstance(e[3], list) or len(e[3]) != 6 for e in events
            ):
                raise ValueError("Event shape")
            if record[0] == "begin":
                current = record[1:3]
            records.append(record)
        except (ValueError, TypeError, IndexError):
            malformed.append(number)
    fixture = repo / "tests/arma/infection_probe/lifecycle.VR"
    catalog = repo / "tests/arma/infection_probe/catalog.VR/candidates.sqf"
    classes = fixture_array(catalog)
    scenarios = fixture_array(fixture / "scenarios.sqf")
    expected = Counter((cls, scenario[0]) for cls in classes for scenario in scenarios)
    by_kind = {kind: [r for r in records if r[0] == kind] for kind in sizes}
    starts, finishes = by_kind["start"], by_kind["complete"]
    complete = len(starts) == len(finishes) == 1
    checks = {
        "one_start_and_completion": complete,
        "record_schema_valid": not malformed,
        "dedicated_server": len(starts) == 1 and starts[0][2:5] == ["VR", True, 2],
        "declared_fixture_matches": len(starts) == 1 and starts[0][5:] == [classes, scenarios],
        "completion_count_matches": complete and finishes[0][1:] == [sum(expected.values()), False],
        "no_abort": not by_kind["abort"],
        "no_engine_or_sqf_errors": not errors,
    }
    for kind in ("begin", "setup", "result", "cleanup"):
        checks[kind + "_once_per_trial"] = Counter(tuple(r[1:3]) for r in by_kind[kind]) == expected
    checks["valid_prepared_subjects"] = bool(by_kind["setup"]) and all(r[3] is True for r in by_kind["setup"])
    counts = Counter(tuple(r[1:3]) for r in by_kind["sample"])
    checks["sample_counts_match"] = bool(by_kind["result"]) and all(
        r[3] > 0 and counts[tuple(r[1:3])] == r[3] for r in by_kind["result"])
    checks["existing_subjects_remain_server_local"] = bool(by_kind["sample"]) and all(
        r[3][0] or r[3][2:4] == [True, 2] for r in by_kind["sample"])
    checks["cleanup_empty"] = bool(by_kind["cleanup"]) and all(
        r[3:5] == [[], 0] and r[5][0] is True for r in by_kind["cleanup"])
    controls = [r for r in by_kind["result"] if r[2] == "delete_alive"]
    checks["live_deletion_is_not_kill_credit"] = len(controls) == len(classes) and all(
        r[4][0] is True and classify(r[4], r[5]) == "deleted_without_recorded_death"
        and any(e[0] == "Deleted" and e[2] == "trial" for e in r[5]) for r in controls)
    forced = [r for r in by_kind["result"] if r[2] == "forced_death"]
    checks["forced_deaths_have_killed_event"] = len(forced) == len(classes) and all(
        classify(r[4], r[5]) in {"dead_with_recorded_death", "deleted_after_recorded_death"} for r in forced)
    checks["observed_combat_deaths_have_killed_event"] = all(
        r[4][1] or classify(r[4], r[5]) in {"dead_with_recorded_death", "deleted_after_recorded_death"}
        for r in by_kind["result"] if r[2] == "rifle_combat")
    observations = []
    for r in by_kind["result"]:
        observations.append({"class": r[1], "scenario": r[2], "sample_count": r[3],
                             "final_snapshot": r[4], "classification": classify(r[4], r[5]),
                             "events_before_cleanup": r[5]})
    sources = sorted(fixture.iterdir()) + [catalog, Path(__file__)]
    return {
        "schema_version": 1,
        "scope": "Standalone prepared-class lifecycle observations; no production special, campaign, visual, client, HC or JIP acceptance",
        "status": "passed" if all(checks.values()) else ("failed" if complete else "incomplete"),
        "collected_at_utc": datetime.now(timezone.utc).isoformat(),
        "source_log": log.name, "source_log_sha256": hashlib.sha256(raw).hexdigest(),
        "source_sha256": {p.relative_to(repo).as_posix(): hashlib.sha256(p.read_bytes()).hexdigest()
                          for p in sources if p.is_file()},
        "checks": checks, "malformed_record_lines": malformed, "errors": errors,
        "warnings_for_review": warnings, "observations": observations,
        "event_records": by_kind["event"], "cleanup_records": by_kind["cleanup"],
        "completion": finishes[0][1:] if len(finishes) == 1 else None,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("log", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    report = collect(args.log, Path(__file__).resolve().parents[2])
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({"status": report["status"], "checks": report["checks"]}))
    return 0 if report["status"] == "passed" else 2


if __name__ == "__main__":
    raise SystemExit(main())
