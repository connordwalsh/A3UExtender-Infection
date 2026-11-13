// Idempotent cleanup, also used when a stopped controller is reclaimed on reentry.
#include "\x\a3a\addons\core\script_component.hpp"
params ["_marker","_record"];
if (!isServer || {isRemoteExecuted && {remoteExecutedOwner != 2}}
    || {_record getOrDefault ["cleaned",false]}) exitWith {};
if (canSuspend) exitWith {[A3I_fnc_cleanupSite,_this] call CBA_fnc_directCall};
_record set ["cleaned",true];
private _context = _record get "context";
// Find every ticket by context, including a partially-created group whose script
// stopped before returning its result to the site controller.
if (!isNil "A3I_budgetRecords") then {
    private _tickets = (keys A3I_budgetRecords) select {(A3I_budgetRecords get _x) # 0 == _context};
    {["cancel",[_x]] call A3I_fnc_budget} forEach _tickets;
};
{if (alive _x) then {deleteVehicle _x}} forEach (_record get "units");
{deleteVehicle _x} forEach (_record get "civilians");
private _groups = +(_record get "groups");
{if (_x getVariable ["A3I_context",""] == _context) then {_groups pushBackUnique _x}} forEach allGroups;
{if (count units _x == 0) then {deleteGroup _x}} forEach _groups;
deleteVehicle (_record get "flag");
private _lootTaken = false;
{
    if (alive _x && {_x distance2D getMarkerPos _marker < 100}) then {deleteVehicle _x} else {
        _lootTaken = true;
        if (alive _x) then {[_x] spawn A3A_fnc_VEHdespawner};
    };
} forEach (_record get "crates");
if (_lootTaken) then {
    private _size = ([_marker] call A3A_fnc_garrisonSize) max 1;
    garrison setVariable [_marker + "_lootCD",120*16/_size,true];
};
(_record get "positions") call A3A_fnc_freeSpawnPositions;
if (_record get "announced") then {
    [CBA_EVENT_SERVER_SPAWN_LOCATION,[_marker,_record get "kind",false]] call A3A_fnc_triggerLocalEvent;
};
private _current = A3I_sites getOrDefault [_marker,createHashMap];
if (_current getOrDefault ["id",-1] == _record get "id") then {
    spawner setVariable [_marker + "_A3I_pending",nil,true];
    A3I_sites deleteAt _marker;
};
