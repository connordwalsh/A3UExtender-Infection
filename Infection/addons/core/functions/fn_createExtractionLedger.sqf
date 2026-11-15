// Internal mission bookkeeping; no task, reward, recruitment or asset creation.
params [["_name","",[""]],["_units",[],[[]]],["_deadline",0,[0]]];
if (!isServer || {isRemoteExecuted} || {!([west] call A3I_fnc_isActive)}) exitWith {createHashMap};
if (canSuspend) exitWith {[A3I_fnc_createExtractionLedger,_this] call CBA_fnc_directCall};
if (_name == "" || {_units isEqualTo []} || {!finite _deadline} || {_deadline <= time}
    || {isNil "teamPlayer"} || {count (_units arrayIntersect _units) != count _units}
    || {(_units findIf {!(_x isEqualType objNull) || {isNull _x} || {!alive _x}
        || {!local _x} || {isPlayer _x} || {!(_x isKindOf "CAManBase")}
        || {!(side group _x in [teamPlayer,civilian])}
        || {_x getVariable ["WBK_AI_ISZombie",false]}
        || {!isNil {_x getVariable "A3I_extractionOwner"}}}) != -1}) exitWith {createHashMap};
if (isNil "A3I_extractionLedgers") then {A3I_extractionLedgers = createHashMap};
if (_name in A3I_extractionLedgers) exitWith {createHashMap};
A3I_extractionSerial = (missionNamespace getVariable ["A3I_extractionSerial",0]) + 1;
private _serial = A3I_extractionSerial;
private _entries = _units apply {createHashMapFromArray [
    ["unit",_x],["state","pending"],["deleted",false],["destination",""],["resolvedAt",-1]]};
private _record = createHashMapFromArray [["name",_name],["serial",_serial],
    ["entries",_entries],["deadline",_deadline],["outcome","pending"],
    ["reason",""],["rescued",0],["killed",0],["unresolved",count _units],["settledAt",-1]];
A3I_extractionLedgers set [_name,_record];
{_x setVariable ["A3I_extractionOwner",[_name,_serial,_forEachIndex]]} forEach _units;
// Mission-level events observe the exact registered actor without depending on
// its later group locality. No remote caller may submit survivor outcomes.
if (isNil "A3I_extractionKilledEH") then {
    A3I_extractionKilledEH = addMissionEventHandler ["EntityKilled", {
        [_this # 0,"killed"] call A3I_fnc_extractionMemberEvent;
    }];
    A3I_extractionDeletedEH = addMissionEventHandler ["EntityDeleted", {
        // The installed engine passes the entity directly; accept the documented
        // array form too, without indexing an object as an array.
        private _entity = if (_this isEqualType []) then {_this param [0,objNull]} else {_this};
        [_entity,"deleted"] call A3I_fnc_extractionMemberEvent;
    }];
};
if (isNil "A3I_extractionLedgerHandle") then {
    A3I_extractionLedgerHandle = [{
        {[_y] call A3I_fnc_updateExtractionLedger} forEach A3I_extractionLedgers;
        if ((values A3I_extractionLedgers findIf {_x get "outcome" == "pending"}) == -1) then {
            [_this # 1] call CBA_fnc_removePerFrameHandler;
            A3I_extractionLedgerHandle = nil;
        };
    },1] call CBA_fnc_addPerFrameHandler;
};
_record
