// Real native support selection/registries with synthetic navigation and injected
// arrivals/deadlines. Ordinary constructors are recorded by the probe addon.
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
private _source = "a3i_support_source";
private _target = "a3i_support_target";
private _position = [5000,4500,0];
private _role = "loadouts_occ_militia_Rifleman";
sidesX = [true] call A3A_fnc_createNamespace;
spawner = [true] call A3A_fnc_createNamespace;
garrison = [true] call A3A_fnc_createNamespace;
server = [true] call A3A_fnc_createNamespace;
garrisonIsChanging = false;
respawnTeamPlayer = "a3i_support_hq";
createMarker [respawnTeamPlayer,[500,500,0]];
createMarker [_source,[4000,4500,0]];
createMarker [_target,_position];
{_x setMarkerShape "ELLIPSE"; _x setMarkerSize [50,50]; spawner setVariable [_x,2]} forEach [_source,_target];
sidesX setVariable [_source,west]; sidesX setVariable [_target,teamPlayer];
outposts = [_source]; resourcesX = [_target]; factories = []; seaports = []; milbases = []; airportsX = [];
markersX = [_source,_target]; controlsX = []; citiesX = []; milAdministrationsX = [];
forcedSpawn = []; antennas = []; antennasDead = []; A3A_milBuildingWhitelist = [];
distanceSPWN = 1000; distanceSPWN1 = 1000; distanceForLandAttack = 2000; distanceMission = 3000;
NavGrid = [[[4000,4500,0],1,0,[[1,0,1000]]],[[5000,4500,0],1,0,[[0,0,1000]]]];
A3A_navCellHM = createHashMap;
{_forEachIndex call A3A_fnc_addToNavCells} forEach NavGrid;
A3A_markerNavPoints = createHashMap;
A3A_recentDamageOcc = []; A3A_recentDamageInv = [];
A3A_resourcesDefenceOcc = 100; A3A_resourcesAttackOcc = 100; A3A_resourcesDefenceInv = 100;
A3A_balanceVehicleCost = 30; A3A_hasACE = false; A3A_GCThreshold = 600;
A3A_balanceResourceRate = 100; A3A_invaderBalanceMul = 10; gameMode = 3;
A3A_groundVehicleThreat = createHashMap; A3A_vehicleResourceCosts = createHashMap;
A3A_faction_all = createHashMapFromArray [["vehiclesFixedWing",[]]];
A3A_faction_civ = createHashMapFromArray [["attributeLowCiv",true]];
A3A_faction_reb = createHashMapFromArray [["diveGear",[]],["flyGear",[]]];
A3A_faction_inv = createHashMap;
GVAR(despawnQueue) = []; GVAR(despawnerRunning) = nil;
A3I_test_originals = []; A3I_test_support = []; A3I_test_aggression = []; A3I_test_zones = [];
A3I_test_lootCalls = []; A3I_test_logisticsCalls = []; A3I_test_vehicleCleanup = [];
areOccupantsDefeated = false; plusGarrison = true; tierWar = 1;
aggressionOccupants = 0; aggressionInvaders = 0; hcArray = [999];
occupantsRadioKeys = 0; invaderRadioKeys = 0; A3A_curHQInfoOcc = 0; A3A_curHQInfoInv = 0;
A3U_disablePATCOMMortars = false; allowUnfairSupports = true;
allowFuturisticSupports = true; allowFuturisticUnfairSupports = true;
private _sourceRoster = [];
for "_i" from 1 to 16 do {_sourceRoster pushBack _role};
garrison setVariable [_source,+_sourceRoster]; garrison setVariable [_target,[]];
spawner setVariable [_target + "_flag_used",[false]];
spawner setVariable [_target + "_flag_places",[[_position,0]]];
private _reset = {server setVariable [_source,0]};
private _waitJob = {params ["_job"]; [{!((_job get "name") in A3I_tacticalSupports)},7] call _wait};
private _finish = {params ["_job"]; _job set ["endTime",time - 1]; [_job] call _waitJob};
private _pair = {
    params ["_name",["_pool","defence"]];
    call _reset; A3A_resourcesDefenceOcc = 100; A3A_resourcesAttackOcc = 100;
    [_name,_pool,20,objNull,_position,0.9,0] call A3I_fnc_startTacticalSupport;
    private _job = A3I_tacticalSupports get _name;
    [{count (_job get "units") == 2}] call _wait;
    _job
};
[4,4] call _setLimits;

