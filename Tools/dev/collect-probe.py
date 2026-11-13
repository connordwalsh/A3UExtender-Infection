"""Export only tagged probe evidence; incomplete runs can never pass."""
from __future__ import annotations

import argparse
import hashlib
import json
import re
from collections import Counter
from datetime import datetime, timezone
from pathlib import Path


def parse_array(text: str) -> list:
    # SQF strings escape quotes by doubling them; backslashes are literal.
    # diag_log emits SIDE values as bare enums, even inside nested arrays.
    # Match strings first so words inside quoted text are never substituted.
    converted = re.sub(
        r'"(?:[^"\r\n]|"")*"|\b(?:WEST|EAST|GUER|CIV|UNKNOWN)\b',
        lambda match: json.dumps(match.group()[1:-1].replace('""', '"')
                                 if match.group().startswith('"') else match.group()),
        text,
    )
    result = json.loads(converted)
    if not isinstance(result, list):
        raise ValueError("Expected an SQF array")
    return result


def collect(log_path: Path, repo: Path) -> dict:
    raw = log_path.read_bytes()
    lines = raw.decode("utf-8", errors="replace").splitlines()
    records, malformed, script_errors = [], [], []
    engine_errors = []
    current_candidate = "startup"
    for number, line in enumerate(lines, 1):
        if re.search(r"Error:?\s+(?:in expression|Undefined|Missing|Generic|Type)", line):
            script_errors.append(number)
        if "Error:" in line:
            category = ("missing_bone" if "Bone " in line else
                        "head_body_skeleton_mismatch" if "Skeleton of " in line else
                        "invalid_attachment_point" if "Invalid memory point" in line else "other")
            engine_errors.append({"line": number, "candidate": current_candidate, "category": category})
        if "[INFECTION_PROBE] " not in line:
            continue
        payload = line.split("[INFECTION_PROBE] ", 1)[1].strip()
        # diag_log writes a quoted string with another layer of doubled quotes.
        if payload.endswith('"'):
            payload = payload[:-1].replace('""', '"')
        try:
            record = parse_array(payload)
            records.append(record)
            if record and record[0] == "class":
                current_candidate = record[1]
        except (ValueError, json.JSONDecodeError):
            malformed.append(number)

    fixture = repo / "tests/arma/infection_probe/catalog.VR"
    candidate_text = "\n".join(
        line.split("//", 1)[0] for line in (fixture / "candidates.sqf").read_text().splitlines()
    )
    candidates = parse_array(candidate_text)
    by_kind = {kind: [r for r in records if r and r[0] == kind]
               for kind in ("start", "complete", "class", "spawn", "afterDelete", "setting")}
    starts, completions = by_kind["start"], by_kind["complete"]
    complete = len(starts) == len(completions) == 1
    expected = Counter(candidates)
    checks = {
        "one_start_and_completion": complete,
        "all_records_parse": not malformed,
        "completion_count_matches_fixture": complete and completions[0][1] == len(candidates),
        "reported_failure_list_empty": complete and completions[0][2] == [],
        "all_class_records_present_once": Counter(r[1] for r in by_kind["class"]) == expected,
        "all_spawn_records_present_once": Counter(r[1] for r in by_kind["spawn"]) == expected,
        "all_cleanup_records_present_once": Counter(r[1] for r in by_kind["afterDelete"]) == expected,
        "no_sqf_error_records": not script_errors,
    }
    checks["spawn_type_side_alive_local_init"] = bool(by_kind["spawn"]) and all(
        len(r) == 14 and r[1] == r[2] and r[3] == "WEST"
        and r[4] is True and r[6] is True and r[7] is True
        for r in by_kind["spawn"]
    )
    checks["unarmed"] = bool(by_kind["spawn"]) and all(r[9:12] == ["", "", ""] for r in by_kind["spawn"])
    checks["no_remaining_entities_at_three_seconds"] = bool(by_kind["afterDelete"]) and all(
        r[2] == [] for r in by_kind["afterDelete"]
    )
    classes = []
    for name in candidates:
        entry = {"class": name}
        for kind, fields in (
            ("class", ("config_side", "scope", "model", "moves", "skeleton", "ancestors", "source_addons")),
            ("spawn", ("actual_class", "group_side", "local", "owner_id", "alive", "initialized",
                       "initialization_marker", "primary_weapon", "secondary_weapon", "handgun_weapon",
                       "animation", "per_frame_handler_count")),
            ("afterDelete", ("remaining_entities", "remaining_group_count")),
        ):
            matches = [r for r in by_kind[kind] if r[1] == name]
            if len(matches) == 1:
                entry["config" if kind == "class" else kind] = dict(zip(fields, matches[0][2:]))
        classes.append(entry)
    error_summary = []
    for candidate, category in sorted({(e["candidate"], e["category"]) for e in engine_errors}):
        matching = [e["line"] for e in engine_errors if (e["candidate"], e["category"]) == (candidate, category)]
        error_summary.append({"candidate": candidate, "category": category, "count": len(matching),
                              "first_line": min(matching), "last_line": max(matching)})
    return {
        "schema_version": 1,
        "scope": "Dedicated prepared-class spawn, initialization, equipment and immediate deletion smoke test",
        "collected_at_utc": datetime.now(timezone.utc).isoformat(),
        "source_log": log_path.name,
        "source_sha256_at_collection": hashlib.sha256(raw).hexdigest(),
        "fixture_sha256": {p.relative_to(repo).as_posix(): hashlib.sha256(p.read_bytes()).hexdigest()
                           for p in sorted(fixture.iterdir()) if p.is_file()},
        "status": ("needs_review" if engine_errors else "pass") if all(checks.values())
                  else ("incomplete" if not complete else "fail"),
        "smoke_checks_pass": all(checks.values()),
        "checks": checks,
        "runtime_record": starts[0][1:] if len(starts) == 1 else None,
        "completion_record": completions[0][1:] if len(completions) == 1 else None,
        "malformed_record_lines": malformed,
        "sqf_error_lines": script_errors,
        "engine_error_summary": error_summary,
        "settings": {r[1]: r[2] for r in by_kind["setting"]},
        "classes": classes,
        "not_covered": ["combat", "civilian targeting", "vehicle interactions", "waypoint compliance",
                        "Antistasi integration", "JIP", "headless transfer", "delayed cleanup or performance soak"],
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
    return 0 if report["status"] == "pass" else 2


if __name__ == "__main__":
    raise SystemExit(main())
