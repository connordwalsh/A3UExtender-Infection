params [["_source","",[""]],["_primary","",[""]]];
if (!isServer || {isRemoteExecuted} || {!canSuspend}) exitWith {false};
private _targets = call A3I_fnc_eliminationTargets;
if (_source == "" && {_targets isNotEqualTo []}) then {_source = selectRandom _targets};
if !(_source in _targets) exitWith {false};
private _classes = call A3I_fnc_eliminationClasses;
if (_primary == "" && {_classes isNotEqualTo []}) then {_primary = selectRandom _classes};
if !(_primary in _classes) exitWith {false};
private _accepted = false;
isNil {
    if (call A3I_fnc_eliminationTaskBusy) exitWith {};
    if (isNil "A3I_eliminationTasks") then {A3I_eliminationTasks = createHashMap};
    A3I_eliminationTaskSerial = (missionNamespace getVariable ["A3I_eliminationTaskSerial",0])+1;
    private _name = "A3I_ELIM_"+str A3I_eliminationTaskSerial;
    private _hard = random 10 < tierWar;
    private _record = createHashMapFromArray [["name",_name],["serial",A3I_eliminationTaskSerial],
        ["source",_source],["class",_primary],["difficult",_hard],["duration",[3600,1800] select _hard],
        ["phase","preparing"],["units",[]],["group",grpNull],["ledger",createHashMap],
        ["searchMarker",""],["settled",false],["outcome","pending"],["fault",""],
        ["taskRegistered",false],["taskRetired",false],["assetRetired",false]];
    A3I_eliminationTasks set [_name,_record];
    _record set ["script",[_record] spawn A3I_fnc_runElimination];
    if (isNil "A3I_eliminationTaskHandle") then {
        A3I_eliminationTaskHandle = [A3I_fnc_eliminationTaskTick,1] call CBA_fnc_addPerFrameHandler;
    };
    _accepted = true;
};
_accepted
