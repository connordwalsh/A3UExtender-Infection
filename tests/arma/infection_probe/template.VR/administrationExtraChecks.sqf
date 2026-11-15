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
private _source = "a3i_adminextra_source";
private _destination = "a3i_adminextra_destination";
private _town = "a3i_adminextra_budgettown";
private _sourcePosition = [4000,4500,0];
private _destinationPosition = [5000,4500,0];
private _hqPosition = [5500,5500,0];
sidesX = [true] call A3A_fnc_createNamespace;
spawner = [true] call A3A_fnc_createNamespace;
garrison = [true] call A3A_fnc_createNamespace;
server = [true] call A3A_fnc_createNamespace;
respawnTeamPlayer = "a3i_adminextra_hq";
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
private _wait = {
    params ["_predicate",["_timeout",20]];
    private _deadline = diag_tickTime + _timeout;
    waitUntil {sleep 0.05; call _predicate || {diag_tickTime > _deadline}};
    call _predicate
};
A3A_hasACE = false; A3A_GCThreshold = 600;
GVAR(despawnQueue) = []; GVAR(despawnerRunning) = nil;
A3A_faction_reb = createHashMapFromArray [["diveGear",[]],["flyGear",[]]];
A3A_resourcesDefenceOcc = 100; A3A_resourcesAttackOcc = 100;
A3I_test_support = []; A3I_test_aggression = []; A3I_test_zones = []; A3I_test_observers = [];
A3I_interceptions = createHashMap; A3I_sites = createHashMap;
tierWar = 0; plusGarrison = true; distanceSPWN = 1000;
[2,2] call _setLimits;
private _role = "loadouts_occ_militia_Rifleman";
private _serial = 0;
private _newJob = {
    params [["_size",4]];
    _serial = _serial + 1;
    private _name = "adminextra_" + str _serial;
    private _roles = []; for "_i" from 1 to _size do {_roles pushBack _role};
    private _record = createHashMapFromArray [["name",_name],["serial",_serial],
        ["context","interception:" + _name],["size",_size],["roles",_roles],
        ["source",_source],["target",_destination],["spawnPosition",+_sourcePosition],
        ["destinationPosition",+_destinationPosition],["phase","preparing"],["retired",false],
        ["fault",""],["remaining",_size],["missing",0],["killed",0],["arrived",false],
        ["created",0],["units",[]],["groups",[]],["prepared",false],
        ["script",[] spawn {sleep 600}]];
    A3I_interceptions set [_name,_record];
    _record
};
private _cleanup = {
    params ["_record"];
    A3I_test_observers = [];
    [_record] call A3I_fnc_retireInterceptionFormation;
    terminate (_record get "script");
    [{scriptDone (_record get "script")},2] call _wait;
    {deleteVehicle _x} forEach (_record get "units");
    [_record get "groups"] call A3I_fnc_cleanupGroups;
    sleep 0.3;
    A3I_interceptions deleteAt (_record get "name");
};


garrisonIsChanging = false; distanceSPWN1 = 1000; A3I_siteSerial = 0;
private _startHorde = {
    private _job = [4] call _newJob;
    [_job] call A3I_fnc_prepareInterception;
    [_job] call A3I_fnc_releaseInterceptionFormation;
    _job set ["settled",true]; _job set ["outcome","arrived"]; _job set ["phase","arrived"];
    { _x setPosATL (_destinationPosition vectorAdd [40 + _forEachIndex * 2,0,0]) } forEach (_job get "units");
    _job
};
private _stopSite = {
    private _actors = +((A3I_sites get _destination) get "units");
    spawner setVariable [_destination,2,true];
    [{!(_destination in A3I_sites)},5] call _wait;
    {deleteVehicle _x} forEach _actors;
    sleep 0.5;
};

