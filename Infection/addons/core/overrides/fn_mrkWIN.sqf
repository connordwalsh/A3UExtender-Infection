private _flag = _this param [0,objNull,[objNull]];
private _blocked = false;
if (!isNull _flag && {[west] call A3I_fnc_isActive}) then {
    private _locations = [];
    {_locations append (missionNamespace getVariable [_x,[]])} forEach ["airportsX","resourcesX","factories","outposts","seaports","milbases"];
    if (_locations isNotEqualTo []) then {
        private _marker = [_locations,getPosATL _flag] call BIS_fnc_nearestPosition;
        _blocked = [_marker] call A3I_fnc_siteCaptureBlocked;
    };
};
if (_blocked) exitWith {
    ["Capture location","More infected defenders remain nearby. Clear the arriving groups before taking the flag."] call SCRT_fnc_misc_deniedHint;
};
_this call A3I_fnc_originalMrkWIN
