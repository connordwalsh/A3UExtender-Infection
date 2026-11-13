params [["_building",objNull,[objNull]], ["_cause","CAPTURE",[""]]];
private _marker = "";
if (!isNull _building && {!isNil "A3A_milAdministrations"} && {_building in A3A_milAdministrations}
    && {!isNil "milAdministrationsX"}) then {
    private _index = milAdministrationsX findIf {getMarkerPos _x distance2D _building < 30};
    if (_index != -1) then {_marker = milAdministrationsX # _index};
};
if (_marker == "" || {isNil "sidesX"}
    || {!([sidesX getVariable [_marker,sideUnknown]] call A3I_fnc_isActive)})
    exitWith {_this call A3I_fnc_originalRemoveMilAdmin};
if (!isServer || {isRemoteExecuted && {remoteExecutedOwner != 2}}) exitWith {false};
// Loading completed sites is a server operation, not a client capture bypass.
if (_cause == "LOADSTAT") exitWith {_this call A3I_fnc_originalRemoveMilAdmin};
if (_cause == "DESTROY") exitWith {
    if (!alive _building && {!(_building getVariable ["A3I_destructionAccounted",false])}) then {
        _building setVariable ["A3I_destructionAccounted",true];
        // Preserve destruction aggression once. Foot response routing is a later
        // integration gate; the native aircraft/vehicle calls are not compatible.
        [west,15,60] remoteExec ["A3A_fnc_addAggression",2];
    };
    false
};
if (_cause in ["CAPTURE","SILENT"]) exitWith {[_marker] call A3I_fnc_tryCaptureAdministration};
false
