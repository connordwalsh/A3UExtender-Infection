/* [ordinary capture candidates, all nearby permanent targets]
   -> [ordinary candidates, available competitive candidates, unavailable races].
   Keep native ordinary-faction frontlines. Towns also provide infected frontlines.
   A refused infected race must not fall back to the same ordinary capture. */
params ["_ordinary","_nearby"];
private _available = []; private _unavailable = [];
private _origins = airportsX + outposts + milbases + seaports + factories + resourcesX + citiesX
    + (missionNamespace getVariable ["milAdministrationsX",[]]);
_origins = (_origins arrayIntersect _origins) select {
    _x in allMapMarkers && {sidesX getVariable [_x,sideUnknown] == west}
};
{
    private _target = _x;
    private _frontline = [_target] call A3A_fnc_isFrontlineNoFIA;
    if (sidesX getVariable [_target,sideUnknown] == Invaders && {[west] call A3I_fnc_isActive}) then {
        private _position = getMarkerPos _target;
        _frontline = _frontline || {(_origins findIf {
            getMarkerPos _x distance2D _position <= (distanceForLandAttack min 2000)
        }) != -1};
        if (!_frontline) then {continue};
        if (([_target] call A3I_fnc_competitiveSources) isEqualTo []) then {
            _unavailable pushBackUnique _target;
        } else {_available pushBackUnique _target};
    } else {
        if (_frontline) then {_available pushBackUnique _target};
    };
} forEach (_nearby arrayIntersect _nearby);
[_ordinary - _unavailable,_available,_unavailable]
