// Dedicated contracts: real actors/bookkeeping, synthetic VR road connectivity.
// Selection uses AI observation anchors; no connected-player behavior is claimed.
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
private _base = "a3i_roam_base";
private _dest = "a3i_roam_destination";
private _role = "loadouts_occ_militia_Rifleman";
sidesX = [true] call A3A_fnc_createNamespace;
spawner = [true] call A3A_fnc_createNamespace;
garrison = [true] call A3A_fnc_createNamespace;
server = [true] call A3A_fnc_createNamespace;
respawnTeamPlayer = "a3i_roam_hq";
createMarker [respawnTeamPlayer,[500,500,0]];
createMarker [_base,[4000,4500,0]];
createMarker [_dest,[5000,4500,0]];
{_x setMarkerShape "ELLIPSE"; _x setMarkerSize [50,50]; sidesX setVariable [_x,west]; spawner setVariable [_x,2]} forEach [_base,_dest];
outposts = [_base]; resourcesX = [_dest]; factories = []; seaports = []; milbases = []; airportsX = [];
markersX = [_base,_dest]; controlsX = []; citiesX = []; milAdministrationsX = [];
forcedSpawn = []; distanceSPWN = 1000; distanceSPWN1 = 1000; distanceForLandAttack = 2000;
NavGrid = [[[4000,4500,0],1,0,[[1,0,1000]]],[[5000,4500,0],1,0,[[0,0,1000]]]];
A3A_navCellHM = createHashMapFromArray [["4/4",[[4000,4500,0]]],["5/4",[[5000,4500,1]]]];
A3A_markerNavPoints = createHashMap;
A3A_recentDamageOcc = []; A3A_recentDamageInv = [];
A3A_resourcesDefenceOcc = 100; A3A_resourcesAttackOcc = 100;
A3A_hasACE = false; A3A_GCThreshold = 600;
GVAR(despawnQueue) = []; GVAR(despawnerRunning) = nil;
A3A_faction_reb = createHashMapFromArray [["diveGear",[]],["flyGear",[]]];
A3A_faction_inv = createHashMapFromArray [["vehiclesGunBoats",[]]];
A3I_test_originals = []; A3I_test_support = []; A3I_test_aggression = []; A3I_test_zones = [];
A3I_roamingCooldowns = createHashMap;
AAFpatrols = 1; A3A_balancePlayerScale = 1; tierWar = 1; aggressionOccupants = 0; plusGarrison = true;
private _roster = [_role,_role,_role,_role];
garrison setVariable [_base,+_roster]; garrison setVariable [_dest,[]];
private _waitJob = {[{!(_base in A3I_roamers)},6] call _wait};
private _reset = {A3I_roamingCooldowns deleteAt _base};
[4,4] call _setLimits;

["roam_override_registered",getText (configFile >> "CfgFunctions" >> "A3A" >> "CREATE" >> "AAFroadPatrol" >> "file")
    == "\x\a3i\addons\core\overrides\fn_AAFroadPatrol.sqf"] call _check;
A3A_faction_occ set ["infectionTemplate",""]; [] call A3A_fnc_AAFroadPatrol;
A3A_faction_occ set ["infectionTemplate","A3I_Infected"];
A3I_dependencies set ["available",false]; [] call A3A_fnc_AAFroadPatrol;
A3I_dependencies set ["available",true];
["roam_inactive_routes_delegate",count A3I_test_originals == 2] call _check;
[] call A3A_fnc_AAFroadPatrol;
["roam_no_players_no_dispatch",AAFpatrols == 1 && {isNil "A3I_roamers" || {count A3I_roamers == 0}}] call _check;
private _observerGroup = createGroup civilian;
private _observer = _observerGroup createUnit ["C_man_1",[5500,4500,0],[],0,"NONE"];
private _bases = [[_observer]] call A3I_fnc_roamingBases;
["roam_player_area_selection",_bases isEqualTo [_base] && {([[]] call A3I_fnc_roamingBases) isEqualTo []}] call _check;
server setVariable ["spawn_" + _base,"a3i_missing_vehicle_spawn"];
["roam_foot_route_ignores_vehicle_spawn",([[_observer]] call A3I_fnc_roamingBases) isEqualTo [_base]
    && {count ([_base] call A3I_fnc_roamingRoute) == 2}] call _check;
