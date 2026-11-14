private _side = _this param [1,sideUnknown];
if (_side isEqualType west && {[_side] call A3I_fnc_isActive}) exitWith {
    if (count _this < 7) exitWith {-1};
    if ((_this # 0) isEqualType "" && {(_this # 0) find "REBUILD_QRF_" == 0})
        exitWith {_this call A3I_fnc_routeRebuildSupport};
    private _arguments = +_this;
    _arguments deleteAt 1;
    private _result = _arguments call A3I_fnc_startTacticalSupport;
    if (_result # 0) then {_result # 1} else {-1}
};
_this call A3I_fnc_originalSUPQRFLand
