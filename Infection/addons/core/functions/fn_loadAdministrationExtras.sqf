// Restore through Ultimate's documented plugin load event, before site spawning.
params [["_plugins",createHashMap,[createHashMap]]];
if (!isServer || {isRemoteExecuted} || {!([west] call A3I_fnc_isActive)}
    || {isNil "garrison"} || {isNil "sidesX"}) exitWith {false};
if (canSuspend) exitWith {[A3I_fnc_loadAdministrationExtras,_this] call CBA_fnc_directCall};
private _data = _plugins getOrDefault ["A3I_administrationExtras",[]];
if (!(_data isEqualType []) || {count _data != 2} || {_data # 0 isNotEqualTo 1}
    || {!(_data # 1 isEqualType [])}) exitWith {false};
private _definitions = A3A_faction_occ get "loadouts";
private _validRole = {
    params ["_role"];
    _role isEqualType "" && {_role find "loadouts_occ_" == 0} && {(_role select [13]) in _definitions}
};
private _seen = [];
private _valid = true;
{
    if (!(_x isEqualType []) || {count _x != 2} || {!(_x # 0 isEqualType "")}
        || {!(_x # 1 isEqualType [])} || {_x # 0 in _seen}
        || {(_x # 1 findIf {!([_x] call _validRole)}) != -1}) exitWith {_valid = false};
    _seen pushBack (_x # 0);
} forEach (_data # 1);
if (!_valid) exitWith {false};
// A load event may repeat. Replace only our roles, never append duplicates or
// erase unrelated entries. Unknown/removed map markers are not recreated.
private _administrations = missionNamespace getVariable ["milAdministrationsX",[]];
{
    if (_x in allMapMarkers && {sidesX getVariable [_x,sideUnknown] == west}) then {
        private _kept = (garrison getVariable [_x,[]]) select {!([_x] call _validRole)};
        garrison setVariable [_x,_kept,true];
    };
} forEach _administrations;
{
    _x params ["_marker","_roles"];
    if (_marker in _administrations && {_marker in allMapMarkers}
        && {sidesX getVariable [_marker,sideUnknown] == west}) then {
        garrison setVariable [_marker,(garrison getVariable [_marker,[]]) + _roles,true];
    };
} forEach (_data # 1);
true
