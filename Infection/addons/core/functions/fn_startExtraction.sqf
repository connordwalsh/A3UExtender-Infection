params [["_source","",[""]]];
if (!isServer || {isRemoteExecuted} || {!canSuspend} || {isNil "tierWar"}
    || {isNil "overallHRGain"} || {isNil "boxX"} || {isNull boxX}) exitWith {false};
private _targets = call A3I_fnc_extractionTargets;
if (_source == "" && {_targets isNotEqualTo []}) then {_source=selectRandom _targets};
if !(_source in _targets) exitWith {false};
private _roles=A3A_faction_occ getOrDefault ["groupPoliceTeam",[]];
if (count _roles != 4) exitWith {false};
private _accepted=false;
isNil {
    if (call A3I_fnc_extractionTaskBusy) exitWith {};
    if (isNil "A3I_extractionTasks") then {A3I_extractionTasks=createHashMap};
    A3I_extractionTaskSerial=(missionNamespace getVariable ["A3I_extractionTaskSerial",0])+1;
    private _name="A3I_EXTRACTION_"+str A3I_extractionTaskSerial;
    private _hard=random 10 < tierWar;
    private _record=createHashMapFromArray [["name",_name],["serial",A3I_extractionTaskSerial],
        ["source",_source],["difficult",_hard],["duration",[3600,1800] select _hard],
        ["hrFactor",2-overallHRGain/100],["hrCredited",0],["guardRoles",+_roles],
        ["units",[]],["guards",[]],["groups",[]],["ledger",createHashMap],
        ["phase","preparing"],["settled",false],["outcome","pending"],["fault",""],
        ["taskRegistered",false],["taskRetired",false],["assetRetired",false]];
    A3I_extractionTasks set [_name,_record];
    _record set ["script",[_record] spawn A3I_fnc_runExtraction];
    if (isNil "A3I_extractionTaskHandle") then {
        A3I_extractionTaskHandle=[A3I_fnc_extractionTaskTick,1] call CBA_fnc_addPerFrameHandler;
    };
    _accepted=true;
};
_accepted
