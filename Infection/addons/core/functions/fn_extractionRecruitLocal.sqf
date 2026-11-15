// Native rebel initialization must run where the newly joined unit is local.
params [["_unit",objNull,[objNull]],["_rescuer",objNull,[objNull]],["_token",[],[[]]]];
if (!canSuspend || {isRemoteExecuted && {remoteExecutedOwner != 2}}
    || {!isRemoteExecuted && {!isServer}}) exitWith {};
private _until = diag_tickTime+10;
waitUntil {sleep 0.1; isNull _unit || {local _unit && {group _unit == group _rescuer}} || {diag_tickTime >= _until}};
if (!alive _unit || {!local _unit} || {group _unit != group _rescuer}
    || {!((_unit getVariable ["A3I_extractionRecruitToken",[]]) isEqualTo _token)}
    || {(_unit getVariable ["A3I_extractionRecruitInitialized",[]]) isEqualTo _token}) exitWith {};
_unit setVariable ["A3I_extractionRecruitInitialized",+_token,true];
[_unit,true,false] spawn A3A_fnc_FIAinit;
