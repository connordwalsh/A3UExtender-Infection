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
    "budget_context_increase_releases_capacity", "budget_context_increase_keeps_caller_ceiling",
    "budget_capacity_reduction_keeps_units", "budget_kill_release", "budget_live_delete_release",
    "budget_close_preserves_bound", "budget_cancel_deletes_bound", "budget_expiry_preserves_bound",
    "budget_expiry_unbound", "budget_unknown_operation", "budget_ticket_preflight", "budget_cleanup",
}
SPAWN_CHECKS = {
    "spawn_invalid_positions", "spawn_hq_exclusion", "spawn_observer_distance",
    "spawn_visible_rejected", "spawn_obscured_position", "spawn_occupied_position",
    "spawn_bounded_search", "spawn_no_center_fallback", "spawn_invalid_search",
    "spawn_budgeted_basics", "spawn_full_budget_denied", "spawn_raw_class_denied",
    "spawn_missing_hq_releases", "spawn_inactive_site_denied", "spawn_ownership_race",
    "spawn_limit_change_rolls_back", "spawn_cleanup",
}
SITE_CHECKS = {
    "site_endpoints_registered", "site_other_factions_delegate", "site_scheduler_passthrough",
    "site_pending_blocks_capture", "site_no_human_surrender", "site_simulation_transition",
    "site_full_roster_arrives", "site_approach_movement", "site_capture_unblocks",
    "site_claimed_loot_preserved", "site_interrupted_controller_reclaimed",
    "site_ownership_change_stops_queue", "site_no_capacity_retains_roster",
    "site_stopped_controller_auto_cleanup",
    "site_recovery_remote_denied",
    "site_human_surrender_delegates", "site_asset_callbacks", "site_all_clean",
} | {f"site_{phase}_{kind}" for phase in ("initial", "cleanup", "reentry")
     for kind in ("resource", "factory", "outpost", "seaport", "milbase", "airport")}


CONTROL_CHECKS = {
    'control_override_registered',
    'control_inactive_roster',
    'control_other_factions_delegate',
    'control_road_skip',
    'control_road_frontline',
    'control_road_military',
    'control_road_weighted_roles',
    'control_field_skip',
    'control_field_frontline',
    'control_field_patrol',
    'control_template_unchanged',
    'control_overlap_rejected',
    'control_capacity_retains_queue',
    'control_duplicate_rejected',
    'control_budgeted_legacy_spawn',
    'control_simulation_transition',
    'control_death_legacy_accounting',
    'control_unspawned_blocks_capture',
    'control_full_queue_arrives',
    'control_approach_blocks_capture',
    'control_present_defender_blocks_capture',
    'control_captive_cannot_capture',
    'control_distant_unit_cannot_capture',
    'control_rebel_capture_once',
    'control_static_cleanup',
    'control_visit_regenerates',
    'control_ownership_cancels_queue',
    'control_interrupted_cleanup',
    'control_invader_capture',
    'control_generated_reset_scheduled',
    'control_reset_waits_120_minutes',
    'control_reset_waits_for_despawn',
    'control_reset_nearest_owner',
    'control_reset_ownership_race',
    'control_reset_rebel_base_preserved',
    'control_calendar_boundaries',
    'control_all_clean',
}

