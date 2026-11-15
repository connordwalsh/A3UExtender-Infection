if (!([west] call A3I_fnc_isActive)) exitWith {_this call A3I_fnc_originalDialogCivFinished};
params [["_unit",objNull,[objNull]],["_caller",objNull,[objNull]]];
if (!isServer || {isNull _unit} || {isNull _caller}) exitWith {false};
if (isRemoteExecuted && {remoteExecutedOwner != 2}
    && {!isPlayer _caller || {owner _caller != remoteExecutedOwner}}) exitWith {false};
[{_this spawn A3I_fnc_runCivilianDialog},[_unit,_caller]] call CBA_fnc_execNextFrame;
true
