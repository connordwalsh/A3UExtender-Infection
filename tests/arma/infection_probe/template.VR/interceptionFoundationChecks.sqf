// Actual native path queries and actors on controlled VR campaign records.
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
private _source = "a3i_interception_source";
private _destination = "a3i_interception_destination";
private _town = "a3i_interception_budgettown";
private _sourcePosition = [4000,4500,0];
private _destinationPosition = [5000,4500,0];
private _hqPosition = [5500,5500,0];
sidesX = [true] call A3A_fnc_createNamespace;
spawner = [true] call A3A_fnc_createNamespace;
garrison = [true] call A3A_fnc_createNamespace;
server = [true] call A3A_fnc_createNamespace;
respawnTeamPlayer = "a3i_interception_hq";
createMarker [_source,_sourcePosition];
createMarker [_destination,_destinationPosition];
createMarker [_town,[8000,4500,0]];
createMarker [respawnTeamPlayer,_hqPosition];
private _markers = [_source,_destination,_town,respawnTeamPlayer];
{_x setMarkerShape "ELLIPSE"; _x setMarkerSize [50,50]; sidesX setVariable [_x,west]; spawner setVariable [_x,2]} forEach _markers;
citiesX = [_source]; factories = [_destination]; resourcesX = []; outposts = [];
airportsX = []; milbases = []; seaports = []; milAdministrationsX = []; controlsX = [];
markersX = [_source,_destination]; forcedSpawn = [];
distanceMission = 1800; distanceForLandAttack = 2000;
A3I_majorSourceCooldowns = createHashMap;
A3A_recentDamageOcc = []; A3A_recentDamageInv = [];
server setVariable [_source,[90,0,0]];
NavGrid = [[_sourcePosition,1,0,[[1,0,1000]]],[_destinationPosition,1,0,[[0,0,1000]]]];
A3A_navCellHM = createHashMap;
{_forEachIndex call A3A_fnc_addToNavCells} forEach NavGrid;
A3A_markerNavPoints = createHashMap;
private _route = {[_destination,_source] call A3I_fnc_interceptionRoutes};
["intercept_initial_sizes_bounded",([-5] call A3I_fnc_interceptionSize) == 40
    && {([5] call A3I_fnc_interceptionSize) == 80} && {([15] call A3I_fnc_interceptionSize) == 120}] call _check;
