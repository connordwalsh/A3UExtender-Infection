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
private _source = "a3i_iform_source";
private _destination = "a3i_iform_destination";
private _town = "a3i_iform_budgettown";
private _sourcePosition = [4000,4500,0];
private _destinationPosition = [5000,4500,0];
private _hqPosition = [5500,5500,0];
sidesX = [true] call A3A_fnc_createNamespace;
spawner = [true] call A3A_fnc_createNamespace;
garrison = [true] call A3A_fnc_createNamespace;
server = [true] call A3A_fnc_createNamespace;
respawnTeamPlayer = "a3i_iform_hq";
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
    private _name = "formation_" + str _serial;
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
private _launch = {
    params ["_record"];
    terminate (_record get "script");
    isNil {
        _record set ["script",[_record] spawn {
            params ["_record"];
            _record set ["preparationResult",[_record] call A3I_fnc_prepareInterception];
            sleep 600;
        }];
    };
};
private _record = [40] call _newJob;
[_record] call _launch;
private _partial = [{_record get "created" > 0},5] call _wait;
["iform_partial_members_hidden",_partial && {_record get "created" < 40}
    && {((_record get "units") findIf {!isObjectHidden _x || {simulationEnabled _x}}) == -1}] call _check;
["iform_incomplete_release_refused",!([_record] call A3I_fnc_releaseInterceptionFormation)
    && {_record get "phase" == "preparing"}] call _check;
["iform_duplicate_preparation_refused",!([_record] call A3I_fnc_prepareInterception)] call _check;
private _prepared = [{!isNil {_record get "preparationResult"}},25] call _wait;
["iform_complete_hidden_roster",_prepared && {_record get "preparationResult"}
    && {_record get "created" == 40} && {_record get "remaining" == 40}
    && {count (_record get "units") == 40} && {count (_record get "groups") == 4}
    && {((_record get "units") findIf {!isObjectHidden _x || {simulationEnabled _x}
        || {_x getVariable ["A3I_interceptionSerial",-1] != _record get "serial"}}) == -1},
    [_record get "created",_record get "fault",_record getOrDefault ["lastPreparation",""]]] call _check;
private _released = [_record] call A3I_fnc_releaseInterceptionFormation;
["iform_complete_release_visible",_released && {_record get "phase" == "marching"}
    && {((_record get "units") findIf {isObjectHidden _x || {!simulationEnabled _x}
        || {!(_x getVariable ["spawner",false])}}) == -1}] call _check;
