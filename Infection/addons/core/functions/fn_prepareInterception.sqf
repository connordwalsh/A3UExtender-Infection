// Assemble one full finite roster before exposing or moving any of its members.
params ["_record"];
if (!isServer || {!canSuspend} || {isRemoteExecuted}) exitWith {false};
private _roles = _record getOrDefault ["roles",[]];
private _began = false;
isNil {
    if (!([_record] call A3I_fnc_interceptionPreparing)
        || {_record getOrDefault ["preparationStarted",false]}) exitWith {};
    if (count _roles != _record get "size") exitWith {_record set ["fault","invalid_roster"]};
    _record set ["preparationStarted",true];
    _began = true;
};
if (!_began) exitWith {false};
private _deadline = diag_tickTime + 60;
private _attempts = 0;
private _allowed = {[_record] call A3I_fnc_interceptionPreparing};
while {_record get "created" < _record get "size" && {call _allowed}
    && {_attempts < 24} && {diag_tickTime < _deadline}} do {
    _attempts = _attempts + 1;
    private _result = [_record get "context",_roles select [_record get "created",12],
        _record get "spawnPosition",0,100,"","legacy",_record get "size",false,_allowed,false,"",
        A3I_fnc_trackInterceptionMember] call A3I_fnc_spawnGroup;
    _record set ["lastPreparation",_result # 2];
    if (_result # 2 in ["unregistered_role","invalid_request","initialization_failed"])
        exitWith {_record set ["fault",_result # 2]};
    if (!(_result # 0)) then {sleep 0.1};
};
// Prepared-class initialization installs its own delayed doMove-to-self.
// Wait for every native AI initialization, then let that startup command finish
// while the whole formation is still hidden and simulation-disabled.
waitUntil {
    uiSleep 0.1;
    !call _allowed || {diag_tickTime >= _deadline}
        || {((_record get "units") findIf {isNil {_x getVariable "WBK_AI_AttachedHandlers"}}) == -1}
};
uiSleep 1;
private _complete = call _allowed && {_record get "created" == _record get "size"}
    && {count (_record get "units") == _record get "size"}
    && {((_record get "units") findIf {!alive _x || {!isObjectHidden _x} || {simulationEnabled _x}
        || {isNil {_x getVariable "WBK_AI_AttachedHandlers"}}}) == -1};
if (!_complete) exitWith {
    if (_record get "fault" == "") then {_record set ["fault","preparation_incomplete"]};
    [_record] call A3I_fnc_retireInterceptionFormation;
    false
};
_record set ["prepared",true];
true