CITY_CHECKS = {
    'city_override_registered',
    'city_inactive_selection',
    'city_other_factions_delegate',
    'city_logistic_selection',
    'city_logistic_floor_growth_cap',
    'city_all_terrain_population_counts',
    'city_support_does_not_scale_population',
    'city_size_does_not_scale_population',
    'city_invalid_population_rejected',
    'city_missing_data_rejected',
    'city_only_infected_ownership',
    'city_frontline_keeps_population',
    'city_ruined_groups',
    'city_enemy_site_does_not_suppress',
    'city_skirmish_does_not_suppress',
    'city_nonhuman_civilians_do_not_suppress',
    'city_pressure_fixture',
    'city_unsafe_placement_retains_population',
    'city_full_reserved_allowance',
    'city_no_unregistered_allowance',
    'city_full_population_without_casualties',
    'city_server_local_basics',
    'city_shared_limit_still_enforced',
    'city_town_transfer_refused',
    'city_incoming_transfer_refused',
    'city_uses_native_ownership_route',
    'city_bounded_patrol_route',
    'city_route_idempotent',
    'city_simulation_transition',
    'city_death_not_persistent',
    'city_no_within_visit_regeneration',
    'city_actual_patrol_movement',
    'city_clear_keeps_support_ownership',
    'city_paired_events',
    'city_reentry_regenerates',
    'city_owner_change_preserves_existing',
    'city_cleanup_preserves_civilians',
    'city_ownership_stops_waiting',
    'city_ruins_stay_infected_west',
    'city_entire_large_population',
    'city_simultaneous_towns',
    'city_rotated_marker_spawn_bounds',
    'city_spread_beyond_center',
    'city_groups_stay_local',
    'city_population_cannot_overfill',
    'city_no_cross_town_transfer',
    'city_simulation_independent',
    'city_large_cleanup_releases_allowances',
    'city_interrupted_creation_cleanup',
    'city_retired_allowance_not_reusable',
    'city_road_anchor_outside_center',
    'city_rotated_ellipse_search',
    'city_invalid_spawn_search',
    'city_no_unsafe_route_fallback',
    'city_route_retry_delay',
    'city_human_route_untouched',
    'city_ownership_hooks_registered',
    'city_rejected_native_change_does_not_spawn',
    'city_active_capture_starts_population',
    'city_capture_handoff_retains_visit',
    'city_native_support_change_starts_population',
    'city_suspended_capture_waits_for_activation',
    'city_suspended_capture_resumes_population',
    'city_offscreen_capture_waits_for_visit',
    'city_inactive_ownership_hooks_delegate',
    'city_capture_handoff_rechecks_current_owner',
    'city_all_clean',
}

ADMIN_CHECKS = {
    "admin_override_registered", "admin_other_routes_delegate", "admin_load_delegate",
    "admin_unspawned_not_captured", "admin_native_police_count", "admin_native_militia_count",
    "admin_skirmish_skips", "admin_missing_building_rejected", "admin_positions_validated",
    "admin_unsafe_indoor_rejected", "admin_empty_layout_no_fallback", "admin_full_queue_retained",
    "admin_captives_and_loot", "admin_public_rescue_rejects_bot", "admin_rescue_claim_once",
    "admin_early_rescue_independent", "admin_budgeted_basics", "admin_forged_death_rejected",
    "admin_delete_requeues_not_kills", "admin_external_capture_guard", "admin_complete_roster_arrives",
    "admin_clear_captures_with_captive", "admin_capture_once", "admin_rescue_reward_separate",
    "admin_rescue_cannot_repeat", "admin_interrupted_rescue_no_reward", "admin_dead_rescue_no_reward",
    "admin_cleanup_keeps_escaped", "admin_completed_reentry_rejected", "admin_destroy_requires_clearing",
    "admin_destruction_aggression_once", "admin_ownership_cancels_queue", "admin_ruin_reentry",
    "admin_interrupted_controller_cleanup", "admin_rescue_recovery_remote_denied", "admin_all_clean",
    "admin_ruin_clear_captures",
}


