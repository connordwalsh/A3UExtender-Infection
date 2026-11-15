// Forget only this exact ledger and its observers; asset cleanup belongs to the
// mission controller. Never delete survivors or another system's event handlers.
params [["_name","",[""]],["_serial",-1,[0]]];
if (!isServer || {isRemoteExecuted}) exitWith {false};
if (canSuspend) exitWith {[A3I_fnc_releaseExtractionLedger,_this] call CBA_fnc_directCall};
private _registry = missionNamespace getVariable ["A3I_extractionLedgers",createHashMap];
private _record = _registry getOrDefault [_name,createHashMap];
if (_record getOrDefault ["serial",-2] != _serial) exitWith {false};
{
    private _unit = _x get "unit";
    if (!isNull _unit && {(_unit getVariable ["A3I_extractionOwner",[]]) isEqualTo
        [_name,_serial,_forEachIndex]}) then {_unit setVariable ["A3I_extractionOwner",nil]};
} forEach (_record get "entries");
_registry deleteAt _name;
if (count _registry == 0) then {
    if (!isNil "A3I_extractionLedgerHandle") then {
        [A3I_extractionLedgerHandle] call CBA_fnc_removePerFrameHandler;
        A3I_extractionLedgerHandle = nil;
    };
    if (!isNil "A3I_extractionKilledEH") then {
        removeMissionEventHandler ["EntityKilled",A3I_extractionKilledEH];
        removeMissionEventHandler ["EntityDeleted",A3I_extractionDeletedEH];
        A3I_extractionKilledEH = nil; A3I_extractionDeletedEH = nil;
    };
};
true
