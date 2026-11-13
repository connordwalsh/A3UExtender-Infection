private _marker = _this param [0,"",[""]];
if (!isNil "sidesX" && {[sidesX getVariable [_marker,sideUnknown]] call A3I_fnc_isActive}) exitWith {
    [_marker,"Resource"] call A3I_fnc_startSite;
};
_this call A3I_fnc_originalCreateAIResources
