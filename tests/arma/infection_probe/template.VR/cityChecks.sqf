// Town selection, transient accounting and roaming use real engine actors.
// Support/ownership UI and original-faction paths remain recorded endpoints.
#include "\x\a3a\addons\core\script_component.hpp"
private _before = entities [[],[],true,false];
private _groupsBefore = +allGroups;
private _savedCap = A3I_activeLimit;
private _savedContext = A3I_contextLimit;
private _savedTierMode = plusGarrison;
plusGarrison = true; tierWar = 1;
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
sidesX = [true] call A3A_fnc_createNamespace;
spawner = [true] call A3A_fnc_createNamespace;
garrison = [true] call A3A_fnc_createNamespace;
garrisonIsChanging = false;
respawnTeamPlayer = "a3i_city_hq";
createMarker [respawnTeamPlayer,[500,500,0]];
private _marker = "a3i_city";
createMarker [_marker,[4500,4500,0]];
_marker setMarkerShape "ELLIPSE"; _marker setMarkerSize [300,300];
createMarker ["a3i_city_neighbor",[5100,4500,0]];
"a3i_city_neighbor" setMarkerShape "ELLIPSE"; "a3i_city_neighbor" setMarkerSize [50,50];
citiesX = [_marker];
controlsX = []; milAdministrationsX = [];
markersX = [_marker,"a3i_city_neighbor"];
airportsX = []; outposts = []; seaports = []; milbases = []; resourcesX = []; factories = [];
townSkirmishes = []; destroyedSites = [];
A3A_townData = createHashMapFromArray [[_marker,[100,2,60,40]]];
A3A_faction_civ = createHashMapFromArray [["attributeCivNonHuman",false]];
sidesX setVariable [_marker,west]; sidesX setVariable ["a3i_city_neighbor",west];
spawner setVariable [_marker,0];
garrison setVariable [_marker,["unrelated_saved_entry"]];
hcArray = [999];
A3I_test_originals = [];
A3I_test_siteEvents = [];
private _event = [CBA_EVENT_SERVER_SPAWN_LOCATION,{A3I_test_siteEvents pushBack +_this}] call CBA_fnc_addEventHandler;
private _stop = {
    spawner setVariable [_marker,2];
    [{!(_marker in A3I_sites)},5] call _wait
};
["city_override_registered",getText (configFile >> "CfgFunctions" >> "A3A" >> "CREATE" >> "createAICities" >> "file")
    == "\x\a3i\addons\core\overrides\fn_createAICities.sqf"
    && {getText (configFile >> "CfgFunctions" >> "A3I" >> "Originals" >> "originalCreateAICities" >> "file")
        == "\x\a3i\tests\contracts\fn_originalCreateAICities.sqf"}] call _check;
