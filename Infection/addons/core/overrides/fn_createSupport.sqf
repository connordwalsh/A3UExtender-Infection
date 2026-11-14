private _side = _this param [1,sideUnknown];
if (_side isEqualType west && {[_side] call A3I_fnc_isActive}) exitWith {
    if (count _this < 7) exitWith {""};
    _this call A3I_fnc_requestTacticalSupport
};
// Two installed mission callers still use [position, count, types, side, reveal].
// Refuse that malformed Infection call; mission adaptation owns its replacement.
private _legacySide = if (count _this == 5 && {(_this # 0) isEqualType []}) then {
    _this param [3,sideUnknown]
} else {sideUnknown};
if (_legacySide isEqualType west && {[_legacySide] call A3I_fnc_isActive}) exitWith {""};
_this call A3I_fnc_originalCreateSupport
