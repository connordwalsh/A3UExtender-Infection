private _side = _this param [1,sideUnknown];
if (_side isEqualType west && {[_side] call A3I_fnc_isActive}) exitWith {
    if (count _this < 7) exitWith {""};
    _this call A3I_fnc_requestTacticalSupport
};
// Two installed mission callers still use a five-argument, side-first form.
// Refuse that malformed Infection call rather than guessing its old meaning.
private _legacySide = _this param [0,sideUnknown];
if (_legacySide isEqualType west && {[_legacySide] call A3I_fnc_isActive}) exitWith {""};
_this call A3I_fnc_originalCreateSupport
