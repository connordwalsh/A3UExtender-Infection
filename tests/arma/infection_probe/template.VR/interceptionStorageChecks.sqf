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
private _source = "a3i_istore_source";
private _destination = "a3i_istore_destination";
private _town = "a3i_istore_budgettown";
private _sourcePosition = [4000,4500,0];
private _destinationPosition = [5000,4500,0];
private _hqPosition = [5500,5500,0];
sidesX = [true] call A3A_fnc_createNamespace;
spawner = [true] call A3A_fnc_createNamespace;
garrison = [true] call A3A_fnc_createNamespace;
server = [true] call A3A_fnc_createNamespace;
respawnTeamPlayer = "a3i_istore_hq";
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
    private _name = "storage_" + str _serial;
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

private _record = [4] call _newJob;
private _prepared = [_record] call A3I_fnc_prepareInterception;
private _group = (_record get "groups") # 0;
["istore_prepared",_prepared && {count units _group == 4}] call _check;
["istore_unsettled_denied",!(([_record,_group] call A3I_fnc_storeInterceptionArrivals) # 0)] call _check;
[_record] call A3I_fnc_releaseInterceptionFormation;
_record set ["settled",true]; _record set ["outcome","arrived"]; _record set ["phase","arrived"];
["istore_outside_denied",([_record,_group] call A3I_fnc_storeInterceptionArrivals) # 2 == "invalid_arrivals"] call _check;
{_x setPosATL (_destinationPosition vectorAdd [_forEachIndex * 3,0,0]); doStop _x} forEach units _group;
private _units = +units _group;
private _ticket = (_units # 0) getVariable "A3I_budgetTicket";
private _binding = A3I_budgetRecords get _ticket;
private _invoke = {[_record,_group] call A3I_fnc_storeInterceptionArrivals};
private _roster = []; for "_i" from 1 to 100 do {_roster pushBack _role};
garrison setVariable [_destination,+_roster];
private _fundsBefore = [A3A_resourcesDefenceOcc,A3A_resourcesAttackOcc];
private _stale = createHashMapFromArray [["name",_record get "name"],["serial",-1]];
["istore_stale_owner_denied",([_stale,_group] call A3I_fnc_storeInterceptionArrivals) # 2 == "inactive_job"] call _check;
sidesX setVariable [_destination,east];
["istore_hostile_destination_denied",(call _invoke) # 2 == "inactive_destination"] call _check;
sidesX setVariable [_destination,west];
spawner setVariable [_destination,0];
["istore_active_destination_denied",(call _invoke) # 2 == "destination_live_or_unsupported"] call _check;
spawner setVariable [_destination,2];
A3I_sites set [_destination,createHashMapFromArray [["id",99],["cleaned",false]]];
["istore_live_owner_denied",(call _invoke) # 2 == "destination_live_or_unsupported"] call _check;
A3I_sites deleteAt _destination;
garrisonIsChanging = true;
["istore_busy_garrison_denied",(call _invoke) # 2 == "garrison_busy"] call _check;
garrisonIsChanging = false;
private _observerGroup = createGroup civilian;
private _observer = _observerGroup createUnit ["C_man_1",_destinationPosition,[],0,"NONE"];
A3I_test_observers = [_observer];
["istore_observed_denied",(call _invoke) # 2 == "observed"] call _check;
A3I_test_observers = []; deleteVehicle _observer; deleteGroup _observerGroup;
(_units # 0) hideObjectGlobal true;
["istore_hidden_member_denied",(call _invoke) # 2 == "invalid_arrivals"] call _check;
(_units # 0) hideObjectGlobal false;
(_units # 0) setVariable ["unitType","unknown_role"];
["istore_unregistered_role_denied",(call _invoke) # 2 == "invalid_arrivals"] call _check;
(_units # 0) setVariable ["unitType",_role];
_binding set [4,false];
["istore_open_ticket_denied",(call _invoke) # 2 == "invalid_ticket"] call _check;
_binding set [4,true];
_binding set [0,"foreign"];
["istore_foreign_ticket_denied",(call _invoke) # 2 == "invalid_ticket"] call _check;
_binding set [0,_record get "context"];
["istore_refusals_leave_force_unchanged",garrison getVariable [_destination,[]] isEqualTo _roster
    && {{alive _x} count _units == 4} && {_record getOrDefault ["storedArrivals",0] == 0}
    && {(call _stats) select [1,3] isEqualTo [4,0,1]}] call _check;
private _stored = call _invoke;
["istore_permanent_adds_above_capacity",_stored isEqualTo [true,4,"stored"]
    && {count (garrison getVariable [_destination,[]]) == 104},[_stored,count (garrison getVariable [_destination,[]])]] call _check;
[{(_units findIf {!isNull _x}) == -1},3] call _wait;
["istore_removes_only_stored_actors",(_units findIf {!isNull _x}) == -1
    && {_record get "units" isEqualTo []} && {_record get "groups" isEqualTo []}
    && {_record get "storedArrivals" == 4} && {_record get "missing" == 0}
    && {_record get "fault" == ""} && {(call _stats) select [1,3] isEqualTo [0,0,0]}] call _check;
sleep 0.3;
["istore_no_resource_refund_or_charge",[A3A_resourcesDefenceOcc,A3A_resourcesAttackOcc] isEqualTo _fundsBefore] call _check;
["istore_retry_no_duplicate",!((call _invoke) # 0) && {count (garrison getVariable [_destination,[]]) == 104}] call _check;
[_record] call _cleanup;
["istore_owner_retirement_preserves_saved_roster",count (garrison getVariable [_destination,[]]) == 104] call _check;

// Real casualty before arrival: only surviving members become town additions.
citiesX pushBack _destination; factories = [];
garrison setVariable [_destination,[_role]];
_record = [4] call _newJob;
[_record] call A3I_fnc_prepareInterception;
[_record] call A3I_fnc_releaseInterceptionFormation;
_group = (_record get "groups") # 0;
_units = +units _group;
(_units # 0) setDamage 1;
[{!alive (_units # 0) && {_record get "killed" == 1}},3] call _wait;
_record set ["settled",true]; _record set ["outcome","arrived"]; _record set ["phase","arrived"];
{if (alive _x) then {_x setPosATL (_destinationPosition vectorAdd [_forEachIndex * 3,0,0]); doStop _x}} forEach _units;
private _corpse = _units # 0;
_stored = call _invoke;
["istore_town_only_survivors_persist",_stored isEqualTo [true,3,"stored"]
    && {count ([_destination] call A3I_fnc_siteExtraRoster) == 4}
    && {_record get "killed" == 1} && {_record get "missing" == 0},[_stored,_record get "killed"]] call _check;
["istore_native_corpse_retained",!isNull _corpse && {!alive _corpse}
    && {_corpse in (_record get "units")}] call _check;
[_record] call _cleanup;
["istore_town_saved_after_owner_cleanup",count ([_destination] call A3I_fnc_siteExtraRoster) == 4] call _check;

A3I_test_observers = nil; A3I_interceptions = nil;
{deleteVehicle _x} forEach [sidesX,spawner,garrison,server];
{deleteMarker _x} forEach _markers;
[_savedCap,_savedContext] call _setLimits;
sleep 1;
["istore_complete_cleanup",(call _stats) select [1,3] isEqualTo [0,0,0]
    && {(entities [[],[],true,false]) - _before isEqualTo []}
    && {allGroups - _groupsBefore isEqualTo []},
    [call _stats,count ((entities [[],[],true,false]) - _before),count (allGroups - _groupsBefore)]] call _check;
