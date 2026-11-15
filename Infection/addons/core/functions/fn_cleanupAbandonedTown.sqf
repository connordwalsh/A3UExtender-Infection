params ["_record"];
if (!isServer || {isRemoteExecuted}) exitWith {false};
if (canSuspend) exitWith {[A3I_fnc_cleanupAbandonedTown,_this] call CBA_fnc_directCall};
private _town = _record getOrDefault ["town",""];
private _current = (missionNamespace getVariable ["A3I_abandonedTowns",createHashMap]) getOrDefault [_town,createHashMap];
if (_current getOrDefault ["serial",-1] != _record getOrDefault ["serial",-2]) exitWith {false};
_record = _current;
if !(_record get "ended") exitWith {false};
if !(_record get "nativeRetired") then {
    // Native boats and driven traffic retain their original cleanup paths.
    {
        if (!isNull _x && {_x getVariable ["ownerSide",sideUnknown] == civilian}) then {
            if (_x distance2D (_x getVariable ["originalPos",getPosATL _x]) < 100) then {deleteVehicle _x}
            else {[_x] spawn A3A_fnc_VEHdespawner};
        };
    } forEach (_record get "nativeParked");
    {if (!isNull _x) then {[_x] spawn A3A_fnc_groupDespawner}} forEach (_record get "trafficGroups");
    {if (!isNull _x) then {[_x] spawn A3A_fnc_VEHdespawner}} forEach (_record get "trafficVehicles");
    _record set ["nativeRetired",true];
};
private _remaining = [];
private _observers = call A3I_fnc_spawnObservers;
{
    private _vehicle = _x;
    if (isNull _vehicle || {!((_vehicle getVariable ["A3I_abandonedTownOwner",[]])
        isEqualTo [_town,_record get "serial"])}) then {continue};
    if (_vehicle getVariable ["ownerSide",sideUnknown] != sideUnknown) then {
        _vehicle setVariable ["A3I_abandonedTownOwner",nil]; continue;
    };
    private _inUse = !local _vehicle || {(crew _vehicle findIf {alive _x}) >= 0}
        || {!isNull attachedTo _vehicle} || {ropesAttachedTo _vehicle isNotEqualTo []}
        || {ropes _vehicle isNotEqualTo []}
        || {(_observers findIf {_x distance2D _vehicle < 150}) != -1};
    if (_inUse) then {_remaining pushBack _vehicle; continue};
    _vehicle setVariable ["A3I_abandonedTownOwner",nil];
    if (_vehicle distance2D (_vehicle getVariable ["originalPos",getPosATL _vehicle]) < 100) then {
        deleteVehicle _vehicle;
    } else {[_vehicle] spawn A3A_fnc_VEHdespawner};
} forEach (_record get "vehicles");
_record set ["vehicles",_remaining];
_remaining isEqualTo []