private _routes = call _route;
["intercept_connected_town_factory",count _routes == 1
    && {(_routes # 0) select [0,2] isEqualTo [_destination,_source]}
    && {(_routes # 0 # 2) inArea _destination}
    && {(_routes # 0 # 3) distance2D _sourcePosition <= 25}
    && {!((_routes # 0 # 3) inArea _destination)}
    && {_routes # 0 # 4 > 0},_routes] call _check;
["intercept_planning_has_no_campaign_effects",server getVariable _source isEqualTo [90,0,0]
    && {count A3I_majorSourceCooldowns == 0} && {isNil "A3I_interceptions"}] call _check;
sidesX setVariable [_destination,teamPlayer];
["intercept_rebel_destination_allowed",count (call _route) == 1] call _check;
sidesX setVariable [_destination,Invaders];
["intercept_initial_russian_destination_refused",(call _route) isEqualTo []] call _check;
sidesX setVariable [_destination,west]; sidesX setVariable [_source,Invaders];
["intercept_russian_source_refused",(call _route) isEqualTo []] call _check;
sidesX setVariable [_source,west];
private _all = call A3I_fnc_interceptionRoutes;
["intercept_automatic_pair_selection",count _all == 1 && {_all # 0 # 0 == _destination}
    && {_all # 0 # 1 == _source}] call _check;
factories pushBack _destination; outposts = [_destination];
["intercept_duplicate_location_lists",count (call _route) == 1] call _check;
outposts = []; factories = [_destination]; controlsX = [_destination];
["intercept_controls_never_endpoints",(call _route) isEqualTo []] call _check;
controlsX = []; citiesX pushBack respawnTeamPlayer;
["intercept_hq_never_endpoint",!(respawnTeamPlayer in (call A3I_fnc_interceptionLocations))] call _check;
citiesX = [_source];
_destination setMarkerShape "ICON";
["intercept_boundary_required",(call _route) isEqualTo []] call _check;
_destination setMarkerShape "RECTANGLE"; _destination setMarkerSize [700,700]; _destination setMarkerDir 45;
["intercept_overlapping_spawn_area_refused",(call _route) isEqualTo []] call _check;
_destination setMarkerShape "ELLIPSE"; _destination setMarkerSize [50,50];
spawner setVariable [_source,0];
["intercept_active_source_refused",(call _route) isEqualTo []] call _check;
spawner setVariable [_source,2]; forcedSpawn = [_source];
["intercept_forced_source_refused",(call _route) isEqualTo []] call _check;
forcedSpawn = []; A3A_recentDamageOcc = [[4000,4500,60]];
["intercept_combat_source_refused",(call _route) isEqualTo []] call _check;
A3A_recentDamageOcc = []; A3I_majorSourceCooldowns set [_source,time + 60];
["intercept_cooldown_respected",(call _route) isEqualTo []] call _check;
A3I_majorSourceCooldowns = createHashMap;
server setVariable ["spawn_" + _source,"missing_vehicle_spawn"];
["intercept_foot_route_ignores_vehicle_marker",count (call _route) == 1] call _check;
server setVariable ["spawn_" + _source,nil];
NavGrid # 1 set [1,2];
["intercept_disconnected_route_refused",(call _route) isEqualTo []] call _check;
NavGrid # 1 set [1,1]; distanceForLandAttack = 500;
["intercept_walking_range_respected",(call _route) isEqualTo []] call _check;
distanceForLandAttack = 2000; distanceMission = 100;
["intercept_hq_range_respected",(call _route) isEqualTo []] call _check;
distanceMission = 2000; respawnTeamPlayer setMarkerPos _sourcePosition;
["intercept_unsafe_source_refused",(call _route) isEqualTo []] call _check;
respawnTeamPlayer setMarkerPos _hqPosition;
private _atomic = [1]; isNil {_atomic = call _route};
["intercept_unscheduled_search_refused",_atomic isEqualTo []] call _check;
A3I_dependencies set ["available",false];
["intercept_dependencies_required",(call _route) isEqualTo []] call _check;
A3I_dependencies set ["available",true]; A3A_faction_occ set ["infectionTemplate",""];
["intercept_inactive_template_refused",(call _route) isEqualTo []] call _check;
A3A_faction_occ set ["infectionTemplate","A3I_Infected"];

A3A_hasACE = false; A3A_GCThreshold = 600;
GVAR(despawnQueue) = []; GVAR(despawnerRunning) = nil;
A3A_faction_reb = createHashMapFromArray [["diveGear",[]],["flyGear",[]]];
A3A_resourcesDefenceOcc = 100; A3A_resourcesAttackOcc = 100;
A3I_test_support = []; A3I_test_aggression = []; A3I_test_zones = [];
tierWar = 0; plusGarrison = true;
[2,2] call _setLimits;
private _role = "loadouts_occ_militia_Rifleman";
private _shared = ["intercept-test-shared",[_role,_role],[6500,4500,0],0,100,"","legacy",2,false] call A3I_fnc_spawnGroup;
["intercept_shared_budget_filled",_shared # 0 && {count (_shared # 1 # 1) == 2}
    && {!((["reserve",["other",1,1]] call A3I_fnc_budget) # 0)}] call _check;
private _worker = [] spawn {sleep 600};
A3I_sites = createHashMapFromArray [[_town,createHashMapFromArray [["kind","City"],["cleaned",false],
    ["context","site:" + _town],["populationTarget",3]]]];
private _townTicket = (["reserve",["site:" + _town,3,3]] call A3I_fnc_budget) # 1 # 0;
private _context = "interception:fixture";
private _job = createHashMapFromArray [["context",_context],["size",40],["phase","preparing"],
    ["retired",false],["script",_worker]];
A3I_interceptions = createHashMapFromArray [["fixture",_job]];
private _reservation = ["reserve",[_context,41,40]] call A3I_fnc_budget;
["intercept_full_allowance_with_shared_and_town_full",_reservation # 0 && {_reservation # 1 # 1 == 40}
    && {(call _stats) select [0,3] isEqualTo [45,2,43]},[_reservation,call _stats]] call _check;
["intercept_cannot_exceed_job_size",!((["reserve",[_context,1,40]] call A3I_fnc_budget) # 0)] call _check;
["intercept_cannot_borrow_job_allowance",!((["reserve",["other",1,1]] call A3I_fnc_budget) # 0)
    && {!((["reserve",["interception:forged",1,1]] call A3I_fnc_budget) # 0)}] call _check;
["close",[_reservation # 1 # 0]] call A3I_fnc_budget;
private _roles = []; for "_i" from 1 to 40 do {_roles pushBack _role};
private _spawn = [_context,_roles,_sourcePosition,0,100,"","legacy",40,false] call A3I_fnc_spawnGroup;
private _members = _spawn # 1 # 1;
private _hordeTicket = _spawn # 1 # 2;
["intercept_actual_complete_horde_with_shared_full",_spawn # 0 && {count _members == 40}
    && {_spawn # 2 == ""} && {(call _stats) select [0,3] isEqualTo [45,42,3]}
    && {(_members findIf {!local _x || {side group _x != west}
        || {!(_x getVariable ["A3I_initialized",false])} || {_x getVariable ["markerX",""] != ""}}) == -1},
    [count _members,call _stats,_spawn # 2]] call _check;
_job set ["phase","marching"];
["intercept_marching_cannot_add_members",!((["reserve",[_context,1,40]] call A3I_fnc_budget) # 0)
    && {(call _stats) # 0 == 45}] call _check;
private _transfer = ["transfer",[_hordeTicket,"other",24]] call A3I_fnc_budget;
["intercept_cannot_transfer_to_shared",!(_transfer # 0) && {_transfer # 2 == "interception_population_fixed"}] call _check;
["close",[_shared # 1 # 2]] call A3I_fnc_budget;
["intercept_cannot_import_shared_members",!((["transfer",[_shared # 1 # 2,_context,40]] call A3I_fnc_budget) # 0)] call _check;
if (count _members == 40) then {
    (_members # 0) setDamage 1; sleep 0.3;
    ["intercept_death_does_not_refill",(call _stats) # 1 == 41
        && {!((["reserve",[_context,1,40]] call A3I_fnc_budget) # 0)}] call _check;
    deleteVehicle (_members # 1); sleep 0.2;
    ["intercept_live_deletion_releases_only_its_slot",(call _stats) # 1 == 40
        && {!((["reserve",["other",1,1]] call A3I_fnc_budget) # 0)}] call _check;
};
_job set ["phase","preparing"];
private _unfilled = ["reserve",[_context,1,40]] call A3I_fnc_budget;
terminate _worker;
private _immediateDone = scriptDone _worker;
private _stopDeadline = diag_tickTime + 2;
waitUntil {sleep 0.05; scriptDone _worker || {diag_tickTime > _stopDeadline}};
["intercept_worker_stop_observed",scriptDone _worker,[_immediateDone,scriptDone _worker]] call _check;
["intercept_stopped_worker_loses_pending_reservation",_unfilled # 0
    && {!((["remaining",[_unfilled # 1 # 0]] call A3I_fnc_budget) # 0)}] call _check;
["intercept_stopped_worker_cannot_reserve",!((["reserve",[_context,1,40]] call A3I_fnc_budget) # 0)] call _check;
_job set ["retired",true];
["intercept_retired_bindings_stay_outside_shared",(call _stats) # 1 == 40
    && {!((["reserve",["other",1,1]] call A3I_fnc_budget) # 0)}] call _check;
A3I_interceptions deleteAt "fixture";
["intercept_removed_job_cannot_reclassify_context",!((["reserve",[_context,1,40]] call A3I_fnc_budget) # 0)
    && {!((["transfer",[_hordeTicket,"other",24]] call A3I_fnc_budget) # 0)}] call _check;
["cancel",[_hordeTicket]] call A3I_fnc_budget;
private _maximumWorker = [] spawn {sleep 600};
private _maximumContext = "interception:maximum";
private _maximumJob = createHashMapFromArray [["context",_maximumContext],["size",121],
    ["phase","preparing"],["retired",false],["script",_maximumWorker]];
A3I_interceptions set ["maximum",_maximumJob];
["intercept_oversized_allowance_refused",!((["reserve",[_maximumContext,121,121]] call A3I_fnc_budget) # 0)] call _check;
_maximumJob set ["size",120]; _maximumJob set ["context","interception:mismatched"];
["intercept_mismatched_job_context_refused",!((["reserve",[_maximumContext,120,120]] call A3I_fnc_budget) # 0)] call _check;
_maximumJob set ["context",_maximumContext];
private _pending = ["reserve",[_maximumContext,120,120]] call A3I_fnc_budget;
_maximumJob set ["phase","marching"];
["intercept_phase_change_retires_unused_slots",_pending # 0 && {_pending # 1 # 1 == 120}
    && {!((["remaining",[_pending # 1 # 0]] call A3I_fnc_budget) # 0)}] call _check;
_maximumJob set ["phase","preparing"];
private _maximumRoles = []; for "_i" from 1 to 120 do {_maximumRoles pushBack _role};
private _maximumSpawn = [_maximumContext,_maximumRoles,[8000,4500,0],0,100,"","legacy",120,false] call A3I_fnc_spawnGroup;
["intercept_actual_maximum_horde",_maximumSpawn # 0 && {count (_maximumSpawn # 1 # 1) == 120}
    && {_maximumSpawn # 2 == ""} && {(call _stats) select [0,3] isEqualTo [125,122,3]},
    [count (_maximumSpawn # 1 # 1),_maximumSpawn # 2,call _stats]] call _check;
["cancel",[_maximumSpawn # 1 # 2]] call A3I_fnc_budget;
{deleteVehicle _x} forEach (_maximumSpawn # 1 # 1);
terminate _maximumWorker;
A3I_interceptions deleteAt "maximum";
["cancel",[_shared # 1 # 2]] call A3I_fnc_budget;
["close",[_townTicket]] call A3I_fnc_budget;
{deleteVehicle _x} forEach (_members + (_shared # 1 # 1));
A3I_sites = createHashMap; A3I_interceptions = nil;
sleep 0.5;
{deleteGroup _x} forEach (allGroups - _groupsBefore);
{deleteVehicle _x} forEach [sidesX,spawner,garrison,server];
{deleteMarker _x} forEach _markers;
[_savedCap,_savedContext] call _setLimits;
sleep 0.3;
["intercept_foundation_cleanup",(call _stats) select [1,3] isEqualTo [0,0,0]
    && {(entities [[],[],true,false]) - _before isEqualTo []}
    && {allGroups - _groupsBefore isEqualTo []}] call _check;
