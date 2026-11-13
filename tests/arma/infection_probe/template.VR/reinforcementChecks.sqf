// Real actors/resources/rosters, with a synthetic two-node road graph in VR.
// Movement is observed separately. Position changes below inject arrival/races;
// this fixture does not certify a long walk or Redux pathfinding.
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
private _source = "a3i_reinf_source";
private _target = "a3i_reinf_target";
private _role = "loadouts_occ_militia_Rifleman";
sidesX = [true] call A3A_fnc_createNamespace;
spawner = [true] call A3A_fnc_createNamespace;
garrison = [true] call A3A_fnc_createNamespace;
server = [true] call A3A_fnc_createNamespace;
killZones = [true] call A3A_fnc_createNamespace;
garrisonIsChanging = false;
respawnTeamPlayer = "a3i_reinf_hq";
createMarker [respawnTeamPlayer,[500,500,0]];
createMarker [_source,[4000,4500,0]];
createMarker [_target,[5000,4500,0]];
{_x setMarkerShape "ELLIPSE"; _x setMarkerSize [50,50]; sidesX setVariable [_x,west]; spawner setVariable [_x,2]} forEach [_source,_target];
outposts = [_source]; resourcesX = [_target]; factories = []; seaports = []; milbases = []; airportsX = [];
markersX = [_source,_target]; controlsX = []; citiesX = []; milAdministrationsX = [];
forcedSpawn = []; A3A_milBuildingWhitelist = [];
distanceSPWN = 1000; distanceSPWN1 = 1000; distanceForLandAttack = 1000;
NavGrid = [[[4000,4500,0],1,0,[[1,0,1000]]],[[5000,4500,0],1,0,[[0,0,1000]]]];
A3A_navCellHM = createHashMapFromArray [["4/4",[[4000,4500,0]]],["5/4",[[5000,4500,1]]]];
A3A_markerNavPoints = createHashMap;
A3I_reinforcementRoutes = createHashMap;
A3A_recentDamageOcc = []; A3A_recentDamageInv = [];
A3A_resourcesDefenceOcc = 100; A3A_resourcesAttackOcc = 1000;
A3A_hasACE = false; A3A_GCThreshold = 600;
GVAR(despawnQueue) = []; GVAR(despawnerRunning) = nil;
A3A_faction_civ = createHashMapFromArray [["attributeLowCiv",true]];
A3A_faction_reb = createHashMapFromArray [["diveGear",[]],["flyGear",[]]];
A3I_test_originals = []; A3I_test_support = []; A3I_test_aggression = []; A3I_test_zones = [];
A3I_test_lootCalls = []; A3I_test_logisticsCalls = []; A3I_test_vehicleCleanup = [];
A3I_reinforcementCooldowns = createHashMap;
hcArray = [999]; tierWar = 1; aggressionOccupants = 0;
aggressionInvaders = 0; gameMode = 3; AAFpatrols = 100; A3A_balancePlayerScale = 1; killZoneRemove = 0;
private _sourceRoster = [];
for "_i" from 1 to 16 do {_sourceRoster pushBack _role};
garrison setVariable [_source,_sourceRoster];
garrison setVariable [_target,[]];
spawner setVariable [_target + "_flag_used",[false]];
spawner setVariable [_target + "_flag_places",[[[5000,4500,0],0]]];
private _stopSite = {
    spawner setVariable [_target,2];
    [{isNil "A3I_sites" || {!(_target in A3I_sites)}},6] call _wait
};
private _clearCooldown = {A3I_reinforcementCooldowns deleteAt _target};
private _waitJob = {
    [{!(_target in A3I_reinforcements)},6] call _wait
};
[12,8] call _setLimits;

["reinf_overrides_registered",getText (configFile >> "CfgFunctions" >> "A3A" >> "CREATE" >> "reinforcementsAI" >> "file")
    == "\x\a3i\addons\core\overrides\fn_reinforcementsAI.sqf"
    && {getText (configFile >> "CfgFunctions" >> "A3A" >> "CREATE" >> "patrolReinf" >> "file")
        == "\x\a3i\addons\core\overrides\fn_patrolReinf.sqf"}] call _check;
