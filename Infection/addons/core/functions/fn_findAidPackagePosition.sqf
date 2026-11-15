if (!isServer || {isRemoteExecuted}) exitWith {[]};
private _hq = missionNamespace getVariable ["respawnTeamPlayer",""];
if !(_hq in allMapMarkers) exitWith {[]};
private _result = [];
for "_attempt" from 0 to 31 do {
    private _position = (getMarkerPos _hq) getPos [4+random 36,random 360];
    _position set [2,0];
    _position = _position findEmptyPosition [0,8,"Land_FoodSacks_01_cargo_brown_F"];
    if ([_position] call A3I_fnc_aidPackagePositionSafe) exitWith {_result = _position};
};
_result
