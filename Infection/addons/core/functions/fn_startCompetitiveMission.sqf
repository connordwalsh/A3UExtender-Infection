// Claim one CON objective before launching its server-owned worker.
#include "\x\a3a\addons\core\script_component.hpp"
params [["_target","",[""]]];
if (!isServer || {!canSuspend} || {isRemoteExecuted}) exitWith {false};
if ("CON" in (missionNamespace getVariable ["A3A_activeTasks",[]])
    || {count (missionNamespace getVariable ["A3I_competitiveMissions",createHashMap]) > 0}) exitWith {false};
private _routes = [_target] call A3I_fnc_competitiveSources;
if (_routes isEqualTo []) exitWith {false};
private _source = (selectRandom _routes) # 0;
private _difficult = random 10 < tierWar;
private _strength = if (_target in (airportsX + milbases)) then {6} else {[2,4] select _difficult};
private _limit = ([90,45] select _difficult) call SCRT_fnc_misc_getTimeLimit;
private _accepted = false;
isNil {
    if ("CON" in (missionNamespace getVariable ["A3A_activeTasks",[]])
        || {count (missionNamespace getVariable ["A3I_competitiveMissions",createHashMap]) > 0}
        || {missionNamespace getVariable ["bigAttackInProgress",false]} || {!isNil "A3I_majorGlobalOwner"}
        || {sidesX getVariable [_target,sideUnknown] != Invaders}
        || {!([_source] call A3I_fnc_majorSourceEligible)}) exitWith {};
    if (isNil "A3I_competitiveMissions") then {A3I_competitiveMissions = createHashMap; A3I_competitiveSerial = 0};
    A3I_competitiveSerial = A3I_competitiveSerial + 1;
    private _name = "A3I_CON_" + str A3I_competitiveSerial;
    private _record = createHashMapFromArray [["name",_name],["target",_target],["source",_source],
        ["position",getMarkerPos _target],["difficult",_difficult],["strength",_strength],
        ["deadline",_limit # 0],["displayTime",_limit # 1],["outcome","pending"],
        ["taskRegistered",false],["settled",false]];
    A3I_competitiveMissions set [_name,_record];
    _record set ["script",[_record] spawn A3I_fnc_runCompetitiveMission];
    if (isNil "A3I_competitiveCaptureHandle") then {
        A3I_competitiveCaptureHandle = [CBA_EVENT_SERVER_MARKER_CHANGE,A3I_fnc_competitiveCapture]
            call CBA_fnc_addEventHandler;
    };
    if (isNil "A3I_competitiveWatchdogHandle") then {
        A3I_competitiveWatchdogHandle = [A3I_fnc_competitiveWatchdog,1] call CBA_fnc_addPerFrameHandler;
    };
    _accepted = true;
};
_accepted