[_target,_source,4,east] call A3A_fnc_patrolReinf;
A3A_faction_occ set ["infectionTemplate",""];
[] call A3A_fnc_reinforcementsAI;
[_target,_source,4,west] call A3A_fnc_patrolReinf;
A3A_faction_occ set ["infectionTemplate","A3I_Infected"];
A3I_dependencies set ["available",false]; [] call A3A_fnc_reinforcementsAI;
A3I_dependencies set ["available",true];
["reinf_other_routes_delegate",count A3I_test_originals == 4] call _check;
private _eligible = [_target] call A3I_fnc_reinforcementEligible;
["reinf_deficit_uses_native_size",_eligible # 0 && {_eligible # 1 == ([_target] call A3A_fnc_garrisonSize)}] call _check;
sidesX setVariable [_target,east];
["reinf_enemy_target_rejected",!(([_target] call A3I_fnc_reinforcementEligible) # 0)] call _check;
sidesX setVariable [_target,west]; forcedSpawn = [_target];
["reinf_forced_target_rejected",([_target] call A3I_fnc_reinforcementEligible) # 2 == "forced_spawn"] call _check;
forcedSpawn = []; A3A_recentDamageOcc = [[5000,4500,60]];
["reinf_combat_target_rejected",([_target] call A3I_fnc_reinforcementEligible) # 2 == "combat"] call _check;
A3A_recentDamageOcc = [];
private _coldSources = [];
isNil {_coldSources = [_target] call A3I_fnc_reinforcementSources};
["reinf_cold_atomic_route_deferred",_coldSources isEqualTo [] && {count A3I_reinforcementRoutes == 0}] call _check;
private _sources = [_target] call A3I_fnc_reinforcementSources;
["reinf_land_source_without_vehicle_places",_sources isEqualTo [[_source,1000]],_sources] call _check;
sidesX setVariable [_source,east];
["reinf_source_ownership",([_target] call A3I_fnc_reinforcementSources) isEqualTo []] call _check;
sidesX setVariable [_source,west]; spawner setVariable [_source,0];
["reinf_active_source_rejected",([_target] call A3I_fnc_reinforcementSources) isEqualTo []] call _check;
spawner setVariable [_source,2]; server setVariable [_source,dateToNumber date + 0.01];
["reinf_idle_source_rejected",([_target] call A3I_fnc_reinforcementSources) isEqualTo []] call _check;
server setVariable [_source,0]; NavGrid # 1 set [1,2];
A3I_reinforcementRoutes = createHashMap;
["reinf_disconnected_source_rejected",([_target] call A3I_fnc_reinforcementSources) isEqualTo []] call _check;
NavGrid # 1 set [1,1];
A3I_reinforcementRoutes = createHashMap;
private _result = [_target,_source,4] call A3I_fnc_requestReinforcement;
["reinf_virtual_paid_once",_result isEqualTo [true,4,"virtual"] && {count (garrison getVariable _target) == 4}
    && {A3A_resourcesDefenceOcc == 60} && {(call _stats) # 1 == 0},_result] call _check;
_result = [_target,_source,4] call A3I_fnc_requestReinforcement;
["reinf_cooldown_blocks_repeat",_result # 2 == "cooldown" && {A3A_resourcesDefenceOcc == 60}] call _check;
call _clearCooldown; A3A_resourcesDefenceOcc = 9;
["reinf_unaffordable_rejected",([_target,_source,4] call A3I_fnc_requestReinforcement) # 2 == "resources"] call _check;
A3A_resourcesDefenceOcc = 100;
garrison setVariable [_target,[]];
// The existing resource-cycle quota at 100 resources is zero, so no free refill.
[] call A3A_fnc_reinforcementsAI;
["reinf_cycle_quota_respected",garrison getVariable _target isEqualTo [] && {A3A_resourcesDefenceOcc == 100}] call _check;
A3A_resourcesDefenceOcc = 1000;
[] call A3A_fnc_reinforcementsAI;
private _virtualCount = count (garrison getVariable _target);
["reinf_cycle_dispatches_with_budget",_virtualCount >= 4 && {_virtualCount <= 8}
    && {A3A_resourcesDefenceOcc == 1000 - 10 * _virtualCount}] call _check;
call _clearCooldown; A3A_resourcesDefenceOcc = 100;
garrison setVariable [_target,[_role,_role]];
[1,1] call _setLimits; spawner setVariable [_target,0];
[_target,"Resource"] call A3I_fnc_startSite;
[{count ((A3I_sites get _target) get "units") == 1}] call _wait;
["reinf_original_queue_precedes_replacements",([_target] call A3I_fnc_reinforcementEligible) # 2 == "original_queue"] call _check;
call _stopSite;
garrison setVariable [_target,[]]; [12,4] call _setLimits;
spawner setVariable [_target,0]; [_target,"Resource"] call A3I_fnc_startSite;
sleep 0.4;
private _pressure = ["reserve",["site:" + _target,3,24]] call A3I_fnc_budget;
[[ _target,_source,2,west],"A3A_fnc_patrolReinf"] call A3A_fnc_scheduler;
[{!isNil "A3I_reinforcements" && {_target in A3I_reinforcements}}] call _wait;
private _job = A3I_reinforcements get _target;
private _spawned = [{count (_job get "units") == 2}] call _wait;
private _units = +(_job get "units");
private _group = (_job get "groups") # 0;
private _ticket = (_units # 0) getVariable "A3I_budgetTicket";
["reinf_server_paid_foot_spawn",_spawned && {local _group} && {owner (_units # 0) == 2}
    && {A3A_resourcesDefenceOcc == 80} && {garrison getVariable _target isEqualTo []}
    && {(_units findIf {_x getVariable ["markerX",""] != "" || {primaryWeapon _x != ""}}) == -1},
    [count _units,A3A_resourcesDefenceOcc,call _stats]] call _check;
private _startPosition = getPosATL leader _group;
private _moved = [{leader _group distance2D _startPosition > 0.5},12] call _wait;
["reinf_approach_moves",_moved,[leader _group distance2D _startPosition]] call _check;
// A leader alone does not count an unarrived follower as a saved defender.
leader _group setPosATL [5020,4500,0];
sleep 1.1;
["reinf_partial_arrival_waits",garrison getVariable _target isEqualTo []
    && {(_job getOrDefault ["lastHandoff",[]]) isEqualTo [false,0,"invalid_arrivals"]}] call _check;
// Freeze only fixture actors while injecting the complete arrival. Observed
// moving-AI repositioning could leave a follower at the origin; assert the actual
// resulting positions before testing the capacity gate and atomic handoff.
{_x enableSimulationGlobal false} forEach _units;
{_x setPosATL [5020 + _forEachIndex * 5,4500,0]} forEach _units;
sleep 0.2;
["reinf_fixture_arrival_established",(_units findIf {_x distance2D getMarkerPos _target > 200}) == -1,
    _units apply {_x distance2D getMarkerPos _target}] call _check;
sleep 1.5;
["reinf_destination_cap_blocks_handoff",garrison getVariable _target isEqualTo []
    && {(A3I_budgetRecords get _ticket) # 0 == _job get "context"}] call _check;
["close",[_pressure # 1 # 0]] call A3I_fnc_budget;
private _adopted = [{count (garrison getVariable _target) == 2},5] call _wait;
private _site = A3I_sites get _target;
["reinf_arrivals_adopt_once",_adopted && {count (_site get "units") == 2}
    && {_site get "queue" isEqualTo []} && {A3A_resourcesDefenceOcc == 80}
    && {(A3I_budgetRecords get _ticket) # 0 == "site:" + _target}
    && {_group getVariable ["A3I_garrisoned",""] == _target},
    [_job getOrDefault ["lastHandoff",[]],_units apply {[_x distance2D getMarkerPos _target,alive _x,
        _x getVariable ["A3A_resPool",""],_x getVariable ["markerX",""]]},call _stats]] call _check;
["reinf_duplicate_handoff_rejected",([_group,_target] call A3I_fnc_adoptReinforcement) # 2 == "already_adopted"
    && {count (garrison getVariable _target) == 2}] call _check;
{_x enableSimulationGlobal true} forEach _units;
call _waitJob;
["reinf_completed_job_released",!(_target in A3I_reinforcements) && {isNil "A3I_reinforcementWatchdogHandle"}
    && {(call _stats) select [1,3] isEqualTo [2,0,1]}] call _check;
(_units # 0) setDamage 1;
[{count (garrison getVariable _target) == 1}] call _wait;
["reinf_adopted_death_updates_roster",count (garrison getVariable _target) == 1 && {A3A_resourcesDefenceOcc == 80}] call _check;
call _stopSite;
["reinf_adopted_despawn_keeps_roster",count (garrison getVariable _target) == 1
    && {A3A_resourcesDefenceOcc == 80} && {(call _stats) # 1 == 0}] call _check;
{deleteVehicle _x} forEach _units;
spawner setVariable [_target,0]; [_target,"Resource"] call A3I_fnc_startSite;
[{count ((A3I_sites get _target) get "units") == 1}] call _wait;
["reinf_reentry_no_duplicate",count ((A3I_sites get _target) get "units") == 1
    && {(A3I_sites get _target) get "queue" isEqualTo []}] call _check;
call _stopSite;

garrison setVariable [_target,[]]; spawner setVariable [_target,0];
[_target,"Resource"] call A3I_fnc_startSite; call _clearCooldown;
[_target,_source,2] call A3I_fnc_requestReinforcement;
_job = A3I_reinforcements get _target;
[{count (_job get "units") == 2}] call _wait;
private _paid = A3A_resourcesDefenceOcc;
sidesX setVariable [_source,east];
private _cancelled = call _waitJob;
private _refunded = [{A3A_resourcesDefenceOcc == _paid + 20},3] call _wait;
["reinf_source_loss_refunds_survivors",_cancelled && {_refunded}
    && {garrison getVariable _target isEqualTo []} && {(call _stats) # 1 == 0}] call _check;
sidesX setVariable [_source,west]; call _clearCooldown;
[_target,_source,2] call A3I_fnc_requestReinforcement;
_job = A3I_reinforcements get _target;
[{count (_job get "units") == 2}] call _wait;
_units = +(_job get "units"); _paid = A3A_resourcesDefenceOcc;
(_units # 0) setDamage 1;
_job set ["travelDeadline",time - 1];
_cancelled = call _waitJob;
_refunded = [{A3A_resourcesDefenceOcc == _paid + 10},3] call _wait;
["reinf_timeout_only_refunds_living",_cancelled && {_refunded}
    && {garrison getVariable _target isEqualTo []},[A3A_resourcesDefenceOcc,_paid]] call _check;
{deleteVehicle _x} forEach _units;
call _clearCooldown;
// Deplete resources after planning, before the scheduled creation can run.
isNil {
    [_target,_source,2] call A3I_fnc_requestReinforcement;
    _job = A3I_reinforcements get _target;
    A3A_resourcesDefenceOcc = 5;
};
sleep 1.5;
["reinf_late_resource_shortage_keeps_queue",_job get "units" isEqualTo []
    && {count (_job get "queue") == 2} && {A3A_resourcesDefenceOcc == 5}] call _check;
_job set ["spawnDeadline",time - 1];
_cancelled = call _waitJob;
["reinf_unspawned_expiry_no_refund",_cancelled && {A3A_resourcesDefenceOcc == 5}] call _check;
A3A_resourcesDefenceOcc = 100; call _clearCooldown;
[_target,_source,2] call A3I_fnc_requestReinforcement;
_job = A3I_reinforcements get _target;
[{count (_job get "units") > 0}] call _wait;
terminate (_job get "script");
_cancelled = call _waitJob;
_refunded = [{A3A_resourcesDefenceOcc == 100},3] call _wait;
["reinf_stopped_controller_recovers",_cancelled && {_refunded}
    && {(call _stats) select [1,3] isEqualTo [0,0,0]}] call _check;
call _clearCooldown;
[_target,_source,2] call A3I_fnc_requestReinforcement;
_job = A3I_reinforcements get _target;
[{count (_job get "units") == 2}] call _wait;
sidesX setVariable [_target,east];
_cancelled = call _waitJob;
_refunded = [{A3A_resourcesDefenceOcc == 100},3] call _wait;
["reinf_destination_loss_cancels",_cancelled && {_refunded}
    && {garrison getVariable _target isEqualTo []} && {(call _stats) # 1 == 0}] call _check;
sidesX setVariable [_target,west];
private _foreign = [{A3I_test_reinfRecovery = A3I_test_reinfRecovery + 1},0.1] call CBA_fnc_addPerFrameHandler;
A3I_test_reinfRecovery = 0;
[[],_foreign] remoteExecCall ["A3I_fnc_reinforcementWatchdog",2]; sleep 0.6;
["reinf_recovery_remote_denied",A3I_test_reinfRecovery >= 2] call _check;
[_foreign] call CBA_fnc_removePerFrameHandler;
private _openTicket = ["reserve",["reinf_transfer_probe",1,1]] call A3I_fnc_budget;
["reinf_open_ticket_transfer_denied",(["transfer",[_openTicket # 1 # 0,"site:" + _target,24]] call A3I_fnc_budget) # 2
    == "ticket_not_closed"] call _check;
["close",[_openTicket # 1 # 0]] call A3I_fnc_budget;
["reinf_unknown_ticket_transfer_denied",(["transfer",["unknown","site:" + _target,24]] call A3I_fnc_budget) # 2
    == "unknown_ticket"] call _check;
call _stopSite;
{deleteVehicle _x} forEach [sidesX,spawner,garrison,server,killZones];
{deleteMarker _x} forEach [_source,_target,respawnTeamPlayer];
sidesX = nil; spawner = nil; garrison = nil; server = nil; respawnTeamPlayer = nil;
sleep 3;
{if (count units _x == 0) then {deleteGroup _x}} forEach (allGroups - _groupsBefore);
[_savedCap,_savedContext] call _setLimits;
GVAR(despawnQueue) = [];
private _remaining = (entities [[],[],true,false]) - _before;
["reinf_all_clean",_remaining isEqualTo [] && {(allGroups - _groupsBefore) isEqualTo []}
    && {(call _stats) select [1,3] isEqualTo [0,0,0]} && {count A3I_sites == 0}
    && {count A3I_reinforcements == 0} && {isNil "A3I_reinforcementWatchdogHandle"}
    && {isNil "A3I_siteWatchdogHandle"},[_remaining apply {typeOf _x},call _stats]] call _check;
