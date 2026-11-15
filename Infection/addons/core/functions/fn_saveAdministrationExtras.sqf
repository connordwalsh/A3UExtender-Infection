// Native saveLoop omits administration icons from its garrison rows.
params [["_plugins",createHashMap,[createHashMap]]];
if (!isServer || {isRemoteExecuted} || {!([west] call A3I_fnc_isActive)}
    || {isNil "garrison"} || {isNil "sidesX"}) exitWith {false};
if (canSuspend) exitWith {[A3I_fnc_saveAdministrationExtras,_this] call CBA_fnc_directCall};
private _rows = [];
{
    if (_x in allMapMarkers && {sidesX getVariable [_x,sideUnknown] == west}) then {
        _rows pushBack [_x,[_x] call A3I_fnc_siteExtraRoster];
    };
} forEach (missionNamespace getVariable ["milAdministrationsX",[]]);
_plugins set ["A3I_administrationExtras",[1,_rows]];
true
