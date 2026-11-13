// Real geometry and bounded unit creation. No player or UI acceptance claim.
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
private _stats = {(["stats"] call A3I_fnc_budget) # 1};
private _site = "a3i_spawn_contract";
createMarker [_site,[4500,4500,0]];
respawnTeamPlayer = "a3i_spawn_hq";
createMarker [respawnTeamPlayer,[500,500,0]];
sidesX = [true] call A3A_fnc_createNamespace;
spawner = [true] call A3A_fnc_createNamespace;
garrison = [true] call A3A_fnc_createNamespace;
sidesX setVariable [_site,west];
spawner setVariable [_site,0];
private _roles = ["loadouts_occ_militia_Rifleman","loadouts_occ_military_Rifleman","loadouts_occ_elite_Rifleman"];
garrison setVariable [_site,+_roles];
private _class = "Zombie_B_Walker_Civ";
private _hq = getMarkerPos respawnTeamPlayer;
private _invalid = [[-1,1000,0],[worldSize+1,1000,0],["bad",0],[4500,4500,100]] apply {
    ([_x,_class,[],_hq] call A3I_fnc_positionSafety) # 0
};
["spawn_invalid_positions", _invalid isEqualTo [false,false,false,false],_invalid] call _check;
private _result = [[510,510,0],_class,[],_hq] call A3I_fnc_positionSafety;
["spawn_hq_exclusion",_result isEqualTo [false,"hq"],_result] call _check;
private _observerGroup = createGroup [independent,false];
private _observer = _observerGroup createUnit ["I_Soldier_F",[3000,3000,0],[],0,"NONE"];
_observer disableAI "ALL";
_observer setCaptive true;
_observer allowDamage false;
_result = [[3050,3000,0],_class,[_observer],_hq] call A3I_fnc_positionSafety;
["spawn_observer_distance",_result isEqualTo [false,"player_distance"],_result] call _check;
_result = [[3200,3000,0],_class,[_observer],_hq] call A3I_fnc_positionSafety;
["spawn_visible_rejected",_result isEqualTo [false,"visible"],_result] call _check;
// Config existence is checked before creating the actual line-of-sight blocker.
private _blockerClass = "Land_Cargo_House_V1_F";
private _blocker = objNull;
if (isClass (configFile >> "CfgVehicles" >> _blockerClass)) then {
    _blocker = createVehicle [_blockerClass,[3100,3000,0],[],0,"CAN_COLLIDE"];
};
sleep 0.3;
_result = [[3200,3000,0],_class,[_observer],_hq] call A3I_fnc_positionSafety;
["spawn_obscured_position",!isNull _blocker && {_result isEqualTo [true,""]},_result] call _check;
_result = [[3000,3000,0],_class,[],_hq] call A3I_fnc_positionSafety;
["spawn_occupied_position",!(_result # 0) && {_result # 1 in ["occupied_entity","occupied_static"]},_result] call _check;
deleteVehicle _blocker;
deleteVehicle _observer;
deleteGroup _observerGroup;
private _search = [[4500,4500,0],20,60,_class] call A3I_fnc_findSpawnPosition;
private _found = _search # 0;
["spawn_bounded_search",_found isNotEqualTo [] && {_found distance2D [4500,4500] >= 20}
    && {_found distance2D [4500,4500] <= 60},_search] call _check;
_search = [[500,500,0],0,20,_class] call A3I_fnc_findSpawnPosition;
["spawn_no_center_fallback",_search isEqualTo [[],"hq"],_search] call _check;
_search = [[4500,4500,0],100,20,_class] call A3I_fnc_findSpawnPosition;
["spawn_invalid_search",_search isEqualTo [[],"invalid_request"],_search] call _check;

[3,3] call _setLimits;
_result = ["spawn_contract",_roles + [_roles # 0],[4500,4500,0],10,60,_site] call A3I_fnc_spawnGroup;
private _units = _result # 1 # 1;
private _ticket = _result # 1 # 2;
sleep 2;
private _bad = _units select {
    !alive _x || {side group _x != west} || {!local _x} || {owner _x != 2}
    || {!(_x getVariable ["A3I_initialized",false])}
    || {isNil {_x getVariable "WBK_AI_AttachedHandlers"}}
    || {_x getVariable ["markerX",""] != _site}
    || {_x getVariable ["A3A_resPool",""] != "garrison"}
    || {primaryWeapon _x != ""} || {vehicle _x != _x}
};
["spawn_budgeted_basics",_result # 0 && {count _units == 3} && {_bad isEqualTo []}
    && {_result # 2 == "partial_capacity"} && {(call _stats) select [1,2] isEqualTo [3,0]},
    [_result # 0,count _units,_result # 2,_bad apply {typeOf _x},call _stats]] call _check;
_result = ["spawn_contract",_roles,[4500,4500,0],10,60,_site] call A3I_fnc_spawnGroup;
["spawn_full_budget_denied",!(_result # 0) && {_result # 2 == "capacity"},[_result # 0,_result # 2]] call _check;
_result = ["spawn_invalid",["Zombie_B_Walker_Civ"],[4500,4500,0],10,60,_site] call A3I_fnc_spawnGroup;
["spawn_raw_class_denied",!(_result # 0) && {_result # 2 == "unregistered_role"},[_result # 0,_result # 2]] call _check;
["cancel",[_ticket]] call A3I_fnc_budget;
sleep 0.3;
deleteMarker respawnTeamPlayer;
_result = ["spawn_missing_hq",_roles,[4500,4500,0],10,60,_site] call A3I_fnc_spawnGroup;
["spawn_missing_hq_releases",!(_result # 0) && {_result # 2 == "hq_unavailable"}
    && {(call _stats) select [1,3] isEqualTo [0,0,0]},[_result # 0,_result # 2,call _stats]] call _check;
createMarker [respawnTeamPlayer,[500,500,0]];
spawner setVariable [_site,2];
_result = ["spawn_inactive",_roles,[4500,4500,0],10,60,_site] call A3I_fnc_spawnGroup;
["spawn_inactive_site_denied",!(_result # 0) && {_result # 2 == "inactive_site"},[_result # 0,_result # 2]] call _check;
spawner setVariable [_site,0];

[6,6] call _setLimits;
private _race = [_site] spawn {
    params ["_site"];
    private _until = diag_tickTime + 5;
    waitUntil {sleep 0.01; (allUnits findIf {_x getVariable ["markerX",""] == _site}) != -1 || {diag_tickTime > _until}};
    sidesX setVariable [_site,east];
};
_result = ["spawn_race",_roles + _roles,[4500,4500,0],10,60,_site] call A3I_fnc_spawnGroup;
_units = _result # 1 # 1;
["spawn_ownership_race",_result # 0 && {count _units > 0} && {count _units < 6}
    && {_result # 2 == "inactive_site"} && {(call _stats) # 2 == 0},
    [_result # 0,count _units,_result # 2,call _stats]] call _check;
waitUntil {sleep 0.05;scriptDone _race};
["cancel",[_result # 1 # 2]] call A3I_fnc_budget;
sleep 0.3;
sidesX setVariable [_site,west];
[6,6] call _setLimits;
_race = [_site] spawn {
    params ["_site"];
    private _until = diag_tickTime + 5;
    waitUntil {sleep 0.01; (allUnits findIf {_x getVariable ["markerX",""] == _site}) != -1 || {diag_tickTime > _until}};
    isNil {
        A3I_test_reductionCount = count (allUnits select {_x getVariable ["markerX",""] == _site});
        ["A3I_activeLimit",1,2,"server",false] call CBA_settings_fnc_set;
    };
};
_result = ["spawn_reduced",_roles + _roles,[4500,4500,0],10,60,_site] call A3I_fnc_spawnGroup;
_units = _result # 1 # 1;
["spawn_limit_change_rolls_back",_result # 0 && {A3I_test_reductionCount > 0} && {A3I_test_reductionCount < 6}
    && {count _units == A3I_test_reductionCount}
    && {(call _stats) select [1,2] isEqualTo [A3I_test_reductionCount,0]}
    && {count (allUnits select {_x getVariable ["markerX",""] == _site}) == A3I_test_reductionCount},
    [_result # 0,count _units,A3I_test_reductionCount,_result # 2,call _stats]] call _check;
waitUntil {sleep 0.05;scriptDone _race};
["cancel",[_result # 1 # 2]] call A3I_fnc_budget;
sleep 3;
{deleteGroup _x} forEach (allGroups - _groupsBefore);
deleteVehicle sidesX;
deleteVehicle garrison;
deleteVehicle spawner;
sidesX = nil; garrison = nil; spawner = nil;
deleteMarker _site;
deleteMarker respawnTeamPlayer;
respawnTeamPlayer = nil;
[_savedCap,_savedContext] call _setLimits;
GVAR(despawnQueue) = [];
private _left = (entities [[],[],true,false]) - _before;
["spawn_cleanup",_left isEqualTo [] && {(allGroups - _groupsBefore) isEqualTo []}
    && {(call _stats) select [1,3] isEqualTo [0,0,0]},
    [_left apply {typeOf _x},count (allGroups - _groupsBefore),call _stats]] call _check;
