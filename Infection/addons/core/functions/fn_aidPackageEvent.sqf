params [["_package",objNull,[objNull]],["_event","",[""]]];
if (!isServer || {isRemoteExecuted} || {isNull _package}
    || {!(_event in ["killed","deleted"])}) exitWith {false};
if (canSuspend) exitWith {[A3I_fnc_aidPackageEvent,_this] call CBA_fnc_directCall};
private _owner = _package getVariable ["A3I_aidOwner",[]];
if (count _owner != 2) exitWith {false};
_owner params ["_name","_serial"];
private _record = (missionNamespace getVariable ["A3I_aidLedgers",createHashMap]) getOrDefault [_name,createHashMap];
if (_record getOrDefault ["serial",-1] != _serial || {_record get "outcome" != "pending"}
    || {!((_record get "package") isEqualTo _package)}) exitWith {false};
if (_event == "deleted") exitWith {_record set ["deleted",true]; true};
// Deletion can make alive false before isNull; only an observed death counts.
if (alive _package || {_record get "deleted"}) exitWith {false};
_record set ["killed",true]; true
