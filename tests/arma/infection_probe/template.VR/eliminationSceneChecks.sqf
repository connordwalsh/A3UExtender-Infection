// Native mixed-unit creation with the actual shared budget, geometry and handlers.
#include "\x\a3a\addons\core\script_component.hpp"
private _before = entities [[],[],true,false]; private _groupsBefore = +allGroups;
sidesX = [true] call A3A_fnc_createNamespace; spawner = [true] call A3A_fnc_createNamespace;
respawnTeamPlayer = "a3i_escene_hq"; private _site = "a3i_escene_site";
createMarker [respawnTeamPlayer,[3000,4000,0]]; createMarker [_site,[4500,4500,0]];
_site setMarkerShape "ELLIPSE"; _site setMarkerSize [100,100];
sidesX setVariable [_site,west]; spawner setVariable [_site,2];
markersX = [_site,respawnTeamPlayer]; citiesX = [_site];
airportsX = []; milbases = []; outposts = []; factories = []; resourcesX = []; seaports = []; milAdministrationsX = []; controlsX = [];
private _group = createGroup teamPlayer;
petros = _group createUnit ["I_G_Soldier_F",[3000,4000,0],[],0,"NONE"];
petros enableSimulationGlobal false; petros setCaptive true;
distanceMission = 3000; distanceSPWN = 300; tierWar = 0; plusGarrison = false;
A3A_GCThreshold = 600; GVAR(despawnQueue) = []; GVAR(despawnerRunning) = nil;
A3A_resourcesAttackOcc = 1000; A3A_resourcesDefenceOcc = 1000;
A3A_recentDamageOcc = []; A3A_hasACE = false;
A3I_test_support = []; A3I_test_aggression = []; A3I_test_observers = [];
private _savedCap = A3I_activeLimit; private _savedContext = A3I_contextLimit;
private _limits = {
    params ["_cap","_local"];
    ["A3I_activeLimit",_cap,2,"server",false] call CBA_settings_fnc_set;
    ["A3I_contextLimit",_local,2,"server",false] call CBA_settings_fnc_set;
};
private _stats = {(["stats"] call A3I_fnc_budget) # 1};
private _clean = {
    params ["_scene"];
    ["cancel",[_scene # 3]] call A3I_fnc_budget;
    sleep 1;
    [[_scene # 2]] call A3I_fnc_cleanupGroups;
};
["escene_town_available",call A3I_fnc_eliminationTargets isEqualTo [_site]] call _check;
citiesX = []; factories = [_site];
["escene_permanent_available",call A3I_fnc_eliminationTargets isEqualTo [_site]] call _check;
sidesX setVariable [_site,east];
["escene_enemy_owner_excluded",call A3I_fnc_eliminationTargets isEqualTo []] call _check;
sidesX setVariable [_site,west]; spawner setVariable [_site,0];
["escene_native_active_site_excluded",call A3I_fnc_eliminationTargets isEqualTo []] call _check;
spawner setVariable [_site,2]; factories = []; controlsX = [_site];
["escene_controls_excluded",call A3I_fnc_eliminationTargets isEqualTo []] call _check;
controlsX = []; citiesX = [_site];
private _roster = [] call A3I_fnc_eliminationRoster;
["escene_low_war_mixed_roster",count (_roster # 1) == 4 && {count (_roster # 2) == 1}
    && {(_roster # 2 # 0) in (call A3I_fnc_eliminationClasses)}] call _check;
tierWar = 10; _roster = [] call A3I_fnc_eliminationRoster;
["escene_high_war_mixed_roster",count (_roster # 1) == 8 && {count (_roster # 2) == 2}] call _check;
tierWar = 0;
["escene_large_class_rejected",["WBK_Goliaph_1"] call A3I_fnc_eliminationRoster isEqualTo []] call _check;
[40,12] call _limits;
{
    private _result = [_site,_x] call A3I_fnc_spawnEliminationScene; private _scene = _result # 1;
    private _units = [_scene # 0]+(_scene # 1);
    sleep 3;
    ["escene_created_"+_x,_result # 0 && {count _units == 6}
        && {typeOf (_scene # 0) == _x}
        && {(_units findIf {!alive _x || {!local _x} || {side group _x != west}
            || {!(_x getVariable ["A3I_initialized",false])} || {isNil {_x getVariable "WBK_AI_ISZombie"}}
            || {_x getVariable ["markerX",""] != ""}}) == -1},_result # 2] call _check;
    ["escene_budget_"+_x,(call _stats) select [1,2] isEqualTo [6,0]] call _check;
    private _ledger = ["scene",_scene # 0,time+3600] call A3I_fnc_createEliminationLedger;
    ["escene_target_ledger_"+_x,count _ledger > 0] call _check;
    if (count _ledger > 0) then {[_ledger get "name",_ledger get "serial"] call A3I_fnc_releaseEliminationLedger};
    [_scene] call _clean;
} forEach (call A3I_fnc_eliminationClasses);
tierWar = 10;
private _high = [_site] call A3I_fnc_spawnEliminationScene;
sleep 3;
["escene_high_war_actual_roster",_high # 0 && {count (_high # 1 # 1) == 10}
    && {(call _stats) select [1,2] isEqualTo [11,0]}] call _check;
[_high # 1] call _clean; tierWar = 0;
[5,12] call _limits;
private _result = [_site] call A3I_fnc_spawnEliminationScene;
["escene_full_roster_or_none",!(_result # 0) && {_result # 2 == "capacity"}
    && {(call _stats) select [1,2] isEqualTo [0,0]}] call _check;
[40,12] call _limits;
A3I_test_observers = [petros]; petros setPosATL [4500,4500,0];
_result = [_site] call A3I_fnc_spawnEliminationScene;
["escene_visible_refused",!(_result # 0) && {(call _stats) select [1,2] isEqualTo [0,0]}] call _check;
A3I_test_observers = []; petros setPosATL [3000,4000,0];
private _rawGroup = createGroup west;
private _raw = _rawGroup createUnit ["Zombie_Special_BLUFOR_Screamer",[5500,4500,0],[],0,"NONE"];
sleep 2;
["escene_unowned_special_not_managed",!([_raw] call A3I_fnc_isManagedUnit)] call _check;
deleteVehicle _raw; sleep 0.3; deleteGroup _rawGroup;
["escene_alive_cleanup_no_army_cost",A3A_resourcesAttackOcc == 1000 && {A3A_resourcesDefenceOcc == 1000}] call _check;
[_savedCap,_savedContext] call _limits;
{deleteVehicle _x} forEach [petros,sidesX,spawner]; deleteMarker _site; deleteMarker respawnTeamPlayer;
sleep 0.3; deleteGroup _group; sleep 0.7;
["escene_cleanup",(entities [[],[],true,false]) - _before isEqualTo []
    && {allGroups - _groupsBefore isEqualTo []} && {(call _stats) select [1,2] isEqualTo [0,0]}] call _check;