server setVariable ["spawn_" + _base,nil];
outposts = []; seaports = [_base];
["roam_infected_port_uses_land",([[_observer]] call A3I_fnc_roamingBases) isEqualTo [_base]] call _check;
sidesX setVariable [_base,east];
private _withoutBoats = [[_observer]] call A3I_fnc_roamingBases;
A3A_faction_inv set ["vehiclesGunBoats",["O_Boat_Armed_01_hmg_F"]];
["roam_invader_port_keeps_boat_rule",_withoutBoats isEqualTo [] && {([[_observer]] call A3I_fnc_roamingBases) isEqualTo [_base]}] call _check;
sidesX setVariable [_base,teamPlayer];
["roam_rebel_source_excluded",([[_observer]] call A3I_fnc_roamingBases) isEqualTo []] call _check;
sidesX setVariable [_base,west]; seaports = []; outposts = [_base];
deleteVehicle _observer; deleteGroup _observerGroup;
spawner setVariable [_base,0];
["roam_active_source_excluded",!([_base] call A3I_fnc_roamingEligible)] call _check;
spawner setVariable [_base,2]; forcedSpawn = [_base];
["roam_forced_source_excluded",!([_base] call A3I_fnc_roamingEligible)] call _check;
forcedSpawn = []; garrison setVariable [_base,[]];
["roam_empty_source_excluded",!([_base] call A3I_fnc_roamingEligible)] call _check;
garrison setVariable [_base,+_roster]; server setVariable [_base,dateToNumber date + 0.01];
["roam_idle_source_excluded",!([_base] call A3I_fnc_roamingEligible)] call _check;
server setVariable [_base,0]; A3A_recentDamageOcc = [[4000,4500,60]];
["roam_combat_source_excluded",!([_base] call A3I_fnc_roamingEligible)] call _check;
A3A_recentDamageOcc = [];
private _route = [_base] call A3I_fnc_roamingRoute;
["roam_connected_outdoor_route",count _route == 2 && {(_route apply {_x # 0}) isEqualTo [_dest,_base]}
    && {(_route findIf {!(([_x # 1,"Zombie_B_Walker_Civ",[],getMarkerPos respawnTeamPlayer] call A3I_fnc_positionSafety) # 0)}) == -1},_route] call _check;
private _atomicRoute = [1]; isNil {_atomicRoute = [_base] call A3I_fnc_roamingRoute};
["roam_unscheduled_search_rejected",_atomicRoute isEqualTo []] call _check;
NavGrid # 1 set [1,2];
["roam_disconnected_route_rejected",([_base] call A3I_fnc_roamingRoute) isEqualTo []] call _check;
NavGrid # 1 set [1,1]; sidesX setVariable [_dest,east];
["roam_enemy_destination_rejected",([_base] call A3I_fnc_roamingRoute) isEqualTo []] call _check;
sidesX setVariable [_dest,west]; controlsX = [_dest];
["roam_control_destination_excluded",([_base] call A3I_fnc_roamingRoute) isEqualTo []] call _check;
controlsX = []; distanceForLandAttack = 500;
["roam_route_distance_bounded",([_base] call A3I_fnc_roamingRoute) isEqualTo []] call _check;
distanceForLandAttack = 2000; respawnTeamPlayer setMarkerPos getMarkerPos _base;
["roam_unsafe_endpoint_rejected",([_base] call A3I_fnc_roamingRoute) isEqualTo []] call _check;
respawnTeamPlayer setMarkerPos [500,500,0]; AAFpatrols = 3;
["roam_native_patrol_limit",!([_base] call A3I_fnc_startRoaming) && {AAFpatrols == 3}] call _check;
AAFpatrols = 1; controlsX = [_dest];
["roam_no_route_no_counter",!([_base] call A3I_fnc_startRoaming) && {AAFpatrols == 1}
    && {!(_base in A3I_roamingCooldowns)}] call _check;
controlsX = []; [1,4] call _setLimits;
private _started = [_base] call A3I_fnc_startRoaming;
private _record = A3I_roamers get _base;
private _planned = count (_record get "queue");
[{count (_record get "units") == 1}] call _wait;
private _units = +(_record get "units");
["roam_budgeted_partial_spawn",_started && {_planned > 1} && {_planned <= 4}
    && {count _units == 1} && {count (_record get "queue") == _planned - 1}
    && {(call _stats) # 1 == 1} && {AAFpatrols == 2}
    && {(_units findIf {!local _x || {owner _x != 2} || {side group _x != west}
        || {!([_x] call A3I_fnc_isManagedUnit)} || {_x getVariable ["A3A_resPool",""] != "legacy"}
        || {_x getVariable ["markerX",""] != ""}}) == -1},[_planned,call _stats]] call _check;
["roam_duplicate_request_blocked",!([_base] call A3I_fnc_startRoaming) && {AAFpatrols == 2}] call _check;
private _group = (_record get "groups") # 0;
private _types = waypoints _group apply {waypointType _x};
["roam_cyclic_foot_waypoints",{_x == "MOVE"} count _types >= 2 && {"CYCLE" in _types}
    && {vehicle leader _group == leader _group}] call _check;
private _startPos = getPosATL leader _group;
private _moved = [{leader _group distance2D _startPos > 0.5},6] call _wait;
["roam_actual_movement",_moved,[leader _group distance2D _startPos]] call _check;
[4,4] call _setLimits;
private _arrived = [{count (_record get "units") == _planned},18] call _wait;
["roam_later_budgeted_batch",_arrived && {_record get "queue" isEqualTo []}
    && {(call _stats) # 1 == _planned} && {AAFpatrols == 2}] call _check;
_units = +(_record get "units");
(_units # 0) setDamage 1;
private _charged = [{A3A_resourcesDefenceOcc == 95 && {A3A_resourcesAttackOcc == 95}},3] call _wait;
["roam_legacy_death_cost_once",_charged && {garrison getVariable _base isEqualTo _roster}
    && {garrison getVariable _dest isEqualTo []}] call _check;
_record set ["lastObserved",time - 61];
private _cleaned = call _waitJob;
sleep 0.3;
["roam_distance_end_preserves_native_count",_cleaned && {AAFpatrols == 1}
    && {A3A_resourcesDefenceOcc == 95} && {A3A_resourcesAttackOcc == 95}
    && {(call _stats) select [1,3] isEqualTo [0,0,0]}] call _check;
{deleteVehicle _x} forEach _units;
["roam_cooldown_survives_cleanup",!([_base] call A3I_fnc_startRoaming) && {AAFpatrols == 1}] call _check;
call _reset; [_base] call A3I_fnc_startRoaming; _record = A3I_roamers get _base;
[{count (_record get "units") > 0}] call _wait;
sidesX setVariable [_base,east]; _cleaned = call _waitJob;
["roam_source_loss_cancels",_cleaned && {AAFpatrols == 1} && {(call _stats) # 1 == 0}] call _check;
sidesX setVariable [_base,west]; call _reset;
[_base] call A3I_fnc_startRoaming; _record = A3I_roamers get _base;
[{count (_record get "units") > 0}] call _wait;
sidesX setVariable [_dest,east]; _cleaned = call _waitJob;
["roam_route_loss_cancels",_cleaned && {AAFpatrols == 1} && {(call _stats) # 1 == 0}] call _check;
sidesX setVariable [_dest,west]; call _reset;
[_base] call A3I_fnc_startRoaming; _record = A3I_roamers get _base;
[{count (_record get "units") > 0}] call _wait;
_record set ["endTime",time - 1]; _cleaned = call _waitJob;
["roam_timeout_cleans",_cleaned && {AAFpatrols == 1} && {(call _stats) # 1 == 0}] call _check;
call _reset; [_base] call A3I_fnc_startRoaming; _record = A3I_roamers get _base;
[{(call _stats) # 1 > 0}] call _wait;
terminate (_record get "script"); _cleaned = call _waitJob;
["roam_stopped_controller_recovers",_cleaned && {AAFpatrols == 1}
    && {(call _stats) select [1,3] isEqualTo [0,0,0]}] call _check;
call _reset; [1,4] call _setLimits;
private _pressure = ["reserve",["roam_pressure",1,1]] call A3I_fnc_budget;
[_base] call A3I_fnc_startRoaming; _record = A3I_roamers get _base;
sleep 0.5;
private _none = _record get "units" isEqualTo [];
_record set ["spawnDeadline",time - 1]; _cleaned = call _waitJob;
["roam_empty_expiry_releases_count",_none && {_cleaned} && {AAFpatrols == 1}
    && {A3A_resourcesDefenceOcc == 95} && {A3A_resourcesAttackOcc == 95}] call _check;
["close",[_pressure # 1 # 0]] call A3I_fnc_budget;
A3I_test_roamTicks = 0;
private _foreign = [{A3I_test_roamTicks = A3I_test_roamTicks + 1},0.1] call CBA_fnc_addPerFrameHandler;
[[],_foreign] remoteExecCall ["A3I_fnc_roamingWatchdog",2]; sleep 0.6;
["roam_recovery_remote_denied",A3I_test_roamTicks >= 2] call _check;
[_foreign] call CBA_fnc_removePerFrameHandler;
{deleteVehicle _x} forEach [sidesX,spawner,garrison,server];
{deleteMarker _x} forEach [_base,_dest,respawnTeamPlayer];
sidesX = nil; spawner = nil; garrison = nil; server = nil; respawnTeamPlayer = nil;
sleep 3;
{if (count units _x == 0) then {deleteGroup _x}} forEach (allGroups - _groupsBefore);
[_savedCap,_savedContext] call _setLimits;
GVAR(despawnQueue) = [];
private _remaining = (entities [[],[],true,false]) - _before;
["roam_all_clean",_remaining isEqualTo [] && {(allGroups - _groupsBefore) isEqualTo []}
    && {(call _stats) select [1,3] isEqualTo [0,0,0]} && {count A3I_roamers == 0}
    && {isNil "A3I_roamingWatchdogHandle"} && {AAFpatrols == 1},[_remaining apply {typeOf _x},call _stats]] call _check;
