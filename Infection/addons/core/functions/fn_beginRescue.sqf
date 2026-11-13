// Internal server transition, also usable by trusted server gameplay/tests.
// requestRescue validates player identity before invoking this transaction.
params ["_unit","_rescuer"];
if (!isServer || {isRemoteExecuted && {remoteExecutedOwner != 2}
    && {!isPlayer _rescuer || {remoteExecutedOwner != owner _rescuer}}}) exitWith {false};
if (canSuspend) exitWith {[A3I_fnc_beginRescue,_this] call CBA_fnc_directCall};
if (!alive _unit || {!local _unit} || {!alive _rescuer} || {side group _rescuer != teamPlayer}
    || {_rescuer getVariable ["incapacitated",false]} || {_rescuer getVariable ["surrendered",false]}
    || {_unit distance _rescuer > 4} || {!(_unit getVariable ["A3I_survivor",false])}
    || {_unit getVariable ["A3I_survivorState",""] != "waiting"} || {isNil "A3I_sites"}) exitWith {false};
private _marker = _unit getVariable ["A3I_survivorMarker",""];
private _record = A3I_sites getOrDefault [_marker,createHashMap];
if (_record getOrDefault ["id",-1] != _unit getVariable ["A3I_survivorId",-2]
    || {_record get "cleaned"} || {!(_unit in (_record get "civilians"))}) exitWith {false};
_unit setVariable ["A3I_survivorState","releasing",true];
if (isNil "A3I_rescues") then {A3I_rescues = createHashMap; A3I_rescueSerial = 0};
A3I_rescueSerial = A3I_rescueSerial + 1;
A3I_rescues set [str A3I_rescueSerial,[_unit,_rescuer,"releasing",diag_tickTime + 5,_marker,_record get "id",grpNull]];
[_rescuer,false] remoteExec ["setCaptive",_rescuer];
[_rescuer,"MountSide"] remoteExec ["playMove",_rescuer];
if (isNil "A3I_rescueHandle") then {
    A3I_rescueHandle = [A3I_fnc_rescueTick,0.5] call CBA_fnc_addPerFrameHandler;
};
true
