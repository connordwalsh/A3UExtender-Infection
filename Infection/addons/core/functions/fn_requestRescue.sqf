// Public server endpoint: a remote caller can act only for their real player.
params [["_unit",objNull,[objNull]], ["_rescuer",objNull,[objNull]]];
if (!isServer || {!isPlayer _rescuer} || {_rescuer isKindOf "HeadlessClient_F"}
    || {isRemoteExecuted && {remoteExecutedOwner != owner _rescuer}}) exitWith {false};
[_unit,_rescuer] call A3I_fnc_beginRescue
