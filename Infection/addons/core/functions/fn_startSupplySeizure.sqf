params [["_target","",[""]],["_kind","",[""]]];
if (!isServer || {isRemoteExecuted} || {!canSuspend} || {isNil "tierWar"}
    || {isNil "staticsToSave"}) exitWith {false};
private _targets = call A3I_fnc_supplyTargets;
if (_target == "" && {_targets isNotEqualTo []}) then {_target = selectRandom _targets};
if !(_target in _targets) exitWith {false};
private _kinds = [_target] call A3I_fnc_supplySiteKinds;
if (_kind == "" && {_kinds isNotEqualTo []}) then {_kind = selectRandom _kinds};
if !(_kind in _kinds) exitWith {false};
private _classes = [_kind] call A3I_fnc_supplyTruckClasses;
if (_classes isEqualTo []) exitWith {false};
private _accepted = false;
isNil {
    if (call A3I_fnc_supplyTaskBusy || {!(_kind in ([_target] call A3I_fnc_supplySiteKinds))}) exitWith {};
    if (isNil "A3I_supplyTasks") then {A3I_supplyTasks = createHashMap};
    A3I_supplySerial = (missionNamespace getVariable ["A3I_supplySerial",0]) + 1;
    private _name = "A3I_SUPPLY_" + str A3I_supplySerial;
    private _hard = random 10 < tierWar;
    private _record = createHashMapFromArray [["name",_name],["serial",A3I_supplySerial],
        ["source",_target],["kind",_kind],["class",selectRandom _classes],
        ["difficult",_hard],["duration",[3600,1800] select _hard],
        ["phase","preparing"],["truck",objNull],["settled",false],["outcome","pending"],
        ["taskRegistered",false],["taskRetired",false],["assetRetired",false],["fault",""]];
    A3I_supplyTasks set [_name,_record];
    _record set ["script",[_record] spawn A3I_fnc_runSupplySeizure];
    if (isNil "A3I_supplyTaskHandle") then {
        A3I_supplyTaskHandle = [A3I_fnc_supplyTaskTick,1] call CBA_fnc_addPerFrameHandler;
    };
    _accepted = true;
};
_accepted
