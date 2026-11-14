// The aggression loop consumes this Boolean to apply its native retry pacing.
private _side = _this param [0,sideUnknown,[sideUnknown]];
if (!([_side] call A3I_fnc_isActive)) exitWith {_this call A3I_fnc_originalChooseAttack};
call A3I_fnc_chooseMajorAttack
