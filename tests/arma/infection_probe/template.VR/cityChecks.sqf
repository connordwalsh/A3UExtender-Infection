// Full-town logistic populations and actual server-local lifecycle.
// Original faction/support/UI endpoints remain recording callbacks.
#include "\x\a3a\addons\core\script_component.hpp"
private _before = entities [[],[],true,false];
private _groupsBefore = +allGroups;
private _savedCap = A3I_activeLimit;
private _savedContext = A3I_contextLimit;
private _savedTierMode = missionNamespace getVariable ["plusGarrison",false];
plusGarrison = true; tierWar = 1; distanceSPWN = 1000;
A3A_GCThreshold = 600; GVAR(despawnQueue) = []; GVAR(despawnerRunning) = nil;
A3A_recentDamageOcc = []; A3A_hasACE = false;
A3I_test_support = []; A3I_test_aggression = []; A3I_test_zones = [];
A3A_resourcesAttackOcc = 1000; A3A_resourcesDefenceOcc = 1000;
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
private _neighbor = "a3i_city_neighbor";
createMarker [_marker,[4500,4500,0]];
_marker setMarkerShape "ELLIPSE"; _marker setMarkerSize [300,300];
createMarker [_neighbor,[5100,4500,0]];
_neighbor setMarkerShape "RECTANGLE"; _neighbor setMarkerSize [50,50];
citiesX = [_marker]; controlsX = []; milAdministrationsX = [];
markersX = [_marker,_neighbor];
airportsX = []; outposts = []; seaports = []; milbases = []; resourcesX = []; factories = [];
townSkirmishes = []; destroyedSites = [];
A3A_townData = createHashMapFromArray [[_marker,[100,2,60,40]]];
A3A_faction_civ = createHashMapFromArray [["attributeCivNonHuman",false]];
sidesX setVariable [_marker,west]; sidesX setVariable [_neighbor,west];
spawner setVariable [_marker,0];
garrison setVariable [_marker,["unrelated_saved_entry"]];
hcArray = [999]; A3I_test_originals = []; A3I_test_siteEvents = [];
private _event = [CBA_EVENT_SERVER_SPAWN_LOCATION,{A3I_test_siteEvents pushBack +_this}] call CBA_fnc_addEventHandler;
private _stop = {
    params [["_town",_marker]];
    spawner setVariable [_town,2];
    private _removed = [{!(_town in A3I_sites)},5] call _wait;
    sleep 0.3;
    _removed
};
["city_override_registered",getText (configFile >> "CfgFunctions" >> "A3A" >> "CREATE" >> "createAICities" >> "file")
    == "\x\a3i\addons\core\overrides\fn_createAICities.sqf"] call _check;
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
["city_logistic_selection",count (_police # 0) == 85 && {_police # 1 == "police"} && {_police # 2 == 12}
    && {(_police # 0) select [0,2] isEqualTo (A3A_faction_occ get "groupPolice")}] call _check;
private _modelCases = [[0,10],[1,10],[10,10],[23,21],[46,41],[50,44],[100,85],[166,127],[200,144],[367,186],[603,198],[1176,200],[1000000,200]];
private _modelResults = _modelCases apply {[[_x # 0] call A3I_fnc_cityPopulationTarget,_x # 1]};
["city_logistic_floor_growth_cap",(_modelResults findIf {_x # 0 != _x # 1}) == -1,_modelResults] call _check;
private _terrainCases = call compile preprocessFileLineNumbers "cityPopulationCases.sqf";
private _badTerrain = _terrainCases select {[_x # 0] call A3I_fnc_cityPopulationTarget != _x # 1};
["city_all_terrain_population_counts",count _terrainCases == 49 && {_badTerrain isEqualTo []},[count _terrainCases,_badTerrain]] call _check;
A3A_townData set [_marker,[100,999,0,0]];
["city_support_does_not_scale_population",count (([_marker] call A3I_fnc_cityRoster) # 0) == 85] call _check;
_marker setMarkerSize [900,600];
["city_size_does_not_scale_population",count (([_marker] call A3I_fnc_cityRoster) # 0) == 85] call _check;
_marker setMarkerSize [300,300];
private _badData = [-1,"100",[],true] apply {
    A3A_townData set [_marker,[_x,2,60,40]];
    ([_marker] call A3I_fnc_cityRoster) # 1 == "invalid_town_data" && {[_x] call A3I_fnc_cityPopulationTarget == -1}
};
["city_invalid_population_rejected",(_badData findIf {!_x}) == -1] call _check;
A3A_townData deleteAt _marker;
["city_missing_data_rejected",!([_marker,"City"] call A3I_fnc_startSite)] call _check;
A3A_townData set [_marker,[100,2,60,40]];
private _wrongOwners = [east,independent,civilian,sideUnknown] apply {
    sidesX setVariable [_marker,_x];
    ([_marker] call A3I_fnc_cityRoster) # 1 == "inactive"
};
sidesX setVariable [_marker,west];
["city_only_infected_ownership",(_wrongOwners findIf {!_x}) == -1] call _check;
outposts = [_neighbor]; sidesX setVariable [_neighbor,east]; tierWar = 8;
private _front = [_marker] call A3I_fnc_cityRoster;
["city_frontline_keeps_population",count (_front # 0) == 85 && {_front # 1 == "frontline"}
    && {((_front # 0) findIf {_x find "loadouts_occ_elite_" != 0}) == -1}] call _check;
destroyedSites = [_marker];
private _ruined = [_marker] call A3I_fnc_cityRoster;
["city_ruined_groups",count (_ruined # 0) == 85 && {_ruined # 1 == "destroyed"} && {_ruined # 2 == 12}
    && {((_ruined # 0) findIf {_x find "loadouts_occ_SF_" != 0}) == -1}] call _check;
destroyedSites = []; outposts = []; tierWar = 1;
_neighbor setMarkerPos getMarkerPos _marker;
["city_enemy_site_does_not_suppress",count (([_marker] call A3I_fnc_cityRoster) # 0) == 85] call _check;
townSkirmishes = [_marker];
["city_skirmish_does_not_suppress",count (([_marker] call A3I_fnc_cityRoster) # 0) == 85] call _check;
A3A_faction_civ set ["attributeCivNonHuman",true];
private _nonhumanCounts = [];
for "_i" from 1 to 20 do {_nonhumanCounts pushBack count (([_marker] call A3I_fnc_cityRoster) # 0)};
["city_nonhuman_civilians_do_not_suppress",(_nonhumanCounts findIf {_x != 85}) == -1] call _check;
A3A_faction_civ set ["attributeCivNonHuman",false];

// Real actors fill the town even while the entire non-town budget is occupied.
private _civilianGroup = createGroup [civilian,false];
private _civilian = _civilianGroup createUnit ["C_man_1",[8000,8000,0],[],0,"NONE"];
_civilian disableAI "ALL";
[2,2] call _setLimits;
private _pressure = ["city-pressure",["loadouts_occ_militia_Rifleman","loadouts_occ_militia_Rifleman"],
    [8000,4500,0],0,100,"","legacy",2,false] call A3I_fnc_spawnGroup;
["city_pressure_fixture",_pressure # 0 && {count (_pressure # 1 # 1) == 2}] call _check;
A3A_townData set [_marker,[10,2,60,40]];
_marker setMarkerSize [100,100];
respawnTeamPlayer setMarkerPos getMarkerPos _marker;
[[_marker],"A3A_fnc_createAICities"] call A3A_fnc_scheduler;
[{_marker in A3I_sites}] call _wait;
sleep 1.5;
private _record = A3I_sites get _marker;
["city_unsafe_placement_retains_population",count (_record get "queue") == 10 && {_record get "units" isEqualTo []}
    && {_record get "populationTarget" == 10} && {_record get "fault" == ""}
    && {garrison getVariable _marker isEqualTo ["unrelated_saved_entry"]}] call _check;
private _allowance = ["reserve",[_record get "context",10,200]] call A3I_fnc_budget;
private _duplicateAllowance = ["reserve",[_record get "context",1,200]] call A3I_fnc_budget;
["city_full_reserved_allowance",_allowance # 0 && {_allowance # 1 # 1 == 10}
    && {_duplicateAllowance # 2 == "capacity"} && {(call _stats) select [0,3] isEqualTo [12,2,10]}] call _check;
["close",[_allowance # 1 # 0]] call A3I_fnc_budget;
private _forged = ["reserve",["site:unregistered-town",200,200]] call A3I_fnc_budget;
["city_no_unregistered_allowance",!(_forged # 0) && {_forged # 2 == "capacity"}] call _check;
respawnTeamPlayer setMarkerPos [500,500,0];
private _allArrived = [{_record get "queue" isEqualTo []},20] call _wait;
private _units = +(_record get "units");
["city_full_population_without_casualties",_allArrived && {count _units == 10} && {({alive _x} count _units) == 10}
    && {(call _stats) select [0,3] isEqualTo [12,12,0]} && {_record get "spawnedCount" == 10},[call _stats]] call _check;
["city_server_local_basics",(_units findIf {owner _x != 2 || {side group _x != west} || {vehicle _x != _x}
    || {_x getVariable ["markerX",""] != ""} || {_x getVariable ["A3A_resPool",""] != "legacy"}
    || {_x getVariable ["spawner",true]}
    || {typeOf _x != "Zombie_B_Walker_Civ"}}) == -1 && {!([_marker,"City"] call A3I_fnc_startSite)}] call _check;
["city_shared_limit_still_enforced",(["reserve",["another-event",1,200]] call A3I_fnc_budget) # 2 == "capacity"] call _check;
private _townTicket = (_units # 0) getVariable "A3I_budgetTicket";
["city_town_transfer_refused",(["transfer",[_townTicket,"other-event",200]] call A3I_fnc_budget) # 2 == "town_population_fixed"] call _check;
["city_incoming_transfer_refused",(["transfer",[_pressure # 1 # 2,_record get "context",200]] call A3I_fnc_budget) # 2 == "town_population_fixed"] call _check;
private _nativeCalls = count A3I_test_originals;
[teamPlayer,_marker] call A3A_fnc_markerChange;
["city_uses_native_ownership_route",!([_marker] call A3I_fnc_siteCaptureBlocked)
    && {count A3I_test_originals == _nativeCalls + 1}
    && {[_marker,_record] call A3I_fnc_tryCaptureControl == sideUnknown}] call _check;
private _firstGroup = (_record get "groups") # 0;
private _points = _firstGroup getVariable ["A3I_patrolPoints",[]];
private _anchor = _firstGroup getVariable "A3I_patrolCenter";
private _badPoints = _points select {!(_x inArea _marker) || {_x distance2D _anchor > 100} || {surfaceIsWater _x}};
private _cycles = (waypoints _firstGroup) select {waypointType _x == "CYCLE"};
["city_bounded_patrol_route",count _points >= 1 && {count _points <= 4} && {_badPoints isEqualTo []}
    && {count _points == 1 || {count _cycles == 1 && {waypointPosition (_cycles # 0) distance2D (_points # 0) < 1}}}] call _check;
private _waypointCount = count waypoints _firstGroup;
["city_route_idempotent",([_firstGroup,_marker] call A3I_fnc_patrolWaypoints) isEqualTo _points
    && {count waypoints _firstGroup == _waypointCount}] call _check;
private _survivor = leader _firstGroup;
private _initialPosition = getPosATL _survivor;
spawner setVariable [_marker,1];
private _disabled = [{(_units findIf {simulationEnabled _x}) == -1},3] call _wait;
spawner setVariable [_marker,0];
private _enabled = [{(_units findIf {!simulationEnabled _x}) == -1},3] call _wait;
["city_simulation_transition",_disabled && {_enabled}] call _check;
(_units # 9) setDamage 1;
sleep 0.5;
["city_death_not_persistent",[A3A_resourcesAttackOcc,A3A_resourcesDefenceOcc] isEqualTo [995,995]
    && {garrison getVariable _marker isEqualTo ["unrelated_saved_entry"]}
    && {A3A_townData get _marker isEqualTo [10,2,60,40]} && {A3I_test_zones isEqualTo []}] call _check;
sleep 3;
["city_no_within_visit_regeneration",_record get "spawnedCount" == 10 && {_record get "queue" isEqualTo []}
    && {({alive _x} count (_record get "units")) == 9}] call _check;
private _moved = [{_survivor distance2D _initialPosition > 1},10] call _wait;
["city_actual_patrol_movement",_moved,[_initialPosition,getPosATL _survivor]] call _check;
{if (alive _x) then {_x setDamage 1}} forEach _units;
sleep 1.5;
["city_clear_keeps_support_ownership",sidesX getVariable _marker == west && {_record get "captured" == sideUnknown}
    && {_record get "queue" isEqualTo []} && {A3A_townData get _marker isEqualTo [10,2,60,40]}] call _check;
[] call _stop;
{deleteVehicle _x} forEach _units;
["city_paired_events",A3I_test_siteEvents isEqualTo [[_marker,"City",true],[_marker,"City",false]]] call _check;
spawner setVariable [_marker,0];
[_marker,"City"] call A3I_fnc_startSite;
_record = A3I_sites get _marker;
[{_record get "queue" isEqualTo []}] call _wait;
["city_reentry_regenerates",count (_record get "units") == 10 && {_record get "spawnedCount" == 10}] call _check;
sidesX setVariable [_marker,east]; sleep 1.2;
["city_owner_change_preserves_existing",({alive _x} count (_record get "units")) == 10] call _check;
private _resourcesBeforeCleanup = [A3A_resourcesAttackOcc,A3A_resourcesDefenceOcc];
[] call _stop;
["city_cleanup_preserves_civilians",alive _civilian && {side group _civilian == civilian}
    && {[A3A_resourcesAttackOcc,A3A_resourcesDefenceOcc] isEqualTo _resourcesBeforeCleanup}] call _check;
sidesX setVariable [_marker,west]; spawner setVariable [_marker,0];
respawnTeamPlayer setMarkerPos getMarkerPos _marker;
[_marker,"City"] call A3I_fnc_startSite;
_record = A3I_sites get _marker; sleep 1.2;
sidesX setVariable [_marker,east]; sleep 1.2;
respawnTeamPlayer setMarkerPos [500,500,0]; sleep 5.5;
["city_ownership_stops_waiting",_record get "queue" isEqualTo [] && {_record get "units" isEqualTo []}] call _check;
[] call _stop;
sidesX setVariable [_marker,west]; spawner setVariable [_marker,0]; destroyedSites = [_marker];
[_marker,"City"] call A3I_fnc_startSite;
_record = A3I_sites get _marker;
[{_record get "queue" isEqualTo []}] call _wait;
["city_ruins_stay_infected_west",count (_record get "units") == 10 && {((_record get "units") findIf {
    side group _x != west || {typeOf _x != "Zombie_B_RA_Civ"}}) == -1}] call _check;
[] call _stop;
destroyedSites = []; townSkirmishes = [];

// Full-size and simultaneous-town cases use the real controller and 221 actors.
_marker setMarkerShape "RECTANGLE"; _marker setMarkerSize [600,400]; _marker setMarkerDir 32;
_neighbor setMarkerPos [6500,4500,0]; _neighbor setMarkerSize [180,140]; _neighbor setMarkerDir 67;
citiesX pushBack _neighbor; sidesX setVariable [_neighbor,west];
A3A_townData set [_marker,[1176,2,60,40]]; A3A_townData set [_neighbor,[23,2,60,40]];
spawner setVariable [_marker,0]; spawner setVariable [_neighbor,0];
private _began = diag_tickTime;
[_marker,"City"] call A3I_fnc_startSite;
[_neighbor,"City"] call A3I_fnc_startSite;
_record = A3I_sites get _marker;
private _otherRecord = A3I_sites get _neighbor;
private _crowded = [{_record get "queue" isEqualTo [] && {_otherRecord get "queue" isEqualTo []}},90] call _wait;
private _elapsed = diag_tickTime - _began;
private _largeUnits = +(_record get "units");
["city_entire_large_population",_crowded && {count _largeUnits == 200} && {({alive _x} count _largeUnits) == 200}
    && {_record get "spawnedCount" == 200},[count _largeUnits,_elapsed,diag_fps]] call _check;
["city_simultaneous_towns",count (_otherRecord get "units") == 21 && {(call _stats) select [0,3] isEqualTo [223,223,0]},[call _stats]] call _check;
private _births = _largeUnits apply {_x getVariable ["A3I_spawnPosition",[]]};
["city_rotated_marker_spawn_bounds",(_births findIf {count _x != 3 || {!(_x inArea _marker)}}) == -1] call _check;
["city_spread_beyond_center",(_births findIf {_x distance2D getMarkerPos _marker > 150}) != -1] call _check;
private _badClusters = (_record get "groups") select {
    private _anchor = _x getVariable ["A3I_patrolCenter",[]];
    (units _x findIf {(_x getVariable ["A3I_spawnPosition",[]]) distance2D _anchor > 50}) != -1
};
["city_groups_stay_local",_badClusters isEqualTo [] && {count (_record get "groups") < 50}
    && {((_record get "groups") findIf {count units _x > 12}) == -1},[count (_record get "groups")]] call _check;
["city_population_cannot_overfill",(["reserve",[_record get "context",1,200]] call A3I_fnc_budget) # 2 == "capacity"] call _check;
["city_no_cross_town_transfer",(["transfer",[(_largeUnits # 0) getVariable "A3I_budgetTicket",_otherRecord get "context",200]] call A3I_fnc_budget) # 2 == "town_population_fixed"] call _check;
spawner setVariable [_marker,1];
private _largeDisabled = [{(_largeUnits findIf {simulationEnabled _x}) == -1},4] call _wait;
["city_simulation_independent",_largeDisabled && {((_otherRecord get "units") findIf {!simulationEnabled _x}) == -1}] call _check;
spawner setVariable [_marker,0];
[{(_largeUnits findIf {!simulationEnabled _x}) == -1},4] call _wait;
[_neighbor] call _stop;
[] call _stop;
["city_large_cleanup_releases_allowances",(call _stats) select [0,3] isEqualTo [2,2,0]
    && {(_largeUnits findIf {!isNull _x}) == -1},[call _stats]] call _check;

// Stop during creation, including actors not yet returned to the controller.
spawner setVariable [_marker,0]; [_marker,"City"] call A3I_fnc_startSite;
_record = A3I_sites get _marker;
[{_record get "spawnedCount" >= 12},15] call _wait;
private _partialCount = _record get "spawnedCount";
terminate (_record get "script");
private _recovered = [{!(_marker in A3I_sites)},5] call _wait;
sleep 0.5;
["city_interrupted_creation_cleanup",_partialCount > 0 && {_partialCount < 200} && {_recovered}
    && {(call _stats) select [0,3] isEqualTo [2,2,0]},[_partialCount,call _stats]] call _check;
["cancel",[_pressure # 1 # 2]] call A3I_fnc_budget;
sleep 0.3;
private _expiredAllowance = ["reserve",["site:" + _marker,200,200]] call A3I_fnc_budget;
["city_retired_allowance_not_reusable",_expiredAllowance # 1 # 1 == 2] call _check;
["close",[_expiredAllowance # 1 # 0]] call A3I_fnc_budget;

// Bounded terrain search and route retries retain all safety rules.
private _roadPoint = getMarkerPos _marker vectorAdd [250,0,0];
private _roadSearch = [_marker,"Zombie_B_Walker_Civ",[],[_roadPoint]] call A3I_fnc_findCitySpawnPosition;
["city_road_anchor_outside_center",_roadSearch # 0 isNotEqualTo [] && {(_roadSearch # 0) inArea _marker}
    && {(_roadSearch # 0) distance2D getMarkerPos _marker > 200}] call _check;
_marker setMarkerShape "ELLIPSE"; _marker setMarkerSize [180,80]; _marker setMarkerDir 38;
private _ellipseSearches = [];
for "_i" from 1 to 16 do {_ellipseSearches pushBack ([_marker,"Zombie_B_Walker_Civ"] call A3I_fnc_findCitySpawnPosition)};
["city_rotated_ellipse_search",(_ellipseSearches findIf {_x # 0 isEqualTo [] || {!((_x # 0) inArea _marker)}}) == -1] call _check;
["city_invalid_spawn_search",(["missing","Zombie_B_Walker_Civ"] call A3I_fnc_findCitySpawnPosition) isEqualTo [[],"invalid_request"]
    && {([_marker,"C_man_1",["bad"]] call A3I_fnc_findCitySpawnPosition) isEqualTo [[],"invalid_request"]}] call _check;
private _routeSpawn = ["city-route-fixture",["loadouts_occ_militia_Rifleman"],[4500,4500,0],0,100] call A3I_fnc_spawnGroup;
private _routeGroup = _routeSpawn # 1 # 0;
respawnTeamPlayer setMarkerPos getMarkerPos _marker;
_marker setMarkerSize [50,50];
private _beforeWaypoints = count waypoints _routeGroup;
private _unsafe = [_routeGroup,_marker] call A3I_fnc_patrolWaypoints;
["city_no_unsafe_route_fallback",_unsafe isEqualTo [] && {count waypoints _routeGroup == _beforeWaypoints}
    && {([_marker,"Zombie_B_Walker_Civ"] call A3I_fnc_findCitySpawnPosition) # 0 isEqualTo []}] call _check;
private _retry = _routeGroup getVariable ["A3I_routeRetry",0];
respawnTeamPlayer setMarkerPos [500,500,0];
private _early = [_routeGroup,_marker] call A3I_fnc_patrolWaypoints;
private _keptDeadline = _routeGroup getVariable ["A3I_routeRetry",0] == _retry;
_routeGroup setVariable ["A3I_routeRetry",diag_tickTime - 1];
private _retried = [_routeGroup,_marker] call A3I_fnc_patrolWaypoints;
["city_route_retry_delay",_retry > diag_tickTime && {_early isEqualTo []} && {_keptDeadline} && {_retried isNotEqualTo []}] call _check;
["cancel",[_routeSpawn # 1 # 2]] call A3I_fnc_budget;
["city_human_route_untouched",([_civilianGroup,_marker] call A3I_fnc_patrolWaypoints) isEqualTo []] call _check;

// Active towns must start after either ownership transaction, without waiting
// for a distance-state transition. The political route calls the installed
// native cityChangeSide, including its five-second ownership race window.
["city_ownership_hooks_registered",getText (configFile >> "CfgFunctions" >> "A3A" >> "Base" >> "cityChangeSide" >> "file")
    == "\x\a3i\addons\core\overrides\fn_cityChangeSide.sqf"
    && {getText (configFile >> "CfgFunctions" >> "A3I" >> "Originals" >> "originalCityChangeSide" >> "file")
        == "\x\a3a\addons\core\functions\Base\fn_cityChangeSide.sqf"}] call _check;
A3A_townData set [_marker,[10,2,60,40]];
_marker setMarkerSize [100,100];
sidesX setVariable [_marker,east]; spawner setVariable [_marker,0];
private _eventsBeforeHandoff = count A3I_test_siteEvents;
private _expectedReturn = count A3I_test_originals;
private _nativeReturn = [west,_marker] call A3A_fnc_markerChange;
["city_rejected_native_change_does_not_spawn",!(_marker in A3I_sites)
    && {sidesX getVariable _marker == east} && {_nativeReturn isEqualTo _expectedReturn}] call _check;
A3I_test_applyMarkerChange = true;
[west,_marker] call A3A_fnc_markerChange;
_record = A3I_sites get _marker;
[{_record get "queue" isEqualTo []}] call _wait;
["city_active_capture_starts_population",count (_record get "units") == 10
    && {!(_record get "announced")} && {!(_record get "assets")}
    && {count A3I_test_siteEvents == _eventsBeforeHandoff} && {alive _civilian}] call _check;
((_record get "units") # 0) setDamage 1;
sleep 0.3;
private _visitId = _record get "id";
[west,_marker] call A3A_fnc_markerChange;
["city_capture_handoff_retains_visit",(A3I_sites get _marker) get "id" == _visitId
    && {_record get "spawnedCount" == 10} && {({alive _x} count (_record get "units")) == 9}] call _check;
private _handoffUnits = +(_record get "units");
[] call _stop;
{deleteVehicle _x} forEach _handoffUnits;
A3I_test_applyMarkerChange = false;
A3I_test_markerUpdates = [];
sidesX setVariable [_marker,east]; spawner setVariable [_marker,0];
private _politicalReturn = [_marker,false] call A3A_fnc_cityChangeSide;
_record = A3I_sites get _marker;
[{_record get "queue" isEqualTo []}] call _wait;
["city_native_support_change_starts_population",sidesX getVariable _marker == west
    && {count (_record get "units") == 10} && {garrison getVariable _marker isEqualTo []}
    && {[_marker] in A3I_test_markerUpdates} && {isNil "_politicalReturn"}
    && {count A3I_test_siteEvents == _eventsBeforeHandoff}] call _check;
[] call _stop;
sidesX setVariable [_marker,east]; spawner setVariable [_marker,1];
[_marker,false] call A3A_fnc_cityChangeSide;
_record = A3I_sites get _marker; sleep 1.2;
["city_suspended_capture_waits_for_activation",_record get "units" isEqualTo []
    && {count (_record get "queue") == 10}] call _check;
spawner setVariable [_marker,0];
[{_record get "queue" isEqualTo []}] call _wait;
["city_suspended_capture_resumes_population",count (_record get "units") == 10] call _check;
[] call _stop;
sidesX setVariable [_marker,east];
[_marker,false] call A3A_fnc_cityChangeSide;
["city_offscreen_capture_waits_for_visit",sidesX getVariable _marker == west && {!(_marker in A3I_sites)}] call _check;
sidesX setVariable [_marker,east]; spawner setVariable [_marker,0];
A3I_dependencies set ["available",false];
[_marker,false] call A3A_fnc_cityChangeSide;
private _missingDidNotSpawn = !(_marker in A3I_sites) && {sidesX getVariable _marker == west};
A3I_dependencies set ["available",true];
sidesX setVariable [_marker,east]; A3A_faction_occ set ["infectionTemplate",""];
[_marker,false] call A3A_fnc_cityChangeSide;
["city_inactive_ownership_hooks_delegate",_missingDidNotSpawn && {!(_marker in A3I_sites)}
    && {sidesX getVariable _marker == west}] call _check;
A3A_faction_occ set ["infectionTemplate","A3I_Infected"];
sidesX setVariable [_marker,east];
private _raceBegan = diag_tickTime;
private _cityScript = [_marker,false] spawn A3A_fnc_cityChangeSide;
private _raceObserved = [{sidesX getVariable _marker == west}] call _wait;
private _raceAtFlip = [diag_tickTime - _raceBegan,sidesX getVariable _marker,scriptDone _cityScript];
// Match native ownership transactions: a local-only update can be overwritten
// by the earlier WEST broadcast on the global namespace object.
sidesX setVariable [_marker,east,true];
private _raceImmediateOwner = sidesX getVariable _marker;
[{scriptDone _cityScript}] call _wait;
["city_capture_handoff_rechecks_current_owner",scriptDone _cityScript && {!(_marker in A3I_sites)}
    && {sidesX getVariable _marker == east} && {alive _civilian},
    [_raceObserved,_raceAtFlip,_raceImmediateOwner,sidesX getVariable _marker,_marker in A3I_sites]] call _check;
spawner setVariable [_marker,2];
A3I_test_applyMarkerChange = nil;
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
