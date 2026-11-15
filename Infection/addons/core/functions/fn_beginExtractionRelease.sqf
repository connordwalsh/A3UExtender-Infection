// Trusted server entry also allows AI actors in isolated contracts.
params [["_unit",objNull,[objNull]],["_rescuer",objNull,[objNull]]];
if (!isServer || {isRemoteExecuted && {!isPlayer _rescuer || {remoteExecutedOwner != owner _rescuer}}}) exitWith {false};
if (canSuspend) exitWith {[A3I_fnc_beginExtractionRelease,_this] call CBA_fnc_directCall};
if (isNull _unit || {!alive _unit} || {!local _unit} || {isPlayer _unit}
    || {!alive _rescuer} || {side group _rescuer != teamPlayer}
    || {_rescuer getVariable ["incapacitated",false]} || {_rescuer getVariable ["surrendered",false]}
    || {_unit getVariable ["incapacitated",false]} || {_unit getVariable ["WBK_AI_ISZombie",false]}
    || {!(side group _unit in [teamPlayer,civilian])} || {_unit distance _rescuer > 4}) exitWith {false};
private _owner = _unit getVariable ["A3I_extractionOwner",[]];
if (count _owner != 3) exitWith {false};
_owner params ["_name","_serial","_index"];
private _record = (missionNamespace getVariable ["A3I_extractionLedgers",createHashMap]) getOrDefault [_name,createHashMap];
if (_record getOrDefault ["serial",-1] != _serial || {_record get "outcome" != "pending"}
    || {time >= _record get "deadline"}) exitWith {false};
private _entry = (_record get "entries") param [_index,createHashMap];
if (_entry getOrDefault ["unit",objNull] != _unit || {_entry get "state" != "pending"}
    || {_entry getOrDefault ["releaseState",""] != "waiting"}) exitWith {false};
_entry set ["releaseState","releasing"]; _entry set ["rescuer",_rescuer];
_entry set ["releaseAt",time+3];
_unit setVariable ["A3I_extractionReleaseState","releasing",true];
[_rescuer,false] remoteExecCall ["setCaptive",_rescuer];
true
