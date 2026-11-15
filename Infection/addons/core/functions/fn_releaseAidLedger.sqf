// Release only this exact record; asset and task cleanup belong to its caller.
params [["_name","",[""]],["_serial",-1,[0]]];
if (!isServer || {isRemoteExecuted}) exitWith {false};
if (canSuspend) exitWith {[A3I_fnc_releaseAidLedger,_this] call CBA_fnc_directCall};
private _registry = missionNamespace getVariable ["A3I_aidLedgers",createHashMap];
private _record = _registry getOrDefault [_name,createHashMap];
if (_record getOrDefault ["serial",-2] != _serial) exitWith {false};
private _package = _record get "package";
if (!isNull _package && {(_package getVariable ["A3I_aidOwner",[]]) isEqualTo [_name,_serial]}) then {
    _package setVariable ["A3I_aidOwner",nil];
};
_registry deleteAt _name;
if (count _registry == 0 && {!isNil "A3I_aidLedgerHandle"}) then {
    [A3I_aidLedgerHandle] call CBA_fnc_removePerFrameHandler; A3I_aidLedgerHandle = nil;
};
true
