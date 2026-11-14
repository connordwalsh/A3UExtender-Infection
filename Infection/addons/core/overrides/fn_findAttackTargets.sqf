private _side = _this param [1,sideUnknown,[sideUnknown]];
if (!([_side] call A3I_fnc_isActive)) exitWith {_this call A3I_fnc_originalFindAttackTargets};
[_this param [0,sideUnknown,[sideUnknown]]] call A3I_fnc_majorAttackTargets
