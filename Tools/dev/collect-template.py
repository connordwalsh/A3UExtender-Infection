"""Collect isolated loader/creator checks; this is not campaign acceptance."""
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
COMMON = {
    "addon_registered", "functions_available", "dependency_state", "passive_without_faction",
    "template_registered", "template_side", "setup_dependency_gate", "ultimate_version_contract",
    "activation_requires_dependencies", "ultimate_patch_version",
}
ROLES = ["SquadLeader", "Rifleman", "Radioman", "Medic", "Engineer", "ExplosivesExpert",
         "Grenadier", "LAT", "AT", "AA", "MachineGunner", "Marksman", "Sniper", "PatrolSniper", "PatrolSpotter"]
EXPECTED_ROLES = [f"{prefix}_{role}" for prefix in ("militia", "military", "elite", "SF") for role in ROLES]
EXPECTED_ROLES += [f"police_{role}" for role in ("SquadLeader", "Standard")]
EXPECTED_ROLES += [f"other_{role}" for role in ("Crew", "Official", "Pilot", "Traitor", "Unarmed")]
GARRISON_CHECKS = {
    "garrison_preferences_present", "garrison_lines_war1", "garrison_lines_war5", "garrison_lines_war8",
    "garrison_weighted_tiers", "garrison_no_vehicle_queries", "garrison_invalid_input",
    "garrison_invader_passthrough", "garrison_normal_occupant_passthrough",
    "garrison_missing_dependency_passthrough", "garrison_initial_rosters", "garrison_selector_observation",
}
COMBAT_CHECKS = {
    "combat_override_registered", "combat_test_endpoints", "combat_guard_scope", "combat_passthrough",
    "combat_init_militia", "combat_init_military", "combat_init_elite", "combat_init_spawn_contract", "combat_damage_observer",
    "combat_kill_garrison", "combat_kill_legacy", "combat_kill_prepaid_attack", "combat_kill_nonrebel",
    "combat_delete_attack_refund", "combat_delete_defence_refund", "combat_delete_garrison_retains",
    "combat_delete_legacy_retains", "combat_delete_unfit_legacy", "combat_delete_duplicate", "combat_ownership_race",
    "combat_rifle_militia", "combat_rifle_military", "combat_rifle_elite", "combat_cleanup",
}
BUDGET_CHECKS = {
    "budget_settings_registered", "budget_inactive_denied", "budget_invalid_requests",
    "budget_global_and_context_caps", "budget_close_idempotent", "budget_concurrent_reservations",
    "budget_server_remote_call", "budget_pending_limit_reduction", "budget_bind_basic", "budget_duplicate_binding", "budget_live_release_denied",
    "budget_capacity_reduction_keeps_units", "budget_kill_release", "budget_live_delete_release",
    "budget_close_preserves_bound", "budget_cancel_deletes_bound", "budget_expiry_preserves_bound",
    "budget_expiry_unbound", "budget_unknown_operation", "budget_cleanup",
}


def collect(log_path: Path, repo: Path, expected_dependencies: bool) -> dict:
    raw = log_path.read_bytes()
    records, malformed, errors, warnings = [], [], [], []
    for number, line in enumerate(raw.decode("utf-8", errors="replace").splitlines(), 1):
        if re.search(r"Error(?::|\s+(?:in expression|Undefined|Missing|Generic|Type))", line) or re.search(
            r"Attempt to override final function - a3[ai]_", line, re.IGNORECASE
        ):
            errors.append(number)
        if any(text in line for text in ("Warning Message:", "not found or empty", "item count not multiple", "Attempt to override final function")):
            # Preserve known dependency/engine warnings separately from SQF failures.
            warnings.append({"line": number, "message": line.split(" ", 1)[-1]})
        if "[INFECTION_TEMPLATE] " not in line:
            continue
        payload = line.split("[INFECTION_TEMPLATE] ", 1)[1].strip()
        if payload.endswith('"'):
            payload = payload[:-1].replace('""', '"')
        try:
            record = parse_array(payload)
            shapes = {"start": 6, "check": 4, "spawn": 4, "complete": 4}
            if not record or len(record) != shapes.get(record[0], -1):
                raise ValueError("Unexpected record shape")
            records.append(record)
        except (ValueError, json.JSONDecodeError):
            malformed.append(number)
    by_kind = {k: [r for r in records if r[0] == k] for k in ("start", "check", "spawn", "complete")}
    starts, finishes = by_kind["start"], by_kind["complete"]
    complete = len(starts) == len(finishes) == 1
    expected_checks = COMMON | ({
        "active_only_for_occupants", "role_count", "generated_groups_resolve", "prepared_basic_classes_only",
        "assets_resolve", "conventional_pools_empty", "cleanup",
    } | GARRISON_CHECKS | COMBAT_CHECKS | BUDGET_CHECKS | {"spawn_" + name for name in EXPECTED_ROLES} if expected_dependencies else {"both_required_patches_absent"})
    expected_roles = EXPECTED_ROLES if expected_dependencies else []
    checks = {
        "one_start_and_completion": complete,
        "record_schema_valid": not malformed,
        "dedicated_expected_mode": len(starts) == 1 and starts[0][2:] == ["VR", True, 2, expected_dependencies],
        "all_expected_checks_once": Counter(r[1] for r in by_kind["check"]) == Counter(expected_checks),
        "all_runtime_checks_pass": bool(by_kind["check"]) and all(r[2] is True for r in by_kind["check"]),
        "completion_matches_checks": complete and finishes[0][1:] == [len(expected_checks), [], len(expected_roles)],
        "all_expected_roles_once": Counter(r[1] for r in by_kind["spawn"]) == Counter(expected_roles),
        "all_role_spawns_pass": all(r[3] is True for r in by_kind["spawn"]),
        "no_engine_or_sqf_error_records": not errors,
    }
    fixture_files = sorted((repo / "tests/arma/infection_probe/template.VR").glob("*"))
    fixture_files += sorted((repo / "tests/arma/infection_probe/contracts-addon").glob("*")) if expected_dependencies else []
    source_files = sorted((repo / "Infection").rglob("*"))
    return {
        "schema_version": 1,
        "scope": "Isolated dedicated template/unit/garrison/combat/budget contracts; no full campaign, player credit, ACE, HC transfer or JIP acceptance",
        "expected_dependencies_present": expected_dependencies,
        "status": "passed" if all(checks.values()) else ("failed" if complete else "incomplete"),
        "collected_at_utc": datetime.now(timezone.utc).isoformat(),
        "source_log": log_path.name,
        "source_log_sha256_at_collection": hashlib.sha256(raw).hexdigest(),
        "source_sha256_at_collection": {p.relative_to(repo).as_posix(): hashlib.sha256(p.read_bytes()).hexdigest()
                                        for p in fixture_files + source_files if p.is_file()},
        "checks": checks,
        "malformed_record_lines": malformed,
        "error_lines": errors,
        "warnings_for_review": warnings,
        "runtime_checks": [{"name": r[1], "passed": r[2], "detail": r[3]} for r in by_kind["check"]],
        "spawn_records": by_kind["spawn"],
        "completion": finishes[0][1:] if len(finishes) == 1 else None,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("log", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--dependencies", choices=("present", "absent"), required=True)
    args = parser.parse_args()
    report = collect(args.log, Path(__file__).resolve().parents[2], args.dependencies == "present")
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({"status": report["status"], "checks": report["checks"]}))
    return 0 if report["status"] == "passed" else 2


if __name__ == "__main__":
    raise SystemExit(main())