["iform_destination_waypoints",((_record get "groups") findIf {
    private _wps = waypoints _x;
    _wps isEqualTo [] || {(_wps findIf {waypointType _x == "MOVE" && {waypointPosition _x distance2D _destinationPosition < 1}}) == -1}
}) == -1] call _check;
["iform_second_release_refused",!([_record] call A3I_fnc_releaseInterceptionFormation)] call _check;
private _leaders = (_record get "groups") apply {leader _x};
private _initialDistances = _leaders apply {_x distance2D _destinationPosition};
private _progress = {
    private _result = [];
    {_result pushBack ((_initialDistances # _forEachIndex) - (_x distance2D _destinationPosition))} forEach _leaders;
    _result
};
private _moved = [{((call _progress) findIf {!finite _x || {_x < 10}}) == -1},45] call _wait;
["iform_actual_march",_moved,call _progress] call _check;
private _members = +(_record get "units");
(_members # 0) setDamage 1; sleep 0.2;
["iform_real_death_counts_once",_record get "remaining" == 39 && {_record get "killed" == 1}
    && {!(_record get "arrived")}] call _check;
deleteVehicle (_members # 0); sleep 0.1;
["iform_dead_body_deletion_not_second_kill",_record get "remaining" == 39 && {_record get "missing" == 0}] call _check;
["Killed",_members # 1] call A3I_fnc_interceptionMemberEvent;
["iform_fake_death_event_refused",_record get "remaining" == 39 && {_record get "killed" == 1}] call _check;
deleteVehicle (_members # 1); sleep 0.1;
["iform_live_deletion_keeps_obligation",_record get "remaining" == 39 && {_record get "missing" == 1}
    && {_record get "fault" == "missing_member"}] call _check;
[_record] call _cleanup;

_record = [] call _newJob;
private _unscheduled = true; isNil {_unscheduled = [_record] call A3I_fnc_prepareInterception};
["iform_unscheduled_preparation_refused",!_unscheduled && {_record get "created" == 0}] call _check;
[createHashMap] remoteExecCall ["A3I_fnc_prepareInterception",2];
[createHashMap] remoteExecCall ["A3I_fnc_releaseInterceptionFormation",2];
[createHashMap] remoteExecCall ["A3I_fnc_retireInterceptionFormation",2];
sleep 0.2;
["iform_remote_internal_calls_refused",_record get "phase" == "preparing" && {_record get "created" == 0}] call _check;
sidesX setVariable [_source,east];
["iform_lost_source_preparation_refused",!([_record] call A3I_fnc_prepareInterception)
    && {_record get "created" == 0}] call _check;
sidesX setVariable [_source,west];
_record set ["roles",[_role]];
["iform_short_roster_refused",!([_record] call A3I_fnc_prepareInterception)
    && {_record get "fault" == "invalid_roster"}] call _check;
[_record] call _cleanup;

_record = [] call _newJob; _record set ["roles",["invalid","invalid","invalid","invalid"]];
["iform_invalid_role_rolls_back",!([_record] call A3I_fnc_prepareInterception)
    && {_record get "retired"} && {_record get "created" == 0}
    && {(call _stats) select [1,3] isEqualTo [0,0,0]}] call _check;
[_record] call _cleanup;

_record = [] call _newJob; [_record] call A3I_fnc_prepareInterception;
sidesX setVariable [_destination,east];
["iform_destination_changes_before_release",!([_record] call A3I_fnc_releaseInterceptionFormation)
    && {_record get "phase" == "preparing"}] call _check;
sidesX setVariable [_destination,west];
_source setMarkerPos [4500,4500,0];
["iform_source_moves_before_release",!([_record] call A3I_fnc_releaseInterceptionFormation)] call _check;
_source setMarkerPos _sourcePosition;
private _first = (_record get "units") # 0;
_first setPosATL _destinationPosition;
["iform_member_inside_destination_cannot_depart",!([_record] call A3I_fnc_releaseInterceptionFormation)] call _check;
_first setPosATL _sourcePosition;
private _firstGroup = (_record get "groups") # 0;
_firstGroup setVariable ["A3I_context","foreign"];
["iform_changed_group_context_refused",!([_record] call A3I_fnc_releaseInterceptionFormation)] call _check;
_firstGroup setVariable ["A3I_context",_record get "context"];
private _observerGroup = createGroup civilian;
private _observer = _observerGroup createUnit ["C_man_1",_sourcePosition getPos [100,180],[],0,"NONE"];
_observer allowDamage false;
A3I_test_observers = [_observer];
["iform_hidden_cleanup_with_observer",[_record] call A3I_fnc_retireInterceptionFormation
    && {_record get "retired"} && {_record get "missing" == 0}] call _check;
A3I_test_observers = []; deleteVehicle _observer; sleep 0.1; deleteGroup _observerGroup;
[_record] call _cleanup;

_record = [] call _newJob; [_record] call A3I_fnc_prepareInterception;
((_record get "units") # 0) setDamage 1; sleep 0.1;
["iform_preparation_casualty_blocks_departure",_record get "remaining" == 3
    && {_record get "fault" == "preparation_casualty"}
    && {!([_record] call A3I_fnc_releaseInterceptionFormation)}] call _check;
[_record] call _cleanup;

_record = [] call _newJob; [_record] call A3I_fnc_prepareInterception;
[_record] call A3I_fnc_releaseInterceptionFormation;
private _arrival = (_record get "units") # 0;
_arrival setPosATL _destinationPosition; _arrival setDamage 1; sleep 0.1;
["iform_killed_first_arrival_is_retained",_record get "arrived" && {_record get "remaining" == 3}] call _check;
{if (alive _x) then {_x setDamage 1}} forEach (_record get "units"); sleep 0.1;
["iform_arrival_survives_whole_horde_death",_record get "arrived" && {_record get "remaining" == 0}] call _check;
[_record] call _cleanup;

_record = [] call _newJob; [_record] call A3I_fnc_prepareInterception;
[_record] call A3I_fnc_releaseInterceptionFormation;
private _body = (_record get "units") # 0;
_body setDamage 1; sleep 0.1; _body setPosATL _destinationPosition;
["iform_dead_body_movement_not_arrival",!(_record get "arrived") && {_record get "remaining" == 3}] call _check;
sidesX setVariable [_destination,east];
["iform_russian_takeover_after_departure_preserves_formation",_record get "phase" == "marching"
    && {_record get "remaining" == 3} && {!(_record get "retired")}] call _check;
sidesX setVariable [_destination,west];
_observerGroup = createGroup civilian;
_observer = _observerGroup createUnit ["C_man_1",_sourcePosition getPos [100,180],[],0,"NONE"];
_observer allowDamage false; A3I_test_observers = [_observer];
["iform_visible_cleanup_waits_for_observer",!([_record] call A3I_fnc_retireInterceptionFormation)
    && {!(_record get "retired")} && {{alive _x} count (_record get "units") == 3}] call _check;
A3I_test_observers = []; deleteVehicle _observer; sleep 0.1; deleteGroup _observerGroup;
["iform_visible_cleanup_after_observer_leaves",[_record] call A3I_fnc_retireInterceptionFormation
    && {_record get "retired"}] call _check;
[_record] call _cleanup;

_record = [] call _newJob; [_record] call A3I_fnc_prepareInterception;
private _replacement = createHashMapFromArray [["serial",(_record get "serial") + 1],["retired",false],
    ["phase","preparing"],["remaining",99],["missing",0]];
A3I_interceptions set [_record get "name",_replacement];
((_record get "units") # 0) setDamage 1; sleep 0.1;
["iform_stale_member_cannot_change_new_job",_replacement get "remaining" == 99 && {_replacement get "missing" == 0}
    && {!([_record] call A3I_fnc_retireInterceptionFormation)}] call _check;
A3I_interceptions set [_record get "name",_record];
[_record] call _cleanup;

_record = [40] call _newJob; [_record] call _launch;
[{_record get "created" > 0},5] call _wait;
terminate (_record get "script");
[{scriptDone (_record get "script")},2] call _wait;
private _countBeforeCleanup = _record get "created";
private _retired = [_record] call A3I_fnc_retireInterceptionFormation;
sleep 0.1;
["iform_stopped_creation_reclaims_partial_group",_countBeforeCleanup > 0 && {_countBeforeCleanup < 40}
    && {_retired} && {_record get "retired"} && {(call _stats) select [1,3] isEqualTo [0,0,0]},
    [_countBeforeCleanup,call _stats]] call _check;
[_record] call _cleanup;

private _beforeRefund = A3A_resourcesAttackOcc;
private _hookReject = ["iform-reject",[_role],_sourcePosition,0,100,"","attack",1,false,{true},true,"",{false}]
    call A3I_fnc_spawnGroup;
sleep 0.3;
["iform_failed_hook_refunds_paid_spawn_once",!(_hookReject # 0) && {_hookReject # 2 == "initialization_failed"}
    && {A3A_resourcesAttackOcc == _beforeRefund}
    && {(call _stats) select [1,3] isEqualTo [0,0,0]},[_hookReject # 0,_hookReject # 2,A3A_resourcesAttackOcc]] call _check;
private _hookNil = ["iform-nil",[_role],_sourcePosition,0,100,"","legacy",1,false,{true},false,"",{nil}]
    call A3I_fnc_spawnGroup;
["iform_missing_hook_result_refused",!(_hookNil # 0) && {_hookNil # 2 == "initialization_failed"}
    && {(call _stats) select [1,3] isEqualTo [0,0,0]}] call _check;
_record = [120] call _newJob;
private _maxPrepared = [_record] call A3I_fnc_prepareInterception;
["iform_maximum_complete_roster",_maxPrepared && {_record get "created" == 120}
    && {count (_record get "units") == 120} && {count (_record get "groups") == 10}
    && {((_record get "units") findIf {!isObjectHidden _x || {simulationEnabled _x}}) == -1},
    [_record get "created",_record get "fault"]] call _check;
["iform_maximum_complete_release",[_record] call A3I_fnc_releaseInterceptionFormation
    && {((_record get "units") findIf {isObjectHidden _x || {!simulationEnabled _x}}) == -1}] call _check;
[_record] call _cleanup;
A3I_test_observers = nil; A3I_interceptions = nil;
{deleteVehicle _x} forEach [sidesX,spawner,garrison,server];
{deleteMarker _x} forEach _markers;
[_savedCap,_savedContext] call _setLimits;
sleep 1;
["iform_complete_cleanup",(call _stats) select [1,3] isEqualTo [0,0,0]
    && {(entities [[],[],true,false]) - _before isEqualTo []}
    && {allGroups - _groupsBefore isEqualTo []}] call _check;
