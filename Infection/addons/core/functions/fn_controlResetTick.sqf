// Generated controls retain Ultimate's 120 campaign-minute reset after despawn.
// A later ownership change cancels this old reset; active locations wait for cleanup.
if (!isServer || {isRemoteExecuted}) exitWith {};
if (isNil "A3I_controlResets") exitWith {};
{
    private _marker = _x;
    (A3I_controlResets get _marker) params ["_started","_winner"];
    if !(_marker in controlsX && {_marker in allMapMarkers}
        && {sidesX getVariable [_marker,sideUnknown] == _winner}
        && {[west] call A3I_fnc_isActive}) then {
        A3I_controlResets deleteAt _marker;
    } else {
        if ([_started,date] call A3I_fnc_elapsedDateMinutes >= 120
            && {spawner getVariable [_marker,2] == 2}) then {
            private _main = markersX - controlsX;
            if (_main isNotEqualTo []) then {
                private _base = [_main,getMarkerPos _marker] call BIS_fnc_nearestPosition;
                private _side = sidesX getVariable [_base,sideUnknown];
                if (_side in [Occupants,Invaders]) then {sidesX setVariable [_marker,_side,true]};
            };
            A3I_controlResets deleteAt _marker;
        };
    };
} forEach keys A3I_controlResets;
