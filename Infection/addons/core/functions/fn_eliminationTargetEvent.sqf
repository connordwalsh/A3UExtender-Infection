params [["_unit",objNull,[objNull]],["_event","",[""]]];
if (!isServer || {isRemoteExecuted} || {isNull _unit}
    || {!(_event in ["killed","deleted"])}) exitWith {false};
if (canSuspend) exitWith {[A3I_fnc_eliminationTargetEvent,_this] call CBA_fnc_directCall};
private _owner = _unit getVariable ["A3I_eliminationOwner",[]];
if (count _owner != 2) exitWith {false};
_owner params ["_name","_serial"];
private _record = (missionNamespace getVariable ["A3I_eliminationLedgers",createHashMap]) getOrDefault [_name,createHashMap];
if (_record getOrDefault ["serial",-1] != _serial || {_record get "outcome" != "pending"}
    || {!((_record get "unit") isEqualTo _unit)}) exitWith {false};
if (_event == "deleted") exitWith {_record set ["deleted",true]; true};
// Disappearance or synthetic calls on a living target cannot prove a kill.
if (alive _unit || {_record get "deleted"} || {_record get "killedAt" >= 0}) exitWith {false};
_record set ["killedAt",time]; true
