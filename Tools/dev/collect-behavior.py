"""Summarize controlled encounter observations without certifying gameplay."""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import runpy
from collections import Counter
from datetime import datetime, timezone
from pathlib import Path

parse_array = runpy.run_path(str(Path(__file__).with_name("collect-probe.py")))["parse_array"]


def fixture_array(path: Path) -> list:
    return parse_array("\n".join(line.split("//", 1)[0] for line in path.read_text().splitlines()))


def collect(log_path: Path, repo: Path) -> dict:
    raw = log_path.read_bytes()
    records, malformed, script_errors, engine_errors = [], [], [], []
    current = ["startup", "startup"]
    for number, line in enumerate(raw.decode("utf-8", errors="replace").splitlines(), 1):
        if re.search(r"Error:?\s+(?:in expression|Undefined|Missing|Generic|Type)", line):
            script_errors.append(number)
        if "Error:" in line:
            category = ("missing_bone" if "Bone " in line else
                        "head_body_skeleton_mismatch" if "Skeleton of " in line else
                        "invalid_attachment_point" if "Invalid memory point" in line else "other")
            engine_errors.append((tuple(current), category, number))
        if "[INFECTION_BEHAVIOR] " not in line:
            continue
        payload = line.split("[INFECTION_BEHAVIOR] ", 1)[1].strip()
        if payload.endswith('"'):
            payload = payload[:-1].replace('""', '"')
        try:
            record = parse_array(payload)
            if not record or not isinstance(record[0], str):
                raise ValueError("Missing record kind")
            records.append(record)
            if record[0] == "begin" and len(record) == 4:
                current = record[1:3]
        except (ValueError, json.JSONDecodeError):
            malformed.append(number)

    fixture = repo / "tests/arma/infection_probe/behavior.VR"
    catalog = repo / "tests/arma/infection_probe/catalog.VR/candidates.sqf"
    classes = fixture_array(catalog)
    scenarios = fixture_array(fixture / "scenarios.sqf")
    expected = Counter((name, scenario[0]) for name in classes for scenario in scenarios)
    shapes = {"begin": 4, "setup": 12, "sample": 17, "result": 19, "cleanup": 5,
              "complete": 4, "setting": 3, "start": 8}
    invalid_shapes = [i for i, row in enumerate(records) if row[0] in shapes and len(row) != shapes[row[0]]]
    by_kind = {kind: [r for r in records if r[0] == kind and len(r) == length]
               for kind, length in shapes.items()}
    starts, completions = by_kind["start"], by_kind["complete"]
    complete = len(starts) == len(completions) == 1
    aborts = [r[1:] for r in records if r[0] in ("abort", "invalid")]
    checks = {
        "one_start_and_completion": complete,
        "records_parse_and_match_schema": not malformed and not invalid_shapes,
        "completed_expected_trials": complete and completions[0][1:3] == [len(expected), len(expected)],
        "no_abort": not aborts and complete and completions[0][3] is False,
        "runtime_manifest_matches_fixture": len(starts) == 1 and starts[0][6:] == [classes, scenarios],
        "no_sqf_error_records": not script_errors,
    }
    for kind in ("begin", "setup", "result", "cleanup"):
        checks[f"all_{kind}_records_present_once"] = Counter(tuple(r[1:3]) for r in by_kind[kind]) == expected
    samples = Counter(tuple(r[1:3]) for r in by_kind["sample"])
    checks["sample_counts_match_results"] = bool(by_kind["result"]) and all(
        r[3] > 0 and samples[tuple(r[1:3])] == r[3] for r in by_kind["result"]
    )
    checks["all_cleanup_empty"] = bool(by_kind["cleanup"]) and all(r[3:] == [[], 0] for r in by_kind["cleanup"])
    checks["server_local_at_start_and_end"] = bool(by_kind["setup"]) and bool(by_kind["result"]) and all(
        r[3:6] == ["WEST", True, 2] for r in by_kind["setup"]
    ) and all(r[17:] == [True, 2] for r in by_kind["result"])

    observations = []
    fields = ("sample_count", "target_acquired", "closest_target_distance_m", "max_target_damage",
              "max_vehicle_damage", "max_infected_damage", "initial_custom_hp", "min_custom_hp",
              "infected_alive_at_end", "target_alive_at_end", "target_side_at_end",
              "infected_displacement_m", "distance_to_waypoint_m", "max_trial_entities",
              "local_at_end", "owner_at_end")
    for record in by_kind["result"]:
        pair = tuple(record[1:3])
        trial_samples = [r for r in by_kind["sample"] if tuple(r[1:3]) == pair]
        entry = {"class": pair[0], "scenario": pair[1], **dict(zip(fields, record[3:]))}
        entry["observed_animations"] = sorted({r[5] for r in trial_samples})
        entry["observed_enemy_classes"] = sorted({r[9] for r in trial_samples if r[9]})
        entry["observed_target_sides"] = sorted({r[13] for r in trial_samples})
        entry["server_fps_range"] = [min(r[16] for r in trial_samples), max(r[16] for r in trial_samples)] if trial_samples else None
        entry["cleanup"] = [r[3:] for r in by_kind["cleanup"] if tuple(r[1:3]) == pair]
        observations.append(entry)
    error_summary = []
    for pair, category in sorted({(pair, category) for pair, category, _ in engine_errors}):
        numbers = [n for p, c, n in engine_errors if (p, c) == (pair, category)]
        error_summary.append({"class": pair[0], "scenario": pair[1], "category": category,
                              "count": len(numbers), "first_line": min(numbers), "last_line": max(numbers)})
    fixture_files = sorted(fixture.iterdir()) + [catalog]
    return {
        "schema_version": 1,
        "scope": "Automated dedicated controlled encounters; manual visual review and campaign acceptance remain separate",
        "collected_at_utc": datetime.now(timezone.utc).isoformat(),
        "source_log": log_path.name,
        "source_sha256_at_collection": hashlib.sha256(raw).hexdigest(),
        "fixture_sha256": {p.relative_to(repo).as_posix(): hashlib.sha256(p.read_bytes()).hexdigest()
                           for p in fixture_files if p.is_file()},
        "status": "observations_complete" if all(checks.values()) else ("incomplete" if not complete else "failed_or_aborted"),
        "requires_review": True,
        "checks": checks,
        "completed_trials": len(observations),
        "expected_trials": len(expected),
        "runtime_record": starts[0][1:] if len(starts) == 1 else None,
        "completion_record": completions[0][1:] if len(completions) == 1 else None,
        "malformed_record_lines": malformed,
        "invalid_record_shapes": invalid_shapes,
        "sqf_error_lines": script_errors,
        "engine_error_summary": error_summary,
        "aborts": aborts,
        "settings": {r[1]: r[2] for r in by_kind["setting"]},
        "observations": observations,
        "limitations": ["No Antistasi damage handlers or campaign state", "No headless transfer",
                        "No manual weapon or vehicle controls", "No long-term infection observation",
                        "Passive targets and stationary vehicles; rifle opponent uses explicit target/fire orders",
                        "Short VR scenarios cannot establish terrain pathing or multiplayer performance"],
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("log", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    report = collect(args.log, Path(__file__).resolve().parents[2])
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({"status": report["status"], "completed_trials": report["completed_trials"],
                      "expected_trials": report["expected_trials"], "checks": report["checks"]}))
    return 0 if all(report["checks"].values()) else 2


if __name__ == "__main__":
    raise SystemExit(main())