REINFORCEMENT_CHECKS = {
    "reinf_overrides_registered", "reinf_other_routes_delegate", "reinf_deficit_uses_native_size",
    "reinf_enemy_target_rejected", "reinf_forced_target_rejected", "reinf_combat_target_rejected",
    "reinf_land_source_without_vehicle_places", "reinf_source_ownership", "reinf_active_source_rejected",
    "reinf_idle_source_rejected", "reinf_disconnected_source_rejected", "reinf_virtual_paid_once",
    "reinf_cooldown_blocks_repeat", "reinf_unaffordable_rejected", "reinf_cycle_quota_respected",
    "reinf_original_queue_precedes_replacements", "reinf_server_paid_foot_spawn", "reinf_approach_moves",
    "reinf_destination_cap_blocks_handoff", "reinf_arrivals_adopt_once", "reinf_duplicate_handoff_rejected",
    "reinf_completed_job_released", "reinf_adopted_death_updates_roster", "reinf_adopted_despawn_keeps_roster",
    "reinf_reentry_no_duplicate", "reinf_source_loss_refunds_survivors", "reinf_timeout_only_refunds_living",
    "reinf_late_resource_shortage_keeps_queue", "reinf_unspawned_expiry_no_refund", "reinf_stopped_controller_recovers",
    "reinf_recovery_remote_denied", "reinf_open_ticket_transfer_denied", "reinf_unknown_ticket_transfer_denied",
    "reinf_all_clean",
    "reinf_cycle_dispatches_with_budget", "reinf_destination_loss_cancels",
    "reinf_partial_arrival_waits", "reinf_fixture_arrival_established",
    "reinf_cold_atomic_route_deferred",
}


ROAMING_CHECKS = {
    "roam_override_registered", "roam_inactive_routes_delegate", "roam_no_players_no_dispatch",
    "roam_player_area_selection", "roam_infected_port_uses_land", "roam_invader_port_keeps_boat_rule",
    "roam_rebel_source_excluded", "roam_active_source_excluded", "roam_forced_source_excluded",
    "roam_empty_source_excluded", "roam_idle_source_excluded", "roam_combat_source_excluded",
    "roam_connected_outdoor_route", "roam_unscheduled_search_rejected", "roam_disconnected_route_rejected",
    "roam_enemy_destination_rejected", "roam_control_destination_excluded", "roam_route_distance_bounded",
    "roam_unsafe_endpoint_rejected", "roam_native_patrol_limit", "roam_no_route_no_counter",
    "roam_budgeted_partial_spawn", "roam_duplicate_request_blocked", "roam_cyclic_foot_waypoints",
    "roam_actual_movement", "roam_later_budgeted_batch", "roam_legacy_death_cost_once",
    "roam_distance_end_preserves_native_count", "roam_cooldown_survives_cleanup", "roam_source_loss_cancels",
    "roam_route_loss_cancels", "roam_timeout_cleans", "roam_stopped_controller_recovers",
    "roam_empty_expiry_releases_count", "roam_recovery_remote_denied", "roam_all_clean",
    "roam_foot_route_ignores_vehicle_spawn",
}


COUNTERATTACK_CHECKS = {
    "counter_override_registered", "counter_other_routes_delegate", "counter_defeated_faction_rejected",
    "counter_owned_target_rejected", "counter_invalid_requests_rejected", "counter_scheduled_required",
    "counter_foot_source_without_vehicle_places", "counter_disconnected_rejected", "counter_source_distance_bounded",
    "counter_source_loss_before_request", "counter_active_source_rejected", "counter_source_idle_and_forced",
    "counter_small_source_rejected", "counter_source_combat_rejected", "counter_hq_walk_not_spawn",
    "counter_unaffordable_no_job", "counter_scheduler_server_and_paid_basics", "counter_cooldown_blocks_duplicate",
    "counter_no_remote_capture", "counter_approach_moves", "counter_later_batch_paid_once",
    "counter_arrival_requests_native_capture", "counter_captured_active_site_adopts_once",
    "counter_adopted_death_is_persistent", "counter_adopted_cleanup_no_refund", "counter_partial_virtual_arrival_waits",
    "counter_virtual_capture_keeps_paid_roster", "counter_virtual_handoff_not_repeatable", "counter_virtual_reentry_single_roster",
    "counter_timeout_refunds_only_living", "counter_source_loss_cancels", "counter_third_party_capture_cancels",
    "counter_defeat_ends_promptly", "counter_stopped_controller_recovers", "counter_allowance_bounded_and_affordable",
    "counter_no_force_ends_without_charge", "counter_late_shortage_preserves_unpaid_queue",
    "counter_late_shortage_refunds_actual_births", "counter_recovery_remote_denied", "counter_all_clean",
    "counter_town_capture_no_saved_garrison", "counter_faction_defeat_cancels",
    "counter_town_capture_starts_population",
    "counter_quarter_strength_retreat", "counter_hard_limit_64",
    "counter_approach_activates_garrisons", "counter_unspawned_defenders_block_capture",
    "counter_pending_native_roster_blocks_capture", "counter_active_handoff_reuses_existing_assets",
    "counter_handoff_cleanup_preserves_existing_assets",
    "counter_native_distance_activates_defenders",
}


