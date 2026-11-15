params ["_arguments","_handle"];
if (!isServer || {isRemoteExecuted}) exitWith {};
_arguments params ["_name","_serial"];
private _record = (missionNamespace getVariable ["A3I_interceptions",createHashMap]) getOrDefault [_name,createHashMap];
if (_record getOrDefault ["serial",-1] != _serial
    || {_record getOrDefault ["lifecycleHandle",-1] != _handle}) exitWith {
    [_handle] call CBA_fnc_removePerFrameHandler;
};
if (!(_record getOrDefault ["settled",false])) then {
    // Preparation has no public task. Wait for it unless its worker stops or fails.
    if (_record getOrDefault ["phase",""] != "preparing"
        || {scriptDone (_record getOrDefault ["script",scriptNull])}
        || {_record getOrDefault ["fault",""] != ""}
        || {!([west] call A3I_fnc_isActive)}) then {[_record] call A3I_fnc_finishInterception};
};
if (!(_record getOrDefault ["settled",false])) exitWith {};
// First arrival is task failure, not permission to delete the arriving horde.
// The separate aftermath owner must explicitly finish reinforcement/combat first.
if (_record getOrDefault ["outcome",""] != "arrived"
    || {_record getOrDefault ["aftermathComplete",false]}) then {
    private _worker = _record getOrDefault ["script",scriptNull];
    if (!scriptDone _worker) then {terminate _worker};
    if (!(_record getOrDefault ["retired",false])) then {[_record] call A3I_fnc_retireInterceptionFormation};
};
[_record] call A3I_fnc_cleanupInterceptionTask;
if (!(_record getOrDefault ["retired",false]) || {!(_record getOrDefault ["taskRetired",false])}) exitWith {};
// Reconcile dead bindings before releasing the exact claim. Corpses retain their
// native lifetime and empty groups are owned by the shared group cleanup service.
["stats"] call A3I_fnc_budget;
private _context = _record get "context";
if ((values A3I_budgetRecords) findIf {_x # 0 == _context} != -1) exitWith {};
[_handle] call CBA_fnc_removePerFrameHandler;
_record deleteAt "lifecycleHandle";
A3I_interceptions deleteAt _name;
