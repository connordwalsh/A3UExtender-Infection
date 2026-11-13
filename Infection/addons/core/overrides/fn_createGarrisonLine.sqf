// Preserve the installed Ultimate implementation for every other faction/side.
params ["_data", "_side"];
if !([_side] call A3I_fnc_isActive) exitWith {
    _this call A3I_fnc_originalCreateGarrisonLine
};
[_data] call A3I_fnc_createFootGarrisonLine