TACTICAL_CHECKS = {
    'tactical_rebuild_local_server_context',
    'tactical_overrides_registered',
    'tactical_registry_only_foot',
    'tactical_invader_registry_preserved',
    'tactical_ordinary_registry_preserved',
    'tactical_absent_registry_preserved',
    'tactical_native_neighbor_cells',
    'tactical_other_routes_delegate',
    'tactical_conventional_requests_refused',
    'tactical_refusal_preserves_foreign_lock',
    'tactical_legacy_signature_refused',
    'tactical_scheduled_required',
    'tactical_invalid_requests',
    'tactical_defeated_rejected',
    'tactical_actual_foot_navigation',
    'tactical_disconnected_rejected',
    'tactical_distance_bounded',
    'tactical_no_funds_no_charge',
    'tactical_occupied_target_finds_nearby_ground',
    'tactical_native_selection_foot',
    'tactical_native_spend_and_strike',
    'tactical_air_target_not_selected',
    'tactical_native_artillery_no_force',
    'tactical_request_waits_for_lock',
    'tactical_delayed_request_no_prepayment',
    'tactical_source_claim_blocks_second',
    'tactical_budgeted_paid_basics',
    'tactical_approach_moves',
    'tactical_no_remote_capture',
    'tactical_later_birth_paid_once',
    'tactical_pending_defenders_block_capture',
    'tactical_arrival_requests_native_capture',
    'tactical_arrival_starts_search',
    'tactical_known_enemy_keeps_search',
    'tactical_search_ends_and_refunds',
    'tactical_direct_air_foot_estimate',
    'tactical_direct_attack_pool_once',
    'tactical_attack_refunds_living_only',
    'tactical_direct_land_foot_once',
    'tactical_mixed_paid_pool_refused',
    'tactical_attack_virtual_adoption',
    'tactical_adoption_not_repeated',
    'tactical_attack_live_adoption',
    'tactical_adopted_death_updates_roster',
    'tactical_adopted_cleanup_no_refund',
    'tactical_rebuild_requires_active_mission',
    'tactical_rebuild_rechecks_owner',
    'tactical_rebuild_position_bounded',
    'tactical_rebuild_internal_remote_denied',
    'tactical_rebuild_forged_player_denied',
    'tactical_rebuild_nearest_side_rechecked',
    'tactical_rebuild_server_sizes_and_pays',
    'tactical_rebuild_single_attempt',
    'tactical_rebuild_claim_release_keeps_qrf',
    'tactical_rebuild_new_cycle',
    'tactical_source_loss_cancels',
    'tactical_faction_loss_cancels',
    'tactical_dependency_loss_cancels',
    'tactical_stopped_controller_recovers',
    'tactical_exact_quarter_retreat',
    'tactical_hard_limit_64',
    'tactical_no_force_no_charge',
    'tactical_budget_rounds_down',
    'tactical_three_allowance_ceiling',
    'tactical_late_shortage_unpaid',
    'tactical_late_shortage_actual_refund',
    'tactical_combat_pauses_births',
    'tactical_combat_clear_resumes',
    'tactical_recovery_remote_denied',
    'tactical_all_clean',
}