["tactical_overrides_registered",( ["initSupports","createSupport","SUP_QRFLand","SUP_QRFAir"] findIf {
    getText (configFile >> "CfgFunctions" >> "A3A" >> "Supports" >> _x >> "file")
        != ("\x\a3i\addons\core\overrides\fn_" + _x + ".sqf")
}) == -1] call _check;
[] call A3I_fnc_originalInitSupports;
private _nativeInv = +A3A_supportTypesInv;
private _nativeOcc = +A3A_supportTypesOcc;
[] call A3A_fnc_initSupports;
["tactical_registry_only_foot",keys A3A_supportTypesOcc isEqualTo ["QRFLAND"]
    && {A3A_supportTypesOcc get "QRFLAND" isEqualTo (_nativeOcc get "QRFLAND")}] call _check;
["tactical_invader_registry_preserved",A3A_supportTypesInv isEqualTo _nativeInv
    && {"QRFAIR" in A3A_supportTypesInv} && {A3A_supportMarkerTypes isNotEqualTo []}] call _check;
A3A_faction_occ set ["infectionTemplate",""]; [] call A3A_fnc_initSupports;
["tactical_ordinary_registry_preserved",A3A_supportTypesOcc isEqualTo _nativeOcc] call _check;
A3A_faction_occ set ["infectionTemplate","A3I_Infected"];
A3I_dependencies set ["available",false]; [] call A3A_fnc_initSupports;
["tactical_absent_registry_preserved",A3A_supportTypesOcc isEqualTo _nativeOcc] call _check;
A3I_dependencies set ["available",true]; [] call A3A_fnc_initSupports;
["tactical_native_neighbor_cells",count (A3A_navCellHM get "4/4") == 2
    && {[[4990,4500,0]] call A3A_fnc_getNearestNavPoint == 1}
    && {[[5010,4500,0]] call A3A_fnc_getNearestNavPoint == 1}] call _check;
{["x",east,"attack",30,objNull,_position,0.9] call _x} forEach [A3A_fnc_SUP_QRFLand,A3A_fnc_SUP_QRFAir];
["QRFLAND",east,[],30,objNull,_position,0.9] call A3A_fnc_createSupport;
A3A_faction_occ set ["infectionTemplate",""];
["QRFLAND",west,[],30,objNull,_position,0.9] call A3A_fnc_createSupport;
A3A_faction_occ set ["infectionTemplate","A3I_Infected"];
A3I_dependencies set ["available",false];
["QRFLAND",west,[],30,objNull,_position,0.9] call A3A_fnc_createSupport;
A3I_dependencies set ["available",true];
["tactical_other_routes_delegate",count A3I_test_originals == 5] call _check;
private _refused = true;
{
    if (["" + _x,west,[],30,objNull,_position,0.9] call A3A_fnc_createSupport != "") then {_refused = false};
} forEach ["QRFAIR","QRFVEHAIRDROP","QRFORBITAL","TANK","CAS","ARTILLERY","MORTAR","HOWITZER","AIRSTRIKE","CRUISEMISSILE","SAM","ORBITALSTRIKE","UAVAttack","CARPETBOMBS","GUNSHIP","ASF","CASDIVE"];
["tactical_conventional_requests_refused",_refused && {count A3I_test_originals == 5}
    && {isNil "A3I_tacticalSupports" || {count A3I_tacticalSupports == 0}}] call _check;
