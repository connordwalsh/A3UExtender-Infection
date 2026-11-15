params [["_unit",objNull,[objNull]],["_event","",[""]]];
if (!isServer || {isRemoteExecuted} || {isNull _unit}
    || {!(_event in ["killed","deleted"])}) exitWith {false};
if (canSuspend) exitWith {[A3I_fnc_extractionMemberEvent,_this] call CBA_fnc_directCall};
private _owner = _unit getVariable ["A3I_extractionOwner",[]];
if (count _owner != 3) exitWith {false};
_owner params ["_name","_serial","_index"];
private _record = (missionNamespace getVariable ["A3I_extractionLedgers",createHashMap])
    getOrDefault [_name,createHashMap];
if (_record getOrDefault ["serial",-1] != _serial
    || {_record get "outcome" != "pending"} || {time >= _record get "deadline"}) exitWith {false};
private _entries = _record get "entries";
if (_index < 0 || {_index >= count _entries}) exitWith {false};
private _entry = _entries # _index;
if (!((_entry get "unit") isEqualTo _unit) || {_entry get "state" != "pending"}) exitWith {false};
if (_event == "deleted") exitWith {_entry set ["deleted",true]; true};
// Deleted can make alive false; only a real death observed before deletion is
// terminal. An unexplained disappearance stays unresolved until the deadline.
if (alive _unit || {_entry get "deleted"}) exitWith {false};
_entry set ["state","killed"];
_entry set ["resolvedAt",time];
true
