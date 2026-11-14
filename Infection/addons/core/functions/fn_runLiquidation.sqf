params ["_record"];
if (!isServer || {!canSuspend} || {isRemoteExecuted}) exitWith {};
private _target = _record get "target";
private _destination = [_target] call A3A_fnc_localizar;
private _description = format ["High command calls for the liberation of %1. Cleanse the site of infected so friendly forces can move in.<br/><br/>Complete the assignment by %2. If Russian forces take the location first, the assignment is cancelled without a penalty.",
    _destination,_record get "displayTime"];
[[teamPlayer,civilian],_record get "name",[_description,"Liquidation Assignment",_target],
    _record get "position",false,0,true,"Target",true] call BIS_fnc_taskCreate;
[_record get "name","CON","CREATED"] call A3A_fnc_taskUpdate;
_record set ["taskRegistered",true];
while {_record get "outcome" == "pending"} do {
    isNil {_record set ["outcome",[_record] call A3I_fnc_liquidationOutcome]};
    // Native site capture has delayed flag work. Keep that worker independent
    // so stopping the task loop cannot strand its markersChanging lock.
    isNil {
        if (_record get "outcome" == "pending"
            && {scriptDone (_record getOrDefault ["captureScript",scriptNull])}
            && {([_target] call A3I_fnc_siteClearance) # 0}) then {
            _record set ["captureScript",[_record] spawn A3I_fnc_captureLiquidation];
        };
    };
    if (_record get "outcome" == "pending") then {sleep 1};
};
[_record] call A3I_fnc_finishLiquidation;
