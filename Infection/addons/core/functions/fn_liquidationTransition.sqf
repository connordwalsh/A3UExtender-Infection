// Execute an ownership-only commit without yielding between the clearance
// check and the write. The supplied local code must not contain delayed work.
// Native notifications, QRFs and maintenance remain in the capture adapters.
params ["_marker","_winner","_commit",["_arguments",[]]];
if (!isServer || {isRemoteExecuted && {remoteExecutedOwner != 2}}) exitWith {false};
if (canSuspend) exitWith {[A3I_fnc_liquidationTransition,_this] call CBA_fnc_directCall};
if (isNil "sidesX") exitWith {false};
private _before = sidesX getVariable [_marker,sideUnknown];
private _claim = [_marker] call A3I_fnc_liquidationClaim;
if (count _claim > 0 && {[west] call A3I_fnc_isActive} && {_winner == teamPlayer}) then {
    private _military = (missionNamespace getVariable ["airportsX",[]])
        + (missionNamespace getVariable ["milbases",[]]);
    if (dateToNumber date > _claim get "deadline"
        || {_marker in _military && {missionNamespace getVariable ["tierWar",0] < 3}}
        || {!(([_marker] call A3I_fnc_siteClearance) # 0)}) exitWith {_commit = {false}};
};
private _committed = _arguments call _commit;
if (isNil "_committed" || {!(_committed isEqualTo true)}) exitWith {false};
if (sidesX getVariable [_marker,sideUnknown] != _winner || {_before == _winner}) exitWith {false};
// Freeze the first real ownership transition before any delayed native effects.
// A Russian takeover followed by a same-frame Rebel retake stays cancelled.
if (count _claim > 0) then {
    _claim set ["outcome",if (_before == west && {_winner == teamPlayer}
        && {[west] call A3I_fnc_isActive}) then {"won"} else {"cancelled"}];
    _claim set ["captureOwner",_winner];
    _claim set ["captureTime",dateToNumber date];
};
true
