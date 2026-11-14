// Native createSupport interface, with actual-birth payment owned by Infection.
params ["_type","_side","_caller","_allowance","_target","_position","_reveal",["_delay",-1]];
if (!isServer || {!canSuspend} || {isRemoteExecuted && {remoteExecutedOwner != 2}})
    exitWith {""};
if !(_type isEqualTo "QRFLAND" && {[_side] call A3I_fnc_isActive}
    && {_type in (missionNamespace getVariable ["A3A_supportTypesOcc",createHashMap])}
    && {_position isEqualType []} && {count _position in [2,3]}
    && {(_position findIf {!(_x isEqualType 0) || {!finite _x}}) == -1}
    && {_reveal isEqualType 0} && {finite _reveal} && {_reveal >= 0} && {_reveal <= 1}
    && {_caller isEqualType [] || {_caller in ["attack","defence"]}}) exitWith {""};
private _pool = if (_caller isEqualType "") then {_caller} else {"defence"};
private _callPosition = if (_caller isEqualType []) then {_caller} else {[]};
waitUntil {isNil "A3A_supportCallInProgress"};
A3A_supportCallInProgress = true;
private _name = "";
try {
    A3A_supportCount = A3A_supportCount + 1;
    private _candidate = "QRFLAND" + str A3A_supportCount;
    private _disclosure = [west,_position,_reveal] call A3A_fnc_useRadioKey;
    private _result = [_candidate,_pool,_allowance,_target,_position,_disclosure,_delay,_callPosition]
        call A3I_fnc_startTacticalSupport;
    if (_result # 0) then {_name = _candidate};
} catch {
    diag_log format ["[INFECTION_SUPPORT] request refused: %1",_exception];
};
A3A_supportCallInProgress = nil;
_name