[24,24] call _setLimits;
private _building = createVehicle ["Land_i_Barracks_V1_F",_destinationPosition,[],0,"CAN_COLLIDE"];
_building setVariable ["A3A_milAdminMarker",_destination];
_destination setMarkerShape "ICON"; _destination setMarkerType "A3AU_miladmin_mrk";
milAdministrationsX = [_destination]; factories = []; markersX = [_source];
A3A_milAdministrations = [_building]; A3A_destroyedMilAdministrations = [];
townSkirmishes = []; destroyedSites = []; aggressionOccupants = -100;
A3I_test_realAdminCapture = true; A3I_test_originals = []; A3I_test_markerUpdates = [];
garrison setVariable [_destination + "_lootCD",1];
garrison setVariable [_destination,["unrelated_saved_entry"],true];
["aextra_icon_endpoint_enabled",_destination in (call A3I_fnc_interceptionLocations)
    && {!(_destination in markersX)}] call _check;
["aextra_fifty_metre_boundary",[_destinationPosition vectorAdd [49,0,0],_destination] call A3I_fnc_interceptionContains
    && {!([_destinationPosition vectorAdd [51,0,0],_destination] call A3I_fnc_interceptionContains)}
    && {[_destination] call A3I_fnc_interceptionRadius == 50}] call _check;
