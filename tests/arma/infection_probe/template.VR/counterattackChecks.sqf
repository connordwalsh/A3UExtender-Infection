// Capture-response contracts: real actors/resources with synthetic road geometry.
// Arrival and ownership changes below are injected. Native zoneCheck calls are
// recorded by the probe addon; full campaign capture is not certified here.
#include "\x\a3a\addons\core\script_component.hpp"
private _before = entities [[],[],true,false];
private _groupsBefore = +allGroups;
private _savedCap = A3I_activeLimit;
private _savedContext = A3I_contextLimit;
private _setLimits = {
    params ["_global","_context"];
    ["A3I_activeLimit",_global,2,"server",false] call CBA_settings_fnc_set;
    ["A3I_contextLimit",_context,2,"server",false] call CBA_settings_fnc_set;
};
private _wait = {
    params ["_predicate",["_timeout",10]];
    private _deadline = diag_tickTime + _timeout;
    waitUntil {sleep 0.05;call _predicate || {diag_tickTime > _deadline}};
    call _predicate
};
private _stats = {(["stats"] call A3I_fnc_budget) # 1};
private _source = "a3i_counter_source";
private _target = "a3i_counter_target";
private _role = "loadouts_occ_militia_Rifleman";
sidesX = [true] call A3A_fnc_createNamespace;
spawner = [true] call A3A_fnc_createNamespace;
garrison = [true] call A3A_fnc_createNamespace;
server = [true] call A3A_fnc_createNamespace;
garrisonIsChanging = false;
respawnTeamPlayer = "a3i_counter_hq";
createMarker [respawnTeamPlayer,[500,500,0]];
createMarker [_source,[4000,4500,0]];
createMarker [_target,[5000,4500,0]];
{_x setMarkerShape "ELLIPSE"; _x setMarkerSize [50,50]; spawner setVariable [_x,2]} forEach [_source,_target];
sidesX setVariable [_source,west]; sidesX setVariable [_target,teamPlayer];
outposts = [_source]; resourcesX = [_target]; factories = []; seaports = []; milbases = []; airportsX = [];
markersX = [_source,_target]; controlsX = []; citiesX = []; milAdministrationsX = [];
forcedSpawn = []; A3A_milBuildingWhitelist = [];
distanceSPWN = 1000; distanceSPWN1 = 1000; distanceForLandAttack = 2000;
NavGrid = [[[4000,4500,0],1,0,[[1,0,1000]]],[[5000,4500,0],1,0,[[0,0,1000]]]];
A3A_navCellHM = createHashMapFromArray [["4/4",[[4000,4500,0]]],["5/4",[[5000,4500,1]]]];
A3A_markerNavPoints = createHashMap;
A3A_recentDamageOcc = []; A3A_recentDamageInv = [];
A3A_resourcesDefenceOcc = 100; A3A_resourcesAttackOcc = 100;
A3A_balanceVehicleCost = 30; A3A_hasACE = false; A3A_GCThreshold = 600;
GVAR(despawnQueue) = []; GVAR(despawnerRunning) = nil;
A3A_faction_civ = createHashMapFromArray [["attributeLowCiv",true]];
A3A_faction_reb = createHashMapFromArray [["diveGear",[]],["flyGear",[]]];
A3I_test_originals = []; A3I_test_support = []; A3I_test_aggression = []; A3I_test_zones = [];
A3I_test_lootCalls = []; A3I_test_logisticsCalls = []; A3I_test_vehicleCleanup = [];
A3I_counterattackCooldowns = createHashMap;
areOccupantsDefeated = false; plusGarrison = true; tierWar = 1; aggressionOccupants = 0; hcArray = [999];
private _sourceRoster = [];
for "_i" from 1 to 16 do {_sourceRoster pushBack _role};
garrison setVariable [_source,+_sourceRoster]; garrison setVariable [_target,[]];
spawner setVariable [_target + "_flag_used",[false]];
spawner setVariable [_target + "_flag_places",[[[5000,4500,0],0]]];
private _reset = {A3I_counterattackCooldowns deleteAt _target};
private _waitJob = {[{!(_target in A3I_counterattacks)},6] call _wait};
private _stopSite = {spawner setVariable [_target,2]; [{isNil "A3I_sites" || {!(_target in A3I_sites)}},6] call _wait};
private _newPair = {
    call _reset; A3A_resourcesDefenceOcc = 100; A3A_balanceVehicleCost = 20;
    sidesX setVariable [_target,teamPlayer]; spawner setVariable [_target,0]; garrison setVariable [_target,[]];
    [_target,1,0.9] call A3I_fnc_startCounterattack;
    private _job = A3I_counterattacks get _target;
    [{count (_job get "units") == 2}] call _wait;
    _job
};
[4,4] call _setLimits;

["counter_override_registered",getText (configFile >> "CfgFunctions" >> "A3A" >> "CREATE" >> "singleAttack" >> "file")
    == "\x\a3i\addons\core\overrides\fn_singleAttack.sqf"] call _check;
[_target,east,1,0.9] call A3A_fnc_singleAttack;
A3A_faction_occ set ["infectionTemplate",""]; [_target,west,1,0.9] call A3A_fnc_singleAttack;
A3A_faction_occ set ["infectionTemplate","A3I_Infected"];
A3I_dependencies set ["available",false]; [_target,west,1,0.9] call A3A_fnc_singleAttack;
A3I_dependencies set ["available",true];
["counter_other_routes_delegate",count A3I_test_originals == 3] call _check;
areOccupantsDefeated = true;
["counter_defeated_faction_rejected",!(([_target,1,0.9] call A3I_fnc_startCounterattack) # 0)] call _check;
areOccupantsDefeated = false; sidesX setVariable [_target,west];
["counter_owned_target_rejected",([_target,1,0.9] call A3I_fnc_startCounterattack) # 2 == "ownership"] call _check;
sidesX setVariable [_target,teamPlayer];
["counter_invalid_requests_rejected",([_target,0,0.9] call A3I_fnc_startCounterattack) # 2 == "invalid_request"
    && {([_target,1.5,0.9] call A3I_fnc_startCounterattack) # 2 == "invalid_request"}
    && {([_target,1,2] call A3I_fnc_startCounterattack) # 2 == "invalid_request"}] call _check;
private _atomic = []; isNil {_atomic = [_target,1,0.9] call A3I_fnc_startCounterattack};
["counter_scheduled_required",_atomic # 2 == "scheduled_required"] call _check;
server setVariable ["spawn_" + _source,"a3i_missing_vehicle_spawn"];
private _sources = [_target] call A3I_fnc_counterattackSources;
["counter_foot_source_without_vehicle_places",count _sources == 1 && {(_sources # 0) select [0,2] isEqualTo [_source,1000]}] call _check;
server setVariable ["spawn_" + _source,nil];
NavGrid # 1 set [1,2];
["counter_disconnected_rejected",([_target] call A3I_fnc_counterattackSources) isEqualTo []] call _check;
NavGrid # 1 set [1,1]; distanceForLandAttack = 500;
["counter_source_distance_bounded",([_target] call A3I_fnc_counterattackSources) isEqualTo []] call _check;
distanceForLandAttack = 2000; sidesX setVariable [_source,east];
["counter_source_loss_before_request",([_target,1,0.9] call A3I_fnc_startCounterattack) # 2 == "source"] call _check;
sidesX setVariable [_source,west]; spawner setVariable [_source,0];
["counter_active_source_rejected",!([_source] call A3I_fnc_counterattackSourceEligible)] call _check;
spawner setVariable [_source,2]; forcedSpawn = [_source];
private _forced = !([_source] call A3I_fnc_counterattackSourceEligible);
forcedSpawn = []; server setVariable [_source,dateToNumber date + 0.01];
["counter_source_idle_and_forced",_forced && {!([_source] call A3I_fnc_counterattackSourceEligible)}] call _check;
server setVariable [_source,0]; garrison setVariable [_source,[_role]];
["counter_small_source_rejected",!([_source] call A3I_fnc_counterattackSourceEligible)] call _check;
garrison setVariable [_source,+_sourceRoster]; A3A_recentDamageOcc = [[4000,4500,60]];
["counter_source_combat_rejected",!([_source] call A3I_fnc_counterattackSourceEligible)] call _check;
A3A_recentDamageOcc = []; respawnTeamPlayer setMarkerPos getMarkerPos _target;
private _ground = getMarkerPos _target;
["counter_hq_walk_not_spawn",!(([_ground,"Zombie_B_Walker_Civ",[],_ground] call A3I_fnc_positionSafety) # 0)
    && {([_ground,"Zombie_B_Walker_Civ",[],_ground,150,false] call A3I_fnc_positionSafety) # 0}
    && {count ([_target] call A3I_fnc_counterattackSources) == 1}] call _check;
respawnTeamPlayer setMarkerPos [500,500,0]; A3A_resourcesDefenceOcc = 9;
["counter_unaffordable_no_job",([_target,1,0.9] call A3I_fnc_startCounterattack) # 2 == "resources"
    && {A3A_resourcesDefenceOcc == 9} && {count A3I_counterattacks == 0}] call _check;
A3A_resourcesDefenceOcc = 100; [2,4] call _setLimits; spawner setVariable [_target,0];
private _callsBefore = count A3I_test_originals;
[[_target,west,1,0.9],"A3A_fnc_singleAttack"] call A3A_fnc_scheduler;
[{_target in A3I_counterattacks}] call _wait;
private _record = A3I_counterattacks get _target;
[{count (_record get "units") == 2}] call _wait;
private _units = +(_record get "units");
["counter_scheduler_server_and_paid_basics",count _units == 2 && {count (_record get "queue") == 1}
    && {A3A_resourcesDefenceOcc == 80} && {(call _stats) # 1 == 2}
    && {count A3I_test_originals == _callsBefore}
    && {(_units findIf {!local _x || {owner _x != 2} || {side group _x != west}
        || {!([_x] call A3I_fnc_isManagedUnit)} || {_x getVariable ["A3A_resPool",""] != "defence"}
        || {vehicle _x != _x} || {_x getVariable ["markerX",""] != ""}}) == -1}] call _check;
["counter_approach_activates_garrisons",_units - (units west select {
    _x getVariable ["spawner",false] && {_x == effectiveCommander vehicle _x}
}) isEqualTo []] call _check;
["counter_cooldown_blocks_duplicate",([_target,1,0.9] call A3I_fnc_startCounterattack) # 2 == "cooldown"
    && {count A3I_counterattacks == 1}] call _check;
["counter_no_remote_capture",A3I_test_zones isEqualTo [] && {_record get "announced"}] call _check;
private _leader = leader ((_record get "groups") # 0);
private _startPos = getPosATL _leader;
private _moved = [{_leader distance2D _startPos > 0.5},6] call _wait;
["counter_approach_moves",_moved,[_leader distance2D _startPos]] call _check;
[4,4] call _setLimits;
private _batch = [{count (_record get "units") == 3},18] call _wait;
["counter_later_batch_paid_once",_batch && {_record get "queue" isEqualTo []}
    && {A3A_resourcesDefenceOcc == 70} && {(call _stats) # 1 == 3}] call _check;
_units = +(_record get "units");
{_x enableSimulationGlobal false; _x setPosATL [5020 + 5*_forEachIndex,4500,0]} forEach _units;
private _atTarget = (_units findIf {_x distance2D getMarkerPos _target > 200}) == -1;
spawner setVariable [_target,2]; garrison setVariable [_target,["pending_rebel_role"]];
sleep 1.5;
["counter_unspawned_defenders_block_capture",A3I_test_zones isEqualTo []] call _check;
// Run Ultimate's actual distance controller. Only its eventual defender-creator
// endpoint is recorded by the ordinary scheduler alias in the probe addon.
theBoss = objNull; distanceSPWN2 = 1000;
watchpostsFIA = []; roadblocksFIA = []; aapostsFIA = []; atpostsFIA = []; hmgpostsFIA = [];
private _distanceController = [] spawn A3A_fnc_distance;
private _activated = [{spawner getVariable [_target,2] == 0 && {
    ["originalScheduler",[[_target],"A3A_fnc_createSDKGarrisons"]] in A3I_test_originals
}},9] call _wait;
terminate _distanceController; theBoss = nil;
["counter_native_distance_activates_defenders",_activated && {
    ["originalScheduler",[[_target],"A3A_fnc_createSDKGarrisons"]] in A3I_test_originals
}] call _check;
sleep 1.5;
["counter_pending_native_roster_blocks_capture",A3I_test_zones isEqualTo []] call _check;
private _guardGroup = createGroup teamPlayer;
private _guard = _guardGroup createUnit ["I_Soldier_F",[5150,4500,0],[],0,"NONE"];
_guard allowDamage false; _guard enableSimulationGlobal false;
_guard setVariable ["markerX",_target,true];
private _captureRequested = [{count A3I_test_zones > 0},3] call _wait;
["counter_arrival_requests_native_capture",_atTarget && {_captureRequested}
    && {A3I_test_zones # 0 isEqualTo [_target,teamPlayer]}] call _check;
deleteVehicle _guard; deleteGroup _guardGroup; garrison setVariable [_target,[]];
private _existingFlag = "Flag_NATO_F" createVehicle [5070,4500,0];
private _existingCrate = "Box_NATO_Ammo_F" createVehicle [5075,4500,0];
sidesX setVariable [_target,west];
private _adopted = [{count (garrison getVariable _target) == 3},6] call _wait;
private _finished = call _waitJob;
["counter_captured_active_site_adopts_once",_adopted && {_finished} && {_record get "outcome" == "captured"}
    && {A3A_resourcesDefenceOcc == 70} && {(call _stats) # 1 == 3}
    && {((_units select {alive _x}) findIf {_x getVariable ["A3A_resPool",""] != "garrison"}) == -1}] call _check;
["counter_active_handoff_reuses_existing_assets",isNull ((A3I_sites get _target) get "flag")
    && {(A3I_sites get _target) get "crates" isEqualTo []}
    && {!((A3I_sites get _target) get "announced")} && {alive _existingFlag} && {alive _existingCrate}
    && {(_units findIf {_x getVariable ["spawner",false]}) == -1}] call _check;
{_x enableSimulationGlobal true} forEach _units;
(_units # 0) setDamage 1;
[{count (garrison getVariable _target) == 2}] call _wait;
["counter_adopted_death_is_persistent",count (garrison getVariable _target) == 2 && {A3A_resourcesDefenceOcc == 70}] call _check;
call _stopSite;
["counter_adopted_cleanup_no_refund",count (garrison getVariable _target) == 2
    && {A3A_resourcesDefenceOcc == 70} && {(call _stats) # 1 == 0}] call _check;
["counter_handoff_cleanup_preserves_existing_assets",alive _existingFlag && {alive _existingCrate}] call _check;
deleteVehicle _existingFlag; deleteVehicle _existingCrate;
{deleteVehicle _x} forEach _units;

// Offscreen victory: save only complete, genuinely arrived groups and retire
// their physical copies in the same transaction without a prepaid refund.
_record = call _newPair; _units = +(_record get "units");
private _group = (_record get "groups") # 0;
leader _group enableSimulationGlobal false; leader _group setPosATL [5020,4500,0];
spawner setVariable [_target,2]; sidesX setVariable [_target,west];
sleep 1.5;
["counter_partial_virtual_arrival_waits",garrison getVariable _target isEqualTo []
    && {_target in A3I_counterattacks} && {(_record get "lastHandoff") # 2 == "invalid_arrivals"}] call _check;
{_x enableSimulationGlobal false; _x setPosATL [5020 + 5*_forEachIndex,4500,0]} forEach _units;
_atTarget = (_units findIf {_x distance2D getMarkerPos _target > 200}) == -1;
_finished = call _waitJob; sleep 0.3;
["counter_virtual_capture_keeps_paid_roster",_atTarget && {_finished} && {count (garrison getVariable _target) == 2}
    && {A3A_resourcesDefenceOcc == 80} && {(call _stats) select [1,3] isEqualTo [0,0,0]}] call _check;
private _repeat = [_group,_target,true] call A3I_fnc_adoptReinforcement;
["counter_virtual_handoff_not_repeatable",!(_repeat # 0) && {count (garrison getVariable _target) == 2}] call _check;
spawner setVariable [_target,0]; [_target,"Resource"] call A3I_fnc_startSite;
[{count ((A3I_sites get _target) get "units") == 2}] call _wait;
["counter_virtual_reentry_single_roster",count ((A3I_sites get _target) get "units") == 2
    && {(A3I_sites get _target) get "queue" isEqualTo []} && {A3A_resourcesDefenceOcc == 80}] call _check;
call _stopSite;

// Town recapture keeps Ultimate's transient patrol model, not a saved roster.
resourcesX = []; citiesX = [_target];
A3A_townData = createHashMapFromArray [[_target,[10,0,50,50]]];
destroyedSites = [];
_record = call _newPair; sidesX setVariable [_target,west];
_finished = call _waitJob;
private _townRefund = [{A3A_resourcesDefenceOcc == 100},3] call _wait;
["counter_town_capture_no_saved_garrison",_finished && {_townRefund}
    && {_record get "outcome" == "captured"} && {garrison getVariable _target isEqualTo []}] call _check;
private _townRecord = A3I_sites get _target;
[{_townRecord get "queue" isEqualTo []}] call _wait;
["counter_town_capture_starts_population",count (_townRecord get "units") == 10
    && {!(_townRecord get "announced")} && {(call _stats) select [1,3] isEqualTo [10,0,1]}
    && {((_townRecord get "units") findIf {_x getVariable ["A3A_resPool",""] != "legacy"}) == -1}] call _check;
call _stopSite;
citiesX = []; resourcesX = [_target];

_record = call _newPair; _units = +(_record get "units");
(_units # 0) setDamage 1; _record set ["endTime",time - 1];
_finished = call _waitJob;
private _refund = [{A3A_resourcesDefenceOcc == 90},3] call _wait;
["counter_timeout_refunds_only_living",_finished && {_refund} && {_record get "outcome" == "timeout"}
    && {garrison getVariable _target isEqualTo []}] call _check;
{deleteVehicle _x} forEach _units;
_record = call _newPair; sidesX setVariable [_source,east]; _finished = call _waitJob;
_refund = [{A3A_resourcesDefenceOcc == 100},3] call _wait;
["counter_source_loss_cancels",_finished && {_refund} && {_record get "outcome" == "cancelled"}] call _check;
sidesX setVariable [_source,west]; _record = call _newPair;
sidesX setVariable [_target,east]; _finished = call _waitJob;
_refund = [{A3A_resourcesDefenceOcc == 100},3] call _wait;
["counter_third_party_capture_cancels",_finished && {_refund} && {_record get "outcome" == "cancelled"}] call _check;
_record = call _newPair; areOccupantsDefeated = true; _finished = call _waitJob;
_refund = [{A3A_resourcesDefenceOcc == 100},3] call _wait;
["counter_faction_defeat_cancels",_finished && {_refund} && {_record get "outcome" == "cancelled"}] call _check;
areOccupantsDefeated = false;
_record = call _newPair; _units = +(_record get "units");
{_x setDamage 1} forEach _units;
_finished = call _waitJob;
["counter_defeat_ends_promptly",_finished && {_record get "outcome" == "defeated"} && {A3A_resourcesDefenceOcc == 80}] call _check;
{deleteVehicle _x} forEach _units;
call _reset; [8,8] call _setLimits; A3A_resourcesDefenceOcc = 100; A3A_balanceVehicleCost = 80;
[_target,1,0.9] call A3I_fnc_startCounterattack; _record = A3I_counterattacks get _target;
private _fullForce = [{count (_record get "units") == 8},20] call _wait;
_units = +(_record get "units");
{_x setDamage 1} forEach (_units select [0,7]);
_finished = call _waitJob; _refund = [{A3A_resourcesDefenceOcc == 30},3] call _wait;
["counter_quarter_strength_retreat",_fullForce && {_finished} && {_refund}
    && {_record get "outcome" == "defeated"}] call _check;
{deleteVehicle _x} forEach _units; [4,4] call _setLimits;
_record = call _newPair; terminate (_record get "script"); _finished = call _waitJob;
_refund = [{A3A_resourcesDefenceOcc == 100},3] call _wait;
["counter_stopped_controller_recovers",_finished && {_refund} && {_record get "outcome" == "interrupted"}
    && {(call _stats) select [1,3] isEqualTo [0,0,0]}] call _check;

// The no-force outcome closes even when the global cap never permits a birth.
call _reset; [1,4] call _setLimits;
private _pressure = ["reserve",["counter_pressure",1,1]] call A3I_fnc_budget;
A3A_resourcesDefenceOcc = 100000;
[_target,1000000,0.9] call A3I_fnc_startCounterattack;
_record = A3I_counterattacks get _target;
private _bounded = count (_record get "queue") == 64;
sleep 0.5; _record set ["spawnDeadline",time - 1]; _finished = call _waitJob;
["counter_hard_limit_64",_bounded && {_finished} && {A3A_resourcesDefenceOcc == 100000}] call _check;
call _reset; A3A_resourcesDefenceOcc = 100;
[_target,1000000,0.9] call A3I_fnc_startCounterattack;
_record = A3I_counterattacks get _target;
["counter_allowance_bounded_and_affordable",count (_record get "queue") == 10] call _check;
sleep 0.5; _record set ["spawnDeadline",time - 1]; _finished = call _waitJob;
["counter_no_force_ends_without_charge",_finished && {_record get "outcome" == "no_force"}
    && {!(_record get "announced")} && {A3A_resourcesDefenceOcc == 100}] call _check;
["close",[_pressure # 1 # 0]] call A3I_fnc_budget;

// Funds can change between early and later batches. Unborn roles are not paid.
call _reset; [2,4] call _setLimits; A3A_balanceVehicleCost = 60;
[_target,1,0.9] call A3I_fnc_startCounterattack; _record = A3I_counterattacks get _target;
[{count (_record get "units") == 2}] call _wait;
A3A_resourcesDefenceOcc = 5; [4,4] call _setLimits;
sleep 16;
["counter_late_shortage_preserves_unpaid_queue",count (_record get "units") == 2
    && {count (_record get "queue") == 4} && {A3A_resourcesDefenceOcc == 5}] call _check;
_record set ["endTime",time - 1]; _finished = call _waitJob;
_refund = [{A3A_resourcesDefenceOcc == 25},3] call _wait;
["counter_late_shortage_refunds_actual_births",_finished && {_refund}] call _check;
private _foreign = [{A3I_test_counterTicks = A3I_test_counterTicks + 1},0.1] call CBA_fnc_addPerFrameHandler;
A3I_test_counterTicks = 0;
[[],_foreign] remoteExecCall ["A3I_fnc_counterattackWatchdog",2]; sleep 0.6;
["counter_recovery_remote_denied",A3I_test_counterTicks >= 2] call _check;
[_foreign] call CBA_fnc_removePerFrameHandler;
{deleteVehicle _x} forEach [sidesX,spawner,garrison,server];
{deleteMarker _x} forEach [_source,_target,respawnTeamPlayer];
sidesX = nil; spawner = nil; garrison = nil; server = nil; respawnTeamPlayer = nil;
// Controllers must finish their own cleanup; the fixture must not hide leaks.
[{allGroups - _groupsBefore isEqualTo []},8] call _wait;
[_savedCap,_savedContext] call _setLimits;
GVAR(despawnQueue) = [];
private _remaining = (entities [[],[],true,false]) - _before;
["counter_all_clean",_remaining isEqualTo [] && {(allGroups - _groupsBefore) isEqualTo []}
    && {(call _stats) select [1,3] isEqualTo [0,0,0]} && {count A3I_counterattacks == 0}
    && {isNil "A3I_counterattackWatchdogHandle"} && {count A3I_sites == 0}
    && {isNil "A3I_siteWatchdogHandle"},[_remaining apply {typeOf _x},call _stats]] call _check;