MAJOR_CHECKS = {
    'major_sim_no_funds_refused',
    'major_sim_negative_defence_preserved',
    'major_choose_invader_delegates',
    'major_find_invader_delegates',
    'major_choose_inactive_delegates',
    'major_find_inactive_delegates',
    'major_choose_missing_dependencies_delegates',
    'major_find_missing_dependencies_delegates',
    'major_find_native_entry_routes_to_walking',
    'major_choose_unscheduled_refused',
    'major_choose_no_funds_refused',
    'major_choose_foreign_attack_refused',
    'major_choose_no_walking_origin',
    'major_choose_town_is_horde',
    'major_choose_town_one_fixed_charge',
    'major_choose_known_hq_horde',
    'major_choose_active_invader_horde',
    'major_sim_malformed_refused',
    'major_sim_active_target_refused',
    'major_sim_rebel_target_refused',
    'major_sim_busy_garrison_refused',
    'major_sim_busy_capture_refused',
    'major_sim_foreign_attack_refused',
    'major_sim_distant_origin_refused',
    'major_sim_observed_target_refused',
    'major_sim_refused_capture_not_charged',
    'major_sim_capture_cannot_repeat',
    'major_sim_town_source_data_preserved',
    'major_choose_offscreen_invader_simulated',
    'major_sim_no_live_force',
    'major_sim_native_airportsX',
    'major_sim_native_outposts',
    'major_sim_native_milbases',
    'major_sim_native_factories',
    'major_sim_native_resourcesX',
    'major_sim_native_seaports',

    'major_functions_registered',
    'major_all_permanent_origins',
    'major_transient_origin_refused',
    'major_source_owner_checked',
    'major_active_source_refused',
    'major_forced_source_refused',
    'major_town_cooldown_separate',
    'major_military_idle_honored',
    'major_malformed_idle_refused',
    'major_source_combat_refused',
    'major_town_target_all_origins',
    'major_native_town_value',
    'major_ground_record_contract',
    'major_finite_positive_weights',
    'major_population_arrays_unchanged',
    'major_normalized_origin_weights',
    'major_duplicate_origins_removed',
    'major_invalid_population_refused',
    'major_native_garrison_threat',
    'major_owned_target_excluded',
    'major_hq_unknown_excluded',
    'major_hq_known_included',
    'major_invader_sites_targeted',
    'major_empty_enemy_threat_finite',
    'major_native_site_value',
    'major_ready_airport_priority',
    'major_no_airport_priority',
    'major_distant_town_refused',
    'major_disconnected_route_refused',
    'major_missing_navigation_refused',
    'major_native_range_respected',
    'major_no_ready_source',
    'major_defeated_refused',
    'major_inactive_refused',
    'major_missing_dependencies_refused',
    'major_invalid_target_side',
    'major_scheduled_required',
    'major_tactical_roster_guard_retained',
    'major_tactical_candidates_unchanged',
    'major_explicit_town_route',
    'major_selector_no_actors',
    'major_all_clean',
    'major_credit_allows_debt',
    'major_credit_cannot_exceed_authority',
    'major_debt_not_available_to_ordinary_jobs',
    'major_credit_context_bound',
    'major_credit_owner_bound',
    'major_stopped_worker_credit_refused',
    'major_credit_actual_refund_once',
    'major_launch_rejects_invalid_strength',
    'major_launch_preserves_foreign_attack',
    'major_launch_combines_strength',
    'major_launch_native_town_charge',
    'major_launch_preserves_town_data',
    'major_no_force_cancels_without_reward',
    'major_shared_limit_and_waiting_strength',
    'major_later_attackers_paid_in_debt',
    'major_unreached_horde_no_free_victory',
    'major_stopped_controller_recovers',
    'major_source_loss_cancels',
    'major_third_party_target_cancels',
    'major_faction_loss_cancels',
    'major_dependency_loss_cancels',
    'major_foreign_global_claim_preserved',
    'major_foreign_forced_entry_preserved',
    'major_combat_source_refused_at_launch',
    'major_exact_quarter_keeps_fighting',
    'major_real_defeat_task_succeeds',
    'major_settlement_once',
    'major_hq_charge_and_flags',
    'major_moved_hq_cancels',
    'major_petros_death_fails_task',
    'major_hq_cleanup_keeps_fixed_cost',
    'major_capture_requires_arrival',
    'major_unspawned_defenders_block_capture',
    'major_native_capture_decision',
    'major_town_loss_fails_defence_task',
    'major_town_capture_preserves_politics',
}


