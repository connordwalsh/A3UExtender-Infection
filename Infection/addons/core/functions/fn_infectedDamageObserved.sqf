// Observe attacks without returning a damage value or adding a revive handler.
// Based on Ultimate handleDamageAAF's site contact-report bookkeeping.
params ["_unit", "_part", "_damage", "_injurer"];
if (!local _unit || {_part != ""} || {isNull _injurer} || {side group _injurer != teamPlayer}) exitWith {nil};
private _marker = _unit getVariable ["markerX", ""];
if (_marker == "" || {isNil "garrison"} || {isNil "sidesX"}) exitWith {nil};
if (sidesX getVariable [_marker, sideUnknown] != west) exitWith {nil};
private _lastAttack = garrison getVariable [_marker + "_lastAttack", -31];
if (_lastAttack + 30 < serverTime) then {
    garrison setVariable [_marker + "_lastAttack", serverTime, true];
    [_marker, teamPlayer, west, false, _injurer getVariable ["isRival", false]]
        remoteExec ["A3A_fnc_underAttack", 2];
};
nil
