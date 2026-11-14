// Server-owned CON assignment. The claim precedes task creation so concurrent
// requests cannot start another controller during the registration handoff.
params [["_target","",[""]]];
if (!isServer || {!canSuspend} || {isRemoteExecuted}) exitWith {false};
if (!(_target in (call A3I_fnc_liquidationTargets))) exitWith {false};
private _hard = random 10 < tierWar;
private _limit = ([90,45] select _hard) call SCRT_fnc_misc_getTimeLimit;
private _accepted = false;
isNil {
    if ("CON" in (missionNamespace getVariable ["A3A_activeTasks",[]])
        || {count (missionNamespace getVariable ["A3I_liquidationClaims",createHashMap]) > 0}
        || {!([west] call A3I_fnc_isActive)}
        || {tierWar < 3 && {_target in (airportsX + milbases)}}
        || {sidesX getVariable [_target,sideUnknown] != west}) exitWith {};
    if (isNil "A3I_liquidationClaims") then {A3I_liquidationClaims = createHashMap};
    A3I_liquidationSerial = (missionNamespace getVariable ["A3I_liquidationSerial",0]) + 1;
    private _record = createHashMapFromArray [["name","A3I_LIQ_" + str A3I_liquidationSerial],
        ["target",_target],["position",getMarkerPos _target],["kind",[_target] call A3I_fnc_liquidationTargetKind],
        ["difficult",_hard],["deadline",_limit # 0],["displayTime",_limit # 1],
        ["outcome","pending"],["settled",false],["taskRegistered",false]];
    A3I_liquidationClaims set [_target,_record];
    _record set ["script",[_record] spawn A3I_fnc_runLiquidation];
    if (isNil "A3I_liquidationWatchdogHandle") then {
        A3I_liquidationWatchdogHandle = [A3I_fnc_liquidationWatchdog,1] call CBA_fnc_addPerFrameHandler;
    };
    _accepted = true;
};
_accepted
