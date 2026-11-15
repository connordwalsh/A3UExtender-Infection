params [["_name","",[""]],["_serial",-1,[0]]];
if (!isServer || {isRemoteExecuted}) exitWith {false};
if (canSuspend) exitWith {[A3I_fnc_releaseEliminationLedger,_this] call CBA_fnc_directCall};
private _registry = missionNamespace getVariable ["A3I_eliminationLedgers",createHashMap];
private _record = _registry getOrDefault [_name,createHashMap];
if (_record getOrDefault ["serial",-2] != _serial) exitWith {false};
private _unit = _record get "unit";
if (!isNull _unit && {(_unit getVariable ["A3I_eliminationOwner",[]]) isEqualTo [_name,_serial]}) then {
    _unit setVariable ["A3I_eliminationOwner",nil];
};
_registry deleteAt _name;
if (count _registry == 0) then {
    if (!isNil "A3I_eliminationLedgerHandle") then {
        [A3I_eliminationLedgerHandle] call CBA_fnc_removePerFrameHandler; A3I_eliminationLedgerHandle = nil;
    };
    if (!isNil "A3I_eliminationKilledEH") then {
        removeMissionEventHandler ["EntityKilled",A3I_eliminationKilledEH];
        removeMissionEventHandler ["EntityDeleted",A3I_eliminationDeletedEH];
        A3I_eliminationKilledEH = nil; A3I_eliminationDeletedEH = nil;
    };
};
true
