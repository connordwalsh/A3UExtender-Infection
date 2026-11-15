params ["_record"];
if (!isServer || {!canSuspend} || {isRemoteExecuted}) exitWith {};
if (!([_record] call A3I_fnc_prepareInterception)) exitWith {
    if (_record get "fault" == "") then {_record set ["fault","preparation_failed"]};
    [_record] call A3I_fnc_finishInterception;
};
private _launched = false;
isNil {
    if ("CONVOY" in (missionNamespace getVariable ["A3A_activeTasks",[]])
        || {(missionNamespace getVariable ["A3A_tasksData",[]]) findIf {_x # 1 == "CONVOY"} >= 0})
        exitWith {_record set ["fault","task_race"]};
    if (!([_record] call A3I_fnc_releaseInterceptionFormation))
        exitWith {_record set ["fault","release_failed"]};
    _launched = [_record,_record get "difficult"] call A3I_fnc_registerInterceptionTask;
    if (!_launched) exitWith {_record set ["fault","registration_failed"]};
    private _origin = _record get "source";
    if (isNil "A3I_majorSourceCooldowns") then {A3I_majorSourceCooldowns = createHashMap};
    A3I_majorSourceCooldowns set [_origin,time + 600];
    if (_origin in (airportsX + outposts + milbases)) then {[_origin,10] call A3A_fnc_addTimeForIdle};
};
if (!_launched) exitWith {[_record] call A3I_fnc_finishInterception};
waitUntil {sleep 0.25; _record getOrDefault ["settled",false]};
// The independent lifecycle supervisor now owns aftermath and safe retirement.