def collect(log_path: Path, repo: Path, expected_dependencies: bool, suite: str = "full") -> dict:
    raw = log_path.read_bytes()
    records, malformed, errors, warnings = [], [], [], []
    for number, line in enumerate(raw.decode("utf-8", errors="replace").splitlines(), 1):
        if re.search(r"Error(?::|\s+(?:in expression|Undefined|Missing|Generic|Type))", line) or re.search(
            r"Attempt to override final function - a3[ai]_", line, re.IGNORECASE
        ):
            errors.append(number)
        if any(text in line for text in ("Warning Message:", "not found or empty", "item count not multiple", "Attempt to override final function", "Server: Object", "Invalid convex component")):
            # Preserve known dependency/engine warnings separately from SQF failures.
            warnings.append({"line": number, "message": line.split(" ", 1)[-1]})
        if "[INFECTION_TEMPLATE] " not in line:
            continue
        payload = line.split("[INFECTION_TEMPLATE] ", 1)[1].strip()
        if payload.endswith('"'):
            payload = payload[:-1].replace('""', '"')
        try:
            record = parse_array(payload)
            shapes = {"start": 7, "check": 4, "spawn": 4, "complete": 4}
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
    } | GARRISON_CHECKS | COMBAT_CHECKS | BUDGET_CHECKS | SPAWN_CHECKS | SITE_CHECKS | CONTROL_CHECKS | CITY_CHECKS | ADMIN_CHECKS | REINFORCEMENT_CHECKS | ROAMING_CHECKS | COUNTERATTACK_CHECKS | TACTICAL_CHECKS | MAJOR_CHECKS | {"spawn_" + name for name in EXPECTED_ROLES} if expected_dependencies else {"both_required_patches_absent"})
    expected_roles = EXPECTED_ROLES if expected_dependencies else []
    if suite in ("administration", "reinforcements", "roaming", "counterattacks", "towns", "tactical", "major"):
        if not expected_dependencies:
            raise ValueError("Focused suites require dependencies")
        focused_checks = {"administration": ADMIN_CHECKS, "reinforcements": REINFORCEMENT_CHECKS, "roaming": ROAMING_CHECKS,
                          "counterattacks": COUNTERATTACK_CHECKS, "towns": CITY_CHECKS, "tactical": TACTICAL_CHECKS, "major": MAJOR_CHECKS}
        expected_checks = COMMON | {"active_only_for_occupants"} | focused_checks[suite]
        expected_roles = []
    checks = {
        "one_start_and_completion": complete,
        "record_schema_valid": not malformed,
        "dedicated_expected_mode": len(starts) == 1 and starts[0][2:] == ["VR", True, 2, expected_dependencies, suite],
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
        "scope": "Isolated dedicated contracts, suite=" + suite + "; no full campaign, player credit, client rescue, ACE, HC transfer or JIP acceptance",
        "suite": suite,
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
    parser.add_argument("--suite", choices=("full", "administration", "reinforcements", "roaming", "counterattacks", "towns", "tactical", "major"), default="full")
    args = parser.parse_args()
    report = collect(args.log, Path(__file__).resolve().parents[2], args.dependencies == "present", args.suite)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({"status": report["status"], "checks": report["checks"]}))
    return 0 if report["status"] == "passed" else 2


if __name__ == "__main__":
    raise SystemExit(main())
