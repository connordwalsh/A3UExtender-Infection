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
private _source = "a3i_iadopt_source";
private _destination = "a3i_iadopt_destination";
private _town = "a3i_iadopt_budgettown";
private _sourcePosition = [4000,4500,0];
private _destinationPosition = [5000,4500,0];
private _hqPosition = [5500,5500,0];
sidesX = [true] call A3A_fnc_createNamespace;
spawner = [true] call A3A_fnc_createNamespace;
garrison = [true] call A3A_fnc_createNamespace;
server = [true] call A3A_fnc_createNamespace;
respawnTeamPlayer = "a3i_iadopt_hq";
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
    private _name = "adoption_" + str _serial;
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
    { _x setPosATL (_destinationPosition vectorAdd [_forEachIndex * 3,0,0]) } forEach (_job get "units");
    _job
};
private _stopSite = {
    private _actors = +((A3I_sites get _destination) get "units");
    spawner setVariable [_destination,2,true];
    [{!(_destination in A3I_sites)},5] call _wait;
    {deleteVehicle _x} forEach _actors;
    sleep 0.5;
};
private _record = call _startHorde;
private _group = (_record get "groups") # 0;
private _units = +(_record get "units");
private _ticket = (_units # 0) getVariable "A3I_budgetTicket";
private _invoke = {[_record,_group] call A3I_fnc_adoptInterceptionArrivals};
["iadopt_no_site_denied",(call _invoke) # 2 == "site_unavailable"] call _check;
private _roster = []; for "_i" from 1 to 8 do {_roster pushBack _role};
garrison setVariable [_destination,_roster,true];
spawner setVariable [_destination,0,true];
[_destination,"Resource",false] call A3I_fnc_startSite;
private _site = A3I_sites get _destination;
[{count (_site get "units") == 2 && {count (_site get "queue") == 6}},10] call _wait;
["iadopt_original_shared_limit_full",count (_site get "units") == 2 && {count (_site get "queue") == 6}] call _check;
private _initial = +(_site get "units");
private _siteId = _site get "id";
private _stale = createHashMapFromArray [["name",_record get "name"],["serial",-1]];
["iadopt_stale_job_denied",([_stale,_group] call A3I_fnc_adoptInterceptionArrivals) # 2 == "inactive_job"] call _check;
sidesX setVariable [_destination,east];
["iadopt_hostile_site_denied",(call _invoke) # 2 == "inactive_destination"] call _check;
sidesX setVariable [_destination,west];
spawner setVariable [_destination,1];
["iadopt_suspended_site_denied",(call _invoke) # 2 == "site_unavailable"] call _check;
spawner setVariable [_destination,0];
garrisonIsChanging = true;
["iadopt_busy_garrison_denied",(call _invoke) # 2 == "garrison_busy"] call _check;
garrisonIsChanging = false;
_site set ["fault","fixture"];
["iadopt_faulted_site_denied",(call _invoke) # 2 == "site_unavailable"] call _check;
_site set ["fault",""];
(_units # 0) setPosATL _sourcePosition;
["iadopt_partial_arrival_denied",(call _invoke) # 2 == "invalid_arrivals"] call _check;
(_units # 0) setPosATL _destinationPosition;
["iadopt_stale_site_budget_denied",(["handoff",[_ticket,_record get "name",_record get "serial",_destination,_siteId + 1]] call A3I_fnc_budget) # 2 == "invalid_arrival_site"] call _check;
["iadopt_refusals_preserve_state",count (_site get "units") == 2 && {count (_site get "queue") == 6}
    && {count (garrison getVariable _destination) == 8} && {count (_record get "units") == 4}] call _check;
private _funds = [A3A_resourcesAttackOcc,A3A_resourcesDefenceOcc];
private _adopted = call _invoke;
private _arrivalContext = (A3I_budgetRecords get _ticket) # 0;
["iadopt_permanent_accepts_full_site",_adopted isEqualTo [true,4,"adopted"]
    && {count (_site get "units") == 6} && {count (garrison getVariable _destination) == 12}
    && {count (_site get "queue") == 6} && {_site get "clearanceRemaining" == 12},[_adopted,call _stats]] call _check;
["iadopt_physical_units_preserved",{alive _x && {simulationEnabled _x} && {!isObjectHidden _x}} count _units == 4
    && {(_units findIf {_x getVariable ["markerX",""] != _destination
        || {_x getVariable ["A3A_resPool",""] != "garrison"}
        || {!(_x getVariable ["A3I_clearanceTracked",false])}}) == -1}] call _check;
["iadopt_reserved_context_cannot_spawn",_arrivalContext find "arrival:" == 0
    && {(["reserve",[_arrivalContext,1,24]] call A3I_fnc_budget) # 2 == "arrival_closed"}] call _check;
["iadopt_duplicate_rejected",(call _invoke) # 2 == "already_adopted"
    && {count (garrison getVariable _destination) == 12}] call _check;
[_record] call _cleanup;
["iadopt_old_horde_cleanup_preserves_arrivals",{alive _x} count _units == 4
    && {!isNil {A3I_budgetRecords get _ticket}} && {_group in (_site get "groups")}
    && {[A3A_resourcesAttackOcc,A3A_resourcesDefenceOcc] isEqualTo _funds}] call _check;
{_x setDamage 1} forEach _initial;
[{count ((_site get "units") select {alive _x && {!(_x in _units)}}) == 2},20] call _wait;
["iadopt_shared_queue_continues",count ((_site get "units") select {alive _x && {!(_x in _units)}}) == 2
    && {count (_site get "queue") == 4} && {{alive _x} count _units == 4}] call _check;
(_units # 0) setDamage 1;
[{count (garrison getVariable _destination) == 9},5] call _wait;
["iadopt_death_updates_site_once",count (garrison getVariable _destination) == 9
    && {_site get "clearanceRemaining" == 9} && {_record get "killed" == 0}
    && {!(([_destination] call A3I_fnc_siteClearance) # 0)}] call _check;
call _stopSite;
["iadopt_despawn_preserves_surviving_roster",count (garrison getVariable _destination) == 9
    && {(call _stats) select [1,3] isEqualTo [0,0,0]}] call _check;

// Adopt while the town's original reservation is still filling. It must keep
// its remaining slots and never spawn a second copy of the arriving group.
citiesX pushBack _destination; factories = [];
_destination setMarkerSize [300,300];
A3A_townData = createHashMapFromArray [[_destination,[100,2,60,40]]];
townSkirmishes = []; destroyedSites = [];
garrison setVariable [_destination,[],true];
_record = call _startHorde; _group = (_record get "groups") # 0;
_units = +(_record get "units");
spawner setVariable [_destination,0,true];
[_destination,"City",false] call A3I_fnc_startSite;
_site = A3I_sites get _destination;
[{count (_site get "units") > 0 && {count (_site get "queue") > 0}},5] call _wait;
private _oldTarget = _site get "populationTarget";
_adopted = call _invoke;
["iadopt_city_accepts_during_initial_queue",_adopted isEqualTo [true,4,"adopted"]
    && {_oldTarget == 85} && {_site get "populationTarget" == 89}
    && {_site get "extraTarget" == 4} && {count (_site get "queue") > 0}] call _check;
[{_site get "queue" isEqualTo [] && {count (_site get "units") == 89}},30] call _wait;
["iadopt_city_completes_original_population",count (_site get "units") == 89
    && {_site get "queue" isEqualTo []} && {_site get "extraQueue" isEqualTo []}
    && {_site get "clearanceRemaining" == 89}
    && {count ([_destination] call A3I_fnc_siteExtraRoster) == 4},[count (_site get "units"),count (_site get "queue"),call _stats]] call _check;
private _job2 = call _startHorde;
private _group2 = (_job2 get "groups") # 0;
private _units2 = +(_job2 get "units");
private _adopted2 = [_job2,_group2] call A3I_fnc_adoptInterceptionArrivals;
["iadopt_city_second_group_adds_once",_adopted2 isEqualTo [true,4,"adopted"]
    && {_site get "populationTarget" == 93} && {_site get "extraTarget" == 8}
    && {count (_site get "units") == 93} && {count ([_destination] call A3I_fnc_siteExtraRoster) == 8}] call _check;
[_record] call _cleanup; [_job2] call _cleanup;
["iadopt_city_survives_both_owner_cleanups",{alive _x} count (_units + _units2) == 8
    && {(call _stats) # 1 == 93}] call _check;
private _ordinary = (_site get "units") - _units - _units2;
{_x setDamage 1} forEach _ordinary;
[{_site get "clearanceRemaining" == 8},10] call _wait;
["iadopt_city_arrivals_block_clearance",_site get "clearanceRemaining" == 8
    && {!(([_destination] call A3I_fnc_siteClearance) # 0)}] call _check;
{_x setDamage 1} forEach (_units + _units2);
[{([_destination] call A3I_fnc_siteClearance) # 0},10] call _wait;
["iadopt_city_clearance_after_extras_die",([_destination] call A3I_fnc_siteClearance) # 0
    && {[_destination] call A3I_fnc_siteExtraRoster isEqualTo []}] call _check;
call _stopSite;
A3I_test_observers = nil; A3I_interceptions = nil;
{deleteVehicle _x} forEach [sidesX,spawner,garrison,server];
{deleteMarker _x} forEach _markers;
[_savedCap,_savedContext] call _setLimits;
sleep 3;
["iadopt_complete_cleanup",(call _stats) select [1,3] isEqualTo [0,0,0]
    && {(entities [[],[],true,false]) - _before isEqualTo []}
    && {allGroups - _groupsBefore isEqualTo []} && {count A3I_sites == 0}
    && {isNil "A3I_siteWatchdogHandle"},
    [call _stats,count ((entities [[],[],true,false]) - _before),count (allGroups - _groupsBefore)]] call _check;