private _routes = [_destination,_source] call A3I_fnc_interceptionRoutes;
["aextra_route_to_native_icon",count _routes == 1
    && {[_routes # 0 # 2,_destination] call A3I_fnc_interceptionContains},_routes] call _check;

A3A_tasksData = []; A3A_activeTasks = []; A3A_taskCount = 0; theBoss = objNull;
killZones = [true] call A3A_fnc_createNamespace;
private _boundaryJob = call _startHorde;
_boundaryJob set ["settled",false]; _boundaryJob set ["outcome","pending"]; _boundaryJob set ["phase","marching"];
_boundaryJob set ["routeDistance",1000];
{_x disableAI "MOVE"; _x setPosATL (_destinationPosition vectorAdd [60 + _forEachIndex * 2,0,0])} forEach (_boundaryJob get "units");
["aextra_native_task_created",[_boundaryJob] call A3I_fnc_registerInterceptionTask] call _check;
["aextra_task_waits_outside_fifty_metres",[_boundaryJob] call A3I_fnc_interceptionTaskOutcome == "pending"] call _check;
((_boundaryJob get "units") # 0) setPosATL (_destinationPosition vectorAdd [49,0,0]);
[{_boundaryJob getOrDefault ["settled",false] && {
    (A3A_tasksData findIf {_x # 0 == _boundaryJob get "name" && {_x # 2 == "FAILED"}}) >= 0
}},5] call _wait;
["aextra_first_inside_fails_native_task",_boundaryJob get "outcome" == "arrived"
    && {(A3A_tasksData findIf {_x # 0 == _boundaryJob get "name" && {_x # 2 == "FAILED"}}) >= 0}] call _check;
_boundaryJob set ["taskDeleteAt",time - 1]; _boundaryJob set ["aftermathComplete",true];
[{isNil {A3I_interceptions get (_boundaryJob get "name")}},5] call _wait;
[_boundaryJob] call _cleanup;

private _record = call _startHorde;
private _group = (_record get "groups") # 0;
private _units = +(_record get "units");
(_units # 0) setPosATL (_destinationPosition vectorAdd [51,0,0]);
["aextra_storage_outside_boundary_refused",([_record,_group] call A3I_fnc_storeInterceptionArrivals) # 2 == "invalid_arrivals"] call _check;
(_units # 0) setPosATL (_destinationPosition vectorAdd [49,0,0]);
private _stored = [_record,_group] call A3I_fnc_storeInterceptionArrivals;
["aextra_offscreen_survivors_saved",_stored isEqualTo [true,4,"stored"]
    && {count ([_destination] call A3I_fnc_siteExtraRoster) == 4}] call _check;
[_record] call _cleanup;
spawner setVariable [_destination,0,true];
[_destination,"MilAdmin",false] call A3I_fnc_startSite;
private _site = A3I_sites get _destination;
private _baseline = (_site get "remainingDefenders") - (_site get "extraTarget");
["aextra_initial_queue_counts",_baseline >= 7 && {_baseline <= 11}
    && {_site get "extraTarget" == 4} && {_site get "remainingDefenders" == _baseline + 4}] call _check;
[{_site get "queue" isEqualTo [] && {_site get "extraQueue" isEqualTo []}},90] call _wait;
private _extras = (_site get "units") select {_x getVariable ["markerX",""] == _destination};
["aextra_baseline_and_extras_spawn",count _extras == 4
    && {count (_site get "units") == _baseline + 4}
    && {_site get "clearanceRemaining" == _baseline + 4}] call _check;
(_extras # 0) setDamage 1;
[{count ([_destination] call A3I_fnc_siteExtraRoster) == 3},5] call _wait;
["aextra_death_removes_saved_extra",count ([_destination] call A3I_fnc_siteExtraRoster) == 3
    && {_site get "remainingDefenders" == _baseline + 3}
    && {_site get "clearanceRemaining" == _baseline + 3}] call _check;
_record = call _startHorde; _group = (_record get "groups") # 0; _units = +(_record get "units");
private _adopted = [_record,_group] call A3I_fnc_adoptInterceptionArrivals;
["aextra_live_arrivals_adopted",_adopted isEqualTo [true,4,"adopted"]
    && {count ([_destination] call A3I_fnc_siteExtraRoster) == 7}
    && {_site get "remainingDefenders" == _baseline + 7}
    && {_site get "clearanceRemaining" == _baseline + 7},[_adopted]] call _check;
// An unfit live deletion is a missing actor, not a real kill. The administration
// replaces it, retaining both the saved role and the original clearance count.
private _deleted = _units # 0;
_deleted setVariable ["incapacitated",true];
["aextra_unfit_deletion_precondition",!(_deleted call A3A_fnc_canFight)] call _check;
private _beforeReplacement = +(_site get "units");
deleteVehicle _deleted;
[{count (_site get "extraQueue") > 0},3] call _wait;
["aextra_live_deletion_keeps_saved_role",count ([_destination] call A3I_fnc_siteExtraRoster) == 7
    && {_site get "remainingDefenders" == _baseline + 7}
    && {_site get "clearanceRemaining" == _baseline + 7}
    && {_site get "clearanceMissing" == 0}] call _check;
[{_site get "extraQueue" isEqualTo [] && {((_site get "units") - _beforeReplacement) isNotEqualTo []}},20] call _wait;
private _replacement = (_site get "units") - _beforeReplacement;
["aextra_deleted_extra_replaced_as_extra",count _replacement == 1
    && {(_replacement # 0) getVariable ["markerX",""] == _destination}
    && {(_replacement # 0) getVariable ["A3A_resPool",""] == "garrison"}
    && {count ([_destination] call A3I_fnc_siteExtraRoster) == 7}] call _check;
[_record] call _cleanup;
["aextra_old_owner_cleanup_safe",{alive _x} count _units == 3
    && {alive (_replacement # 0)}] call _check;
private _plugins = createHashMapFromArray [["other_plugin",["unchanged"]]];
[CBA_EVENT_SERVER_GAME_SAVE,[_plugins]] call A3A_fnc_triggerLocalEvent;
["aextra_native_save_event_serializes",_plugins getOrDefault ["other_plugin",[]] isEqualTo ["unchanged"]
    && {(_plugins getOrDefault ["A3I_administrationExtras",[]]) isEqualTo [1,[[_destination,[_destination] call A3I_fnc_siteExtraRoster]]]}] call _check;
private _oldSaveHandle = A3I_adminSaveHandle;
["aextra_hooks_registered_once",!call A3I_fnc_registerPersistence && {A3I_adminSaveHandle == _oldSaveHandle}] call _check;
call _stopSite;
["aextra_healthy_despawn_preserves_extras",count ([_destination] call A3I_fnc_siteExtraRoster) == 7] call _check;
garrison setVariable [_destination,["unrelated_saved_entry"],true];
[CBA_EVENT_SERVER_GAME_LOAD,[_plugins]] call A3A_fnc_triggerLocalEvent;
[CBA_EVENT_SERVER_GAME_LOAD,[_plugins]] call A3A_fnc_triggerLocalEvent;
["aextra_native_load_restores_without_duplicates",count ([_destination] call A3I_fnc_siteExtraRoster) == 7
    && {count (garrison getVariable _destination) == 8}
    && {"unrelated_saved_entry" in (garrison getVariable _destination)}] call _check;
private _bad = createHashMapFromArray [["A3I_administrationExtras",[1,[[_destination,["bad_role"]]]]]];
["aextra_malformed_load_preserves_roster",!([_bad] call A3I_fnc_loadAdministrationExtras)
    && {count ([_destination] call A3I_fnc_siteExtraRoster) == 7}] call _check;
A3I_dependencies set ["available",false];
private _inactiveSave = createHashMap;
[CBA_EVENT_SERVER_GAME_SAVE,[_inactiveSave]] call A3A_fnc_triggerLocalEvent;
["aextra_inactive_save_untouched",count _inactiveSave == 0] call _check;
A3I_dependencies set ["available",true];
spawner setVariable [_destination,0,true];
[_destination,"MilAdmin",false] call A3I_fnc_startSite;
_site = A3I_sites get _destination;
_baseline = (_site get "remainingDefenders") - (_site get "extraTarget");
[{_site get "queue" isEqualTo [] && {_site get "extraQueue" isEqualTo []}},90] call _wait;
_extras = (_site get "units") select {_x getVariable ["markerX",""] == _destination};
private _ordinary = (_site get "units") - _extras;
["aextra_revisit_regenerates_only_baseline",count _extras == 7 && {count _ordinary == _baseline}
    && {_baseline >= 7} && {_baseline <= 11}] call _check;
{_x setDamage 1} forEach _ordinary;
[{_site get "remainingDefenders" == 7},5] call _wait;
private _beforeDestruction = entities [[],[],true,false];
_building setDamage 1;
[_building,"DESTROY"] call SCRT_fnc_location_removeMilAdmin;
sleep 0.5;
private _ruins = ((entities [[],[],true,false]) - _beforeDestruction) select {_x isKindOf "Ruins_F"};
["aextra_ruin_still_requires_extras",sidesX getVariable _destination == west
    && {!([_destination] call A3I_fnc_tryCaptureAdministration)}
    && {!(([_destination] call A3I_fnc_siteClearance) # 0)}] call _check;
{_x setDamage 1} forEach _extras;
[{sidesX getVariable _destination == teamPlayer},5] call _wait;
["aextra_cleared_extras_allow_capture",sidesX getVariable _destination == teamPlayer
    && {_building in A3A_destroyedMilAdministrations}
    && {_site get "remainingDefenders" == 0}
    && {(garrison getVariable _destination) isEqualTo ["unrelated_saved_entry"]}] call _check;
[CBA_EVENT_SERVER_GAME_LOAD,[_plugins]] call A3A_fnc_triggerLocalEvent;
["aextra_load_does_not_restore_enemy_on_rebel_site",garrison getVariable _destination isEqualTo ["unrelated_saved_entry"]] call _check;
call _stopSite;
deleteVehicle _building; {deleteVehicle _x} forEach _ruins;
A3I_test_realAdminCapture = false; A3I_test_observers = nil; A3I_interceptions = nil;
{deleteVehicle _x} forEach [sidesX,spawner,garrison,server,killZones];
{deleteMarker _x} forEach _markers;
[_savedCap,_savedContext] call _setLimits;
sleep 3;
["aextra_complete_cleanup",(call _stats) select [1,3] isEqualTo [0,0,0]
    && {(entities [[],[],true,false]) - _before isEqualTo []}
    && {allGroups - _groupsBefore isEqualTo []} && {count A3I_sites == 0}
    && {isNil "A3I_siteWatchdogHandle"} && {A3A_tasksData isEqualTo []},
    [call _stats,count ((entities [[],[],true,false]) - _before),count (allGroups - _groupsBefore)]] call _check;
