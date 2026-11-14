// Ownership alone cannot manufacture success: only the atomic capture adapter
// records a win. Russian/unknown ownership cancels without a penalty.
params ["_record"];
if (!isServer || {isRemoteExecuted}) exitWith {"pending"};
if (_record get "outcome" != "pending") exitWith {_record get "outcome"};
private _target = _record get "target";
if (!([west] call A3I_fnc_isActive) || {isNil "sidesX"} || {!(_target in allMapMarkers)}
    || {sidesX getVariable [_target,sideUnknown] != west}) exitWith {"cancelled"};
if (dateToNumber date > _record get "deadline") exitWith {"timeout"};
private _clearance = [_target] call A3I_fnc_siteClearance;
if (_clearance # 1 in ["site_fault","missing_defender"]) exitWith {"cancelled"};
"pending"
