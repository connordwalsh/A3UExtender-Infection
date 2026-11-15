// Internal neutralization tracking only; no creation, task, reward or cleanup.
params [["_name","",[""]],["_unit",objNull,[objNull]],["_deadline",0,[0]]];
if (!isServer || {isRemoteExecuted} || {!([west] call A3I_fnc_isActive)}) exitWith {createHashMap};
if (canSuspend) exitWith {[A3I_fnc_createEliminationLedger,_this] call CBA_fnc_directCall};
if (_name == "" || {!finite _deadline} || {_deadline <= time}
    || {isNull _unit} || {!alive _unit} || {!local _unit} || {isPlayer _unit}
    || {side group _unit != west} || {!(typeOf _unit in (call A3I_fnc_eliminationClasses))}
    || {!isNil {_unit getVariable "A3I_eliminationOwner"}}) exitWith {createHashMap};
if (isNil "A3I_eliminationLedgers") then {A3I_eliminationLedgers = createHashMap};
if (_name in A3I_eliminationLedgers) exitWith {createHashMap};
A3I_eliminationSerial = (missionNamespace getVariable ["A3I_eliminationSerial",0])+1;
private _serial = A3I_eliminationSerial;
private _record = createHashMapFromArray [["name",_name],["serial",_serial],["unit",_unit],
    ["class",typeOf _unit],["deadline",_deadline],["killedAt",-1],["deleted",false],
    ["outcome","pending"],["reason",""],["settledAt",-1]];
A3I_eliminationLedgers set [_name,_record];
_unit setVariable ["A3I_eliminationOwner",[_name,_serial]];
if (isNil "A3I_eliminationKilledEH") then {
    A3I_eliminationKilledEH = addMissionEventHandler ["EntityKilled", {
        [_this # 0,"killed"] call A3I_fnc_eliminationTargetEvent;
    }];
    A3I_eliminationDeletedEH = addMissionEventHandler ["EntityDeleted", {
        private _entity = if (_this isEqualType []) then {_this param [0,objNull]} else {_this};
        [_entity,"deleted"] call A3I_fnc_eliminationTargetEvent;
    }];
};
if (isNil "A3I_eliminationLedgerHandle") then {
    A3I_eliminationLedgerHandle = [{
        {[_y] call A3I_fnc_updateEliminationLedger} forEach A3I_eliminationLedgers;
        if ((values A3I_eliminationLedgers findIf {_x get "outcome" == "pending"}) == -1) then {
            [_this # 1] call CBA_fnc_removePerFrameHandler; A3I_eliminationLedgerHandle = nil;
        };
    },1] call CBA_fnc_addPerFrameHandler;
};
_record
