params [["_target","",[""]]];
if (!isServer || {isRemoteExecuted} || {!canSuspend} || {isNil "tierWar"}) exitWith {false};
private _targets = call A3I_fnc_aidTargets;
if (_target == "" && {_targets isNotEqualTo []}) then {_target = selectRandomWeighted _targets};
if !(_target in _targets) exitWith {false};
private _accepted = false;
isNil {
    if (call A3I_fnc_aidTaskBusy || {!(_target in (call A3I_fnc_aidTargets))}) exitWith {};
    if (isNil "A3I_aidTasks") then {A3I_aidTasks = createHashMap};
    A3I_aidTaskSerial = (missionNamespace getVariable ["A3I_aidTaskSerial",0])+1;
    private _name = "A3I_AID_"+str A3I_aidTaskSerial;
    private _hard = random 10 < tierWar;
    private _record = createHashMapFromArray [["name",_name],["serial",A3I_aidTaskSerial],["target",_target],
        ["difficult",_hard],["duration",[3600,1800] select _hard],["phase","preparing"],
        ["package",objNull],["ledger",createHashMap],["settled",false],["outcome","pending"],
        ["taskRegistered",false],["taskRetired",false],["assetRetired",false],
        ["pickupMarker",""],["notifiedOwners",[]],["fault",""]];
    A3I_aidTasks set [_name,_record];
    A3I_aidSupplyLock = [_name,A3I_aidTaskSerial];
    missionNamespace setVariable ["A3A_supplyMissionActive",true,true];
    _record set ["script",[_record] spawn A3I_fnc_runHumanitarianAid];
    if (isNil "A3I_aidTaskHandle") then {A3I_aidTaskHandle = [A3I_fnc_aidTaskTick,1] call CBA_fnc_addPerFrameHandler};
    _accepted = true;
};
_accepted