A3A_supportCallInProgress = true;
["CAS",west,[],30,objNull,_position,0.9] call A3A_fnc_createSupport;
["tactical_refusal_preserves_foreign_lock",!isNil "A3A_supportCallInProgress"] call _check;
A3A_supportCallInProgress = nil;
["tactical_legacy_signature_refused",[west,_position,"QRFLAND",0,0] call A3A_fnc_createSupport == ""] call _check;
private _atomic = []; isNil {_atomic = ["atomic","defence",20,objNull,_position,0] call A3I_fnc_startTacticalSupport};
["tactical_scheduled_required",_atomic # 2 == "scheduled_required"] call _check;
["tactical_invalid_requests",!((["bad","other",20,objNull,_position,0] call A3I_fnc_startTacticalSupport) # 0)
    && {!((["bad","defence",9,objNull,_position,0] call A3I_fnc_startTacticalSupport) # 0)}
    && {!((["bad","defence",20,objNull,_position,2] call A3I_fnc_startTacticalSupport) # 0)}
    && {!((["bad","defence",20,objNull,[1,"invalid"],0] call A3I_fnc_startTacticalSupport) # 0)}
    && {!((["bad","defence",20,objNull,_position,0,-2] call A3I_fnc_startTacticalSupport) # 0)}] call _check;
areOccupantsDefeated = true;
["tactical_defeated_rejected",(["bad","defence",20,objNull,_position,0] call A3I_fnc_startTacticalSupport) # 2 == "inactive"] call _check;
areOccupantsDefeated = false;
server setVariable ["spawn_" + _source,"a3i_missing_vehicle_spawn"];
private _sources = [_position] call A3I_fnc_tacticalSources;
["tactical_actual_foot_navigation",count _sources == 1 && {(_sources # 0) select [0,2] isEqualTo [_source,1000]}] call _check;
server setVariable ["spawn_" + _source,nil];
NavGrid # 1 set [1,2];
["tactical_disconnected_rejected",([_position] call A3I_fnc_tacticalSources) isEqualTo []] call _check;
NavGrid # 1 set [1,1]; distanceForLandAttack = 500;
["tactical_distance_bounded",([_position] call A3I_fnc_tacticalSources) isEqualTo []] call _check;
distanceForLandAttack = 2000;
A3A_resourcesDefenceOcc = 9;
["tactical_no_funds_no_charge",(["none","defence",100,objNull,_position,0] call A3I_fnc_startTacticalSupport) # 2 == "resources"
    && {A3A_resourcesDefenceOcc == 9}] call _check;
A3A_resourcesDefenceOcc = 100;

// Native selection and budget calculation run unchanged; its paid actor worker
// is the new implementation. No original infected constructor is invoked.
private _enemyGroup = createGroup teamPlayer;
private _enemy = _enemyGroup createUnit ["I_Soldier_F",[5000,4520,0],[],0,"NONE"];
_enemy enableSimulationGlobal false; _enemy allowDamage false;
private _occupiedRoute = [getPosATL _enemy] call A3I_fnc_tacticalSources;
["tactical_occupied_target_finds_nearby_ground",count _occupiedRoute == 1
    && {(_occupiedRoute # 0 # 2) distance2D _enemy >= 3}
    && {(_occupiedRoute # 0 # 2) distance2D _enemy <= 50}
    && {([_occupiedRoute # 0 # 2,"Zombie_B_Walker_Civ",[],getMarkerPos respawnTeamPlayer,150,false]
        call A3I_fnc_positionSafety) # 0}] call _check;
[west,_enemy,_position,4,0.9] call A3A_fnc_requestSupport;
private _nativeName = "QRFLAND" + str A3A_supportCount;
private _job = A3I_tacticalSupports getOrDefault [_nativeName,createHashMap];
["tactical_native_selection_foot",count _job > 0 && {count A3I_test_originals == 5}
    && {isNil "A3A_supportCallInProgress"},[_nativeName,keys A3I_tacticalSupports]] call _check;
if (count _job == 0) exitWith {
    diag_log format ["[INFECTION_SUPPORT_TEST] source eligibility=%1 routes=%2",[_source] call A3I_fnc_counterattackSourceEligible,[_position] call A3I_fnc_tacticalSources];
};
[{count (_job get "units") > 0}] call _wait;
["tactical_native_spend_and_strike",count A3A_supportSpends == 1 && {count A3A_supportStrikes == 1}
    && {A3A_supportSpends # 0 # 3 == 90} && {A3A_supportStrikes # 0 # 1 == "TROOPS"}
    && {A3A_resourcesDefenceOcc == 100 - 10 * count (_job get "units")}] call _check;
[_job] call _finish; [{A3A_resourcesDefenceOcc == 100},3] call _wait;
deleteVehicle _enemy; deleteGroup _enemyGroup;
private _air = createVehicle ["B_Heli_Light_01_F",[5100,4500,0],[],0,"NONE"];
_air enableSimulationGlobal false;
_air setVariable ["A3A_airKills",1000];
private _priorCount = A3A_supportCount;
[west,_air,_position,4,0.9] call A3A_fnc_requestSupport;
["tactical_air_target_not_selected",A3A_supportCount == _priorCount && {count A3I_tacticalSupports == 0}
    && {[west,_air,_position] call A3A_fnc_maxDefenceSpend > 0}
    && {(["air","defence",30,_air,_position,0] call A3I_fnc_startTacticalSupport) # 2 == "air_target"}] call _check;
deleteVehicle _air;
[west,_position,"attack",4,0.9,0] call A3A_fnc_requestArtillery;
["tactical_native_artillery_no_force",count A3I_tacticalSupports == 0 && {A3A_supportCount == _priorCount}
    && {A3A_resourcesAttackOcc == 100} && {isNil "A3A_supportCallInProgress"}] call _check;

call _reset; A3A_supportCallInProgress = true; A3I_test_tacticalName = nil;
private _requestThread = ["QRFLAND",west,_position,20,objNull,_position,0.9,2] spawn {
    A3I_test_tacticalName = _this call A3A_fnc_createSupport;
};
sleep 0.5;
private _held = !scriptDone _requestThread && {isNil "A3I_test_tacticalName"} && {count A3I_tacticalSupports == 0};
A3A_supportCallInProgress = nil;
[{scriptDone _requestThread},3] call _wait;
["tactical_request_waits_for_lock",_held && {A3I_test_tacticalName != ""}
    && {isNil "A3A_supportCallInProgress"}] call _check;
_job = A3I_tacticalSupports get A3I_test_tacticalName;
[_job] call _finish;

call _reset;
private _name = ["QRFLAND",west,_position,30,objNull,_position,0.9,2] call A3A_fnc_createSupport;
_job = A3I_tacticalSupports get _name;
["tactical_delayed_request_no_prepayment",_name != "" && {_job get "created" == 0}
    && {A3A_resourcesDefenceOcc == 100} && {_job get "readyAt" > time}] call _check;
["tactical_source_claim_blocks_second",!((["duplicate","defence",20,objNull,_position,0] call A3I_fnc_startTacticalSupport) # 0)
    && {!([_source] call A3I_fnc_counterattackSourceEligible)} && {[_source,false] call A3I_fnc_counterattackSourceEligible}] call _check;
[2,4] call _setLimits;
[{count (_job get "units") == 2},7] call _wait;
private _units = +(_job get "units");
["tactical_budgeted_paid_basics",count _units == 2 && {count (_job get "queue") == 1}
    && {A3A_resourcesDefenceOcc == 80} && {(call _stats) # 1 == 2}
    && {(_units findIf {!local _x || {owner _x != 2} || {side group _x != west}
        || {!([_x] call A3I_fnc_isManagedUnit)} || {vehicle _x != _x}
        || {!(_x getVariable ["spawner",false])} || {_x getVariable ["A3A_resPool",""] != "defence"}}) == -1}] call _check;
private _leader = leader ((_job get "groups") # 0);
private _origin = getPosATL _leader;
private _moved = [{_leader distance2D _origin > 0.5},6] call _wait;
["tactical_approach_moves",_moved,[_leader distance2D _origin]] call _check;
["tactical_no_remote_capture",A3I_test_zones isEqualTo [] && {_job get "announced"}] call _check;
[4,4] call _setLimits;
private _full = [{count (_job get "units") == 3},18] call _wait;
["tactical_later_birth_paid_once",_full && {A3A_resourcesDefenceOcc == 70} && {_job get "queue" isEqualTo []}] call _check;
_units = +(_job get "units");
{_x enableSimulationGlobal false; _x setPosATL [5020 + 5*_forEachIndex,4500,0]} forEach _units;
garrison setVariable [_target,["pending_role"]]; spawner setVariable [_target,0]; sleep 1.5;
["tactical_pending_defenders_block_capture",A3I_test_zones isEqualTo []] call _check;
garrison setVariable [_target,[]];
private _capture = [{count A3I_test_zones > 0},12] call _wait;
["tactical_arrival_requests_native_capture",_capture && {A3I_test_zones # 0 isEqualTo [_target,teamPlayer]}] call _check;
[{_job get "searchDeadline" > time},3] call _wait;
["tactical_arrival_starts_search",_job get "searchDeadline" > time] call _check;
_enemyGroup = createGroup teamPlayer;
_enemy = _enemyGroup createUnit ["I_Soldier_F",[5050,4500,0],[],0,"NONE"];
_enemy enableSimulationGlobal false; _enemy allowDamage false;
private _friendship = west getFriend teamPlayer;
west setFriend [teamPlayer,0];
{_x enableSimulationGlobal true} forEach _units;
{leader _x reveal [_enemy,4]} forEach (_job get "groups");
private _known = [{((_job get "groups") findIf {leader _x findNearestEnemy _position == _enemy}) != -1},3] call _wait;
_job set ["searchDeadline",time - 1];
sleep 1.5;
["tactical_known_enemy_keeps_search",_known && {(_job get "name") in A3I_tacticalSupports}
    && {_job get "outcome" == "pending"},[_known,_job get "outcome"]] call _check;
deleteVehicle _enemy; deleteGroup _enemyGroup;
west setFriend [teamPlayer,_friendship];
private _finished = [_job] call _waitJob;
private _refund = [{A3A_resourcesDefenceOcc == 100},3] call _wait;
["tactical_search_ends_and_refunds",_finished && {_refund} && {_job get "outcome" == "searched"}] call _check;
spawner setVariable [_target,2];

// Direct mission constructors use the attack pool, without native prepayment.
call _reset;
private _cost = ["directAir",west,"attack",20,objNull,_position,0.9,2] call A3A_fnc_SUP_QRFAir;
_job = A3I_tacticalSupports get "directAir";
["tactical_direct_air_foot_estimate",_cost == 20 && {_job get "created" == 0}
    && {A3A_resourcesAttackOcc == 100}] call _check;
[{count (_job get "units") == 2},7] call _wait;
["tactical_direct_attack_pool_once",A3A_resourcesAttackOcc == 80 && {A3A_resourcesDefenceOcc == 100}
    && {((_job get "units") findIf {_x getVariable ["A3A_resPool",""] != "attack"}) == -1}] call _check;
_units = +(_job get "units"); (_units # 0) setDamage 1;
[_job] call _finish; _refund = [{A3A_resourcesAttackOcc == 90},3] call _wait;
["tactical_attack_refunds_living_only",_refund] call _check;
{deleteVehicle _x} forEach _units;
call _reset; A3A_resourcesAttackOcc = 100;
_cost = ["directLand",west,"attack",20,objNull,_position,0.9,0] call A3A_fnc_SUP_QRFLand;
_job = A3I_tacticalSupports get "directLand";
[{count (_job get "units") == 2}] call _wait;
["tactical_direct_land_foot_once",_cost == 20 && {A3A_resourcesAttackOcc == 80}
    && {count A3I_test_originals == 5}] call _check;
_units = +(_job get "units"); private _group = (_job get "groups") # 0;
sidesX setVariable [_target,west];
{_x enableSimulationGlobal false; _x setPosATL [5020 + 5*_forEachIndex,4500,0]} forEach _units;
(_units # 1) setVariable ["A3A_resPool","defence"];
["tactical_mixed_paid_pool_refused",([_group,_target,true] call A3I_fnc_adoptReinforcement) # 2 == "invalid_arrivals"] call _check;
(_units # 1) setVariable ["A3A_resPool","attack"];
_job set ["endTime",time - 1]; _finished = [_job] call _waitJob; sleep 0.5;
["tactical_attack_virtual_adoption",_finished && {count (garrison getVariable _target) == 2}
    && {A3A_resourcesAttackOcc == 80} && {(_units findIf {!isNull _x}) == -1}] call _check;
["tactical_adoption_not_repeated",!(([_group,_target,true] call A3I_fnc_adoptReinforcement) # 0)
    && {count (garrison getVariable _target) == 2}] call _check;
garrison setVariable [_target,[]]; sidesX setVariable [_target,teamPlayer];
_job = ["activeAttack","attack"] call _pair; _units = +(_job get "units");
{_x enableSimulationGlobal false; _x setPosATL [5020 + 5*_forEachIndex,4500,0]} forEach _units;
sidesX setVariable [_target,west]; spawner setVariable [_target,0];
_job set ["endTime",time - 1]; _finished = [_job] call _waitJob;
["tactical_attack_live_adoption",_finished && {count (garrison getVariable _target) == 2}
    && {A3A_resourcesAttackOcc == 80} && {(call _stats) # 1 == 2}
    && {(_units findIf {_x getVariable ["A3A_resPool",""] != "garrison"}) == -1}] call _check;
(_units # 0) setDamage 1; sleep 0.5;
["tactical_adopted_death_updates_roster",count (garrison getVariable _target) == 1 && {A3A_resourcesAttackOcc == 80}] call _check;
spawner setVariable [_target,2]; [{!(_target in A3I_sites)},6] call _wait;
{deleteVehicle _x} forEach _units; sleep 0.5;
["tactical_adopted_cleanup_no_refund",A3A_resourcesAttackOcc == 80 && {(call _stats) # 1 == 0}] call _check;
garrison setVariable [_target,[]]; sidesX setVariable [_target,teamPlayer];

// Rebuilding constructors may originate on clients. Exercise the local server
// policy and rejection boundary here; a real connected-player relay is separate.
private _rebuildFlag = "A3U_rebuilding_" + _target;
private _rebuildName = "REBUILD_QRF_" + _target + "_1";
["tactical_rebuild_requires_active_mission",([_target,_position] call A3I_fnc_rebuildSupport) # 2 == "inactive_rebuild"
    && {[_rebuildName,west,"attack",9999,false,_position,1,-1] call A3A_fnc_SUP_QRFLand == -1}] call _check;
missionNamespace setVariable [_rebuildFlag,true]; sidesX setVariable [_target,east];
["tactical_rebuild_rechecks_owner",([_target,_position] call A3I_fnc_rebuildSupport) # 2 == "inactive_rebuild"] call _check;
sidesX setVariable [_target,teamPlayer];
["tactical_rebuild_position_bounded",([_target,[5100,4500,0]] call A3I_fnc_rebuildSupport) # 2 == "inactive_rebuild"] call _check;
[_target,_position] remoteExec ["A3I_fnc_rebuildSupport",2]; sleep 0.5;
["tactical_rebuild_internal_remote_denied",count A3I_tacticalSupports == 0] call _check;
_enemyGroup = createGroup teamPlayer;
_enemy = _enemyGroup createUnit ["I_Soldier_F",[5000,4520,0],[],0,"NONE"];
[_target,_position,_enemy] remoteExec ["A3I_fnc_receiveRebuildSupport",2]; sleep 0.5;
["tactical_rebuild_forged_player_denied",count A3I_tacticalSupports == 0] call _check;
deleteVehicle _enemy; deleteGroup _enemyGroup;
sidesX setVariable [_source,east];
["tactical_rebuild_nearest_side_rechecked",([_target,_position] call A3I_fnc_rebuildSupport) # 2 == "source_changed"] call _check;
sidesX setVariable [_source,west]; call _reset;
A3A_resourcesAttackOcc = 100; A3A_balanceVehicleCost = 10;
_cost = [_rebuildName,west,"attack",9999,false,_position,1,-1] call A3A_fnc_SUP_QRFLand;
private _rebuildJobName = A3I_rebuildClaims get _target;
_job = A3I_tacticalSupports get _rebuildJobName;
[{count (_job get "units") == 2}] call _wait;
["tactical_rebuild_server_sizes_and_pays",_cost == 20 && {_job get "planned" == 2}
    && {_job get "pool" == "attack"} && {A3A_resourcesAttackOcc == 80}] call _check;
_cost = [_rebuildName + "extra",west,"attack",9999,false,_position,1,-1] call A3A_fnc_SUP_QRFAir;
["tactical_rebuild_single_attempt",_cost == -1 && {count A3I_tacticalSupports == 1}
    && {count A3I_rebuildClaims == 1} && {A3A_resourcesAttackOcc == 80}] call _check;
missionNamespace setVariable [_rebuildFlag,false];
private _released = [{count A3I_rebuildClaims == 0},4] call _wait;
["tactical_rebuild_claim_release_keeps_qrf",_released && {isNil "A3I_rebuildWatchdogHandle"}
    && {_job get "outcome" == "pending"}] call _check;
[_job] call _finish; [{A3A_resourcesAttackOcc == 100},3] call _wait;
call _reset; missionNamespace setVariable [_rebuildFlag,true];
_cost = [_rebuildName,west,"attack",9999,false,_position,1,-1] call A3A_fnc_SUP_QRFAir;
_job = A3I_tacticalSupports get (A3I_rebuildClaims get _target);
[{count (_job get "units") == 2}] call _wait;
["tactical_rebuild_new_cycle",_cost == 20 && {_job get "name" != _rebuildJobName}
    && {A3A_resourcesAttackOcc == 80}] call _check;
missionNamespace setVariable [_rebuildFlag,false];
[_job] call _finish; [{A3A_resourcesAttackOcc == 100 && {count A3I_rebuildClaims == 0}},4] call _wait;
missionNamespace setVariable [_rebuildFlag,nil]; A3A_balanceVehicleCost = 30;

_job = ["sourceLost"] call _pair; sidesX setVariable [_source,east]; _finished = [_job] call _waitJob;
_refund = [{A3A_resourcesDefenceOcc == 100},3] call _wait;
["tactical_source_loss_cancels",_finished && {_refund} && {_job get "outcome" == "cancelled"}] call _check;
sidesX setVariable [_source,west]; _job = ["factionLost"] call _pair;
areOccupantsDefeated = true; _finished = [_job] call _waitJob;
_refund = [{A3A_resourcesDefenceOcc == 100},3] call _wait;
["tactical_faction_loss_cancels",_finished && {_refund} && {_job get "outcome" == "cancelled"}] call _check;
areOccupantsDefeated = false;
_job = ["dependencyLost"] call _pair;
A3I_dependencies set ["available",false]; _finished = [_job] call _waitJob;
_refund = [{A3A_resourcesDefenceOcc == 100},3] call _wait;
["tactical_dependency_loss_cancels",_finished && {_refund} && {_job get "outcome" == "cancelled"}] call _check;
A3I_dependencies set ["available",true];
_job = ["interrupted"] call _pair; terminate (_job get "script"); _finished = [_job] call _waitJob;
_refund = [{A3A_resourcesDefenceOcc == 100},3] call _wait;
["tactical_stopped_controller_recovers",_finished && {_refund} && {_job get "outcome" == "interrupted"}] call _check;
call _reset; A3A_resourcesDefenceOcc = 100;
["quarter","defence",40,objNull,_position,0.9,0] call A3I_fnc_startTacticalSupport;
_job = A3I_tacticalSupports get "quarter"; [{count (_job get "units") == 4}] call _wait;
_units = +(_job get "units"); {_x setDamage 1} forEach (_units select [0,3]);
_finished = [_job] call _waitJob; _refund = [{A3A_resourcesDefenceOcc == 70},3] call _wait;
["tactical_exact_quarter_retreat",_finished && {_refund} && {_job get "outcome" == "defeated"}] call _check;
{deleteVehicle _x} forEach _units;

// Queue and cost bounds remain meaningful even with no active-unit capacity.
[1,4] call _setLimits; private _pressure = ["reserve",["tactical_pressure",1,1]] call A3I_fnc_budget;
call _reset; A3A_resourcesDefenceOcc = 100000; A3A_balanceVehicleCost = 100000;
["bounded","defence",1000000,objNull,_position,0,0] call A3I_fnc_startTacticalSupport;
_job = A3I_tacticalSupports get "bounded";
["tactical_hard_limit_64",_job get "planned" == 64] call _check;
sleep 0.5; _job set ["spawnDeadline",time - 1]; _finished = [_job] call _waitJob;
["tactical_no_force_no_charge",_finished && {_job get "outcome" == "no_force"}
    && {!(_job get "announced")} && {A3A_resourcesDefenceOcc == 100000}] call _check;
call _reset; A3A_resourcesDefenceOcc = 25;
["affordable","defence",1000000,objNull,_position,0,0] call A3I_fnc_startTacticalSupport;
_job = A3I_tacticalSupports get "affordable";
["tactical_budget_rounds_down",_job get "planned" == 2] call _check;
[_job] call _finish;
["close",[_pressure # 1 # 0]] call A3I_fnc_budget;
call _reset; A3A_resourcesDefenceOcc = 100; A3A_balanceVehicleCost = 10;
[2,4] call _setLimits;
["lateFunds","defence",100,objNull,_position,0,0] call A3I_fnc_startTacticalSupport;
_job = A3I_tacticalSupports get "lateFunds";
[{count (_job get "units") == 2}] call _wait;
["tactical_three_allowance_ceiling",_job get "planned" == 3] call _check;
A3A_resourcesDefenceOcc = 5; [4,4] call _setLimits; sleep 16;
["tactical_late_shortage_unpaid",count (_job get "units") == 2 && {count (_job get "queue") == 1}
    && {A3A_resourcesDefenceOcc == 5}] call _check;
[_job] call _finish; _refund = [{A3A_resourcesDefenceOcc == 25},3] call _wait;
["tactical_late_shortage_actual_refund",_refund] call _check;
call _reset; A3A_resourcesDefenceOcc = 100;
[2,4] call _setLimits;
["combatPause","defence",30,objNull,_position,0,0] call A3I_fnc_startTacticalSupport;
_job = A3I_tacticalSupports get "combatPause";
[{count (_job get "units") == 2}] call _wait;
A3A_recentDamageOcc = [[4000,4500,60]]; [4,4] call _setLimits; sleep 16;
["tactical_combat_pauses_births",count (_job get "units") == 2 && {count (_job get "queue") == 1}
    && {A3A_resourcesDefenceOcc == 80}] call _check;
A3A_recentDamageOcc = [];
private _resumed = [{count (_job get "units") == 3},7] call _wait;
["tactical_combat_clear_resumes",_resumed && {A3A_resourcesDefenceOcc == 70}] call _check;
[_job] call _finish; [{A3A_resourcesDefenceOcc == 100},3] call _wait;
private _foreign = [{A3I_test_tacticalTicks = A3I_test_tacticalTicks + 1},0.1] call CBA_fnc_addPerFrameHandler;
A3I_test_tacticalTicks = 0;
[[],_foreign] remoteExecCall ["A3I_fnc_tacticalWatchdog",2]; sleep 0.6;
["tactical_recovery_remote_denied",A3I_test_tacticalTicks >= 2] call _check;
[_foreign] call CBA_fnc_removePerFrameHandler;
{deleteVehicle _x} forEach [sidesX,spawner,garrison,server];
{deleteMarker _x} forEach [_source,_target,respawnTeamPlayer];
sidesX = nil; spawner = nil; garrison = nil; server = nil; respawnTeamPlayer = nil;
sleep 3;
{if (count units _x == 0) then {deleteGroup _x}} forEach (allGroups - _groupsBefore);
[_savedCap,_savedContext] call _setLimits;
GVAR(despawnQueue) = [];
private _remaining = (entities [[],[],true,false]) - _before;
["tactical_all_clean",_remaining isEqualTo [] && {(allGroups - _groupsBefore) isEqualTo []}
    && {(call _stats) select [1,3] isEqualTo [0,0,0]} && {count A3I_tacticalSupports == 0}
    && {isNil "A3I_tacticalWatchdogHandle"} && {count A3I_sites == 0}
    && {count A3I_rebuildClaims == 0} && {isNil "A3I_rebuildWatchdogHandle"}
    && {isNil "A3I_siteWatchdogHandle"},[_remaining apply {typeOf _x},call _stats]] call _check;