sidesX setVariable [_marker,east]; [_marker,"unchanged"] call A3A_fnc_createAICities;
sidesX setVariable [_marker,west];
A3A_faction_occ set ["infectionTemplate",""]; [_marker,"unchanged"] call A3A_fnc_createAICities;
A3A_faction_occ set ["infectionTemplate","A3I_Infected"];
A3I_dependencies set ["available",false]; [_marker,"unchanged"] call A3A_fnc_createAICities;
["city_inactive_selection",([_marker] call A3I_fnc_cityRoster) # 1 == "inactive"] call _check;
A3I_dependencies set ["available",true];
["city_other_factions_delegate",count A3I_test_originals == 3
    && {(A3I_test_originals findIf {_x # 1 isNotEqualTo [_marker,"unchanged"]}) == -1}] call _check;
private _police = [_marker] call A3I_fnc_cityRoster;
["city_size_support_selection",count (_police # 0) == 6 && {_police # 1 == "police"} && {_police # 2 == 2}
    && {(_police # 0) select [0,2] isEqualTo (A3A_faction_occ get "groupPolice")},_police] call _check;
A3A_townData set [_marker,[100,2,20,30]];
private _scaled = [_marker] call A3I_fnc_cityRoster;
["city_support_scales_count",count (_scaled # 0) == 4,_scaled] call _check;
A3A_townData set [_marker,[100,2,0,0]];
["city_minimum_patrol",count (([_marker] call A3I_fnc_cityRoster) # 0) == 2] call _check;
A3A_townData set [_marker,[100,2,60,40]];
outposts = ["a3i_city_neighbor"]; sidesX setVariable ["a3i_city_neighbor",east];
tierWar = 8;
private _front = [_marker] call A3I_fnc_cityRoster;
["city_frontline_doubles",count (_front # 0) == 12 && {_front # 1 == "frontline"}
    && {((_front # 0) findIf {_x find "loadouts_occ_elite_" != 0}) == -1},_front] call _check;
destroyedSites = [_marker];
private _ruined = [_marker] call A3I_fnc_cityRoster;
["city_ruined_groups",count (_ruined # 0) == 24 && {_ruined # 1 == "destroyed"} && {_ruined # 2 == 4}
    && {((_ruined # 0) findIf {_x find "loadouts_occ_SF_" != 0}) == -1},[_ruined # 1,count (_ruined # 0)]] call _check;
destroyedSites = []; outposts = []; sidesX setVariable ["a3i_city_neighbor",west]; tierWar = 1;
"a3i_city_neighbor" setMarkerPos getMarkerPos _marker;
sidesX setVariable ["a3i_city_neighbor",east];
["city_overlap_rejected",!([_marker,"City"] call A3I_fnc_startSite)
    && {([_marker] call A3I_fnc_cityRoster) # 1 == "overlap"}] call _check;
"a3i_city_neighbor" setMarkerPos [5100,4500,0]; sidesX setVariable ["a3i_city_neighbor",west];
A3A_townData deleteAt _marker;
["city_missing_data_rejected",!([_marker,"City"] call A3I_fnc_startSite)
    && {([_marker] call A3I_fnc_cityRoster) # 1 == "invalid_town_data"}] call _check;
A3A_townData set [_marker,[100,2,60,40]];
townSkirmishes = [_marker];
[_marker,"City"] call A3I_fnc_startSite;
sleep 1;
private _record = A3I_sites get _marker;
["city_skirmish_skip_events",_record get "queue" isEqualTo [] && {_record get "units" isEqualTo []}
    && {A3I_test_siteEvents isEqualTo [[_marker,"City",true]]}] call _check;
call _stop;
["city_skirmish_cleanup",A3I_test_siteEvents isEqualTo [[_marker,"City",true],[_marker,"City",false]]
    && {(call _stats) select [1,3] isEqualTo [0,0,0]}] call _check;
townSkirmishes = [];

// A normal civilian remains outside the patrol's ownership/cleanup lists.
private _civilianGroup = createGroup [civilian,false];
private _civilian = _civilianGroup createUnit ["C_man_1",[8000,8000,0],[],0,"NONE"];
_civilian disableAI "ALL";
_marker setMarkerSize [200,200];
spawner setVariable [_marker,0];
[2,2] call _setLimits;
private _full = ["reserve",["city-test-pressure",2,2]] call A3I_fnc_budget;
[[_marker],"A3A_fnc_createAICities"] call A3A_fnc_scheduler;
[{_marker in A3I_sites}] call _wait;
sleep 1.5;
_record = A3I_sites get _marker;
["city_capacity_keeps_visit_roster",count (_record get "queue") == 4 && {_record get "units" isEqualTo []}
    && {garrison getVariable _marker isEqualTo ["unrelated_saved_entry"]}] call _check;
private _nativeCalls = count A3I_test_originals;
[teamPlayer,_marker] call A3A_fnc_markerChange;
["city_uses_native_ownership_route",!([_marker] call A3I_fnc_siteCaptureBlocked)
    && {count A3I_test_originals == _nativeCalls + 1}
    && {[_marker,_record] call A3I_fnc_tryCaptureControl == sideUnknown}] call _check;
["close",[_full # 1 # 0]] call A3I_fnc_budget;
[{count (_record get "units") == 2}] call _wait;
private _units = +(_record get "units");
private _firstGroup = (_record get "groups") # 0;
private _points = _firstGroup getVariable ["A3I_patrolPoints",[]];
["city_server_local_basics",count _units == 2 && {count (_record get "queue") == 2}
    && {(_units findIf {owner _x != 2 || {side group _x != west} || {vehicle _x != _x}
        || {_x getVariable ["markerX",""] != ""} || {_x getVariable ["A3A_resPool",""] != "legacy"}
        || {typeOf _x != "Zombie_B_Walker_Civ"}}) == -1}
    && {!([_marker,"City"] call A3I_fnc_startSite)},[call _stats]] call _check;
private _routeBad = _points select {!(_x inArea _marker) || {_x distance2D getMarkerPos _marker > 150}
    || {surfaceIsWater _x} || {_x distance2D getMarkerPos respawnTeamPlayer < 200}};
private _cycles = (waypoints _firstGroup) select {waypointType _x == "CYCLE"};
["city_bounded_patrol_route",count _points >= 2 && {count _points <= 4} && {_routeBad isEqualTo []}
    && {count _cycles == 1} && {waypointPosition (_cycles # 0) distance2D (_points # 0) < 1},[_points,_routeBad]] call _check;
private _wpCount = count waypoints _firstGroup;
private _again = [_firstGroup,_marker] call A3I_fnc_patrolWaypoints;
["city_route_idempotent",_again isEqualTo _points && {count waypoints _firstGroup == _wpCount}] call _check;
private _survivor = _units # 1;
private _initialPosition = getPosATL _survivor;
spawner setVariable [_marker,1];
private _disabled = [{!simulationEnabled _survivor},3] call _wait;
spawner setVariable [_marker,0];
private _enabled = [{simulationEnabled _survivor},3] call _wait;
["city_simulation_transition",_disabled && {_enabled}] call _check;
A3A_resourcesAttackOcc = 1000; A3A_resourcesDefenceOcc = 1000;
A3I_test_zones = [];
(_units # 0) setDamage 1;
sleep 0.5;
["city_death_not_persistent",[A3A_resourcesAttackOcc,A3A_resourcesDefenceOcc] isEqualTo [995,995]
    && {garrison getVariable _marker isEqualTo ["unrelated_saved_entry"]}
    && {A3A_townData get _marker isEqualTo [100,2,60,40]} && {A3I_test_zones isEqualTo []}] call _check;
[4,4] call _setLimits;
private _allArrived = [{_record get "queue" isEqualTo []},20] call _wait;
["city_full_visit_arrives",_allArrived && {({alive _x} count (_record get "units")) == 3}
    && {(call _stats) select [1,2] isEqualTo [3,0]},[call _stats]] call _check;
["city_actual_patrol_movement",_survivor distance2D _initialPosition > 1,[_initialPosition,getPosATL _survivor]] call _check;
private _dead = +(_record get "units");
{if (alive _x) then {_x setDamage 1}} forEach _dead;
sleep 1.5;
["city_clear_keeps_support_ownership",sidesX getVariable _marker == west
    && {_record get "captured" == sideUnknown} && {count (_record get "queue") == 0}
    && {A3A_townData get _marker isEqualTo [100,2,60,40]}] call _check;
call _stop;
{deleteVehicle _x} forEach _dead;
spawner setVariable [_marker,0];
[2,2] call _setLimits;
[_marker,"City"] call A3I_fnc_startSite;
[{count ((A3I_sites get _marker) get "units") == 2}] call _wait;
_record = A3I_sites get _marker;
["city_reentry_regenerates",count (_record get "queue") == 2 && {count (_record get "units") == 2}
    && {garrison getVariable _marker isEqualTo ["unrelated_saved_entry"]}] call _check;
sidesX setVariable [_marker,east];
sleep 1.5;
["city_ownership_stops_waiting",_record get "queue" isEqualTo []
    && {({alive _x} count (_record get "units")) == 2}] call _check;
private _resourcesBeforeCleanup = [A3A_resourcesAttackOcc,A3A_resourcesDefenceOcc];
call _stop;
sleep 0.5;
["city_cleanup_preserves_civilians",alive _civilian && {side group _civilian == civilian}
    && {[A3A_resourcesAttackOcc,A3A_resourcesDefenceOcc] isEqualTo _resourcesBeforeCleanup}] call _check;

// Ruined-town groups must stay on WEST, rather than following the native EAST
// branch intended for conventional forces, and still respect the same cap.
sidesX setVariable [_marker,west]; spawner setVariable [_marker,0];
destroyedSites = [_marker];
[_marker,"City"] call A3I_fnc_startSite;
[{count ((A3I_sites get _marker) get "units") == 2}] call _wait;
_record = A3I_sites get _marker;
_units = _record get "units";
["city_ruins_stay_infected_west",(_units findIf {side group _x != west || {typeOf _x != "Zombie_B_RA_Civ"}}) == -1
    && {count (_record get "queue") == 14},[_units apply {typeOf _x},count (_record get "queue")]] call _check;
terminate (_record get "script");
private _recovered = [{!(_marker in A3I_sites)},4] call _wait;
["city_interrupted_cleanup",_recovered && {(call _stats) select [1,3] isEqualTo [0,0,0]}] call _check;
destroyedSites = [];

// Check failed route searches have no unchecked-center fallback or mutations.
private _routeSpawn = ["city-route-fixture",["loadouts_occ_militia_Rifleman"],[4500,4500,0],0,100] call A3I_fnc_spawnGroup;
private _routeGroup = _routeSpawn # 1 # 0;
respawnTeamPlayer setMarkerPos getMarkerPos _marker;
_marker setMarkerSize [50,50];
private _beforeWaypoints = count waypoints _routeGroup;
private _unsafe = [_routeGroup,_marker] call A3I_fnc_patrolWaypoints;
["city_no_unsafe_route_fallback",_unsafe isEqualTo [] && {count waypoints _routeGroup == _beforeWaypoints}] call _check;
private _retry = _routeGroup getVariable ["A3I_routeRetry",0];
respawnTeamPlayer setMarkerPos [500,500,0];
private _early = [_routeGroup,_marker] call A3I_fnc_patrolWaypoints;
private _keptDeadline = _routeGroup getVariable ["A3I_routeRetry",0] == _retry;
_routeGroup setVariable ["A3I_routeRetry",diag_tickTime - 1];
private _retried = [_routeGroup,_marker] call A3I_fnc_patrolWaypoints;
["city_route_retry_delay",_retry > diag_tickTime && {_early isEqualTo []}
    && {_keptDeadline} && {_retried isNotEqualTo []},[_retry,diag_tickTime,_retried]] call _check;
["cancel",[_routeSpawn # 1 # 2]] call A3I_fnc_budget;
["city_human_route_untouched",([_civilianGroup,_marker] call A3I_fnc_patrolWaypoints) isEqualTo []] call _check;
deleteVehicle _civilian; deleteGroup _civilianGroup;
sleep 3;
{deleteGroup _x} forEach (allGroups - _groupsBefore);
[CBA_EVENT_SERVER_SPAWN_LOCATION,_event] call CBA_fnc_removeEventHandler;
{deleteMarker _x} forEach (markersX + [respawnTeamPlayer]);
deleteVehicle garrison; deleteVehicle spawner; deleteVehicle sidesX;
garrison = nil; spawner = nil; sidesX = nil; respawnTeamPlayer = nil;
[_savedCap,_savedContext] call _setLimits;
plusGarrison = _savedTierMode;
GVAR(despawnQueue) = [];
private _remaining = (entities [[],[],true,false]) - _before;
["city_all_clean",_remaining isEqualTo [] && {(allGroups - _groupsBefore) isEqualTo []}
    && {count A3I_sites == 0} && {isNil "A3I_siteWatchdogHandle"}
    && {(call _stats) select [1,3] isEqualTo [0,0,0]},[_remaining apply {typeOf _x},call _stats]] call _check;
