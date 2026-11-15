params [["_unit",objNull,[objNull]],["_rescuer",objNull,[objNull]]];
if (!isServer || {!isPlayer _rescuer} || {_rescuer isKindOf "HeadlessClient_F"}
    || {_rescuer != _rescuer getVariable ["owner",objNull]}
    || {isRemoteExecuted && {remoteExecutedOwner != owner _rescuer}}) exitWith {false};
[_unit,_rescuer] call A3I_fnc_beginExtractionRelease
