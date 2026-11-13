// Difference between two valid Arma calendar dates. Subtract integer day counts
// before converting to minutes to avoid loss of precision in large timestamps.
params ["_start","_finish"];
private _dayNumber = {
    params ["_year","_month","_day"];
    private _priorYear = _year - 1;
    private _days = 365 * _priorYear + floor (_priorYear / 4) - floor (_priorYear / 100) + floor (_priorYear / 400);
    private _months = [0,31,59,90,120,151,181,212,243,273,304,334];
    _days = _days + (_months # (_month - 1)) + _day;
    if (_month > 2 && {_year mod 4 == 0} && {_year mod 100 != 0 || {_year mod 400 == 0}}) then {_days = _days + 1};
    _days
};
((_finish call _dayNumber) - (_start call _dayNumber)) * 1440
    + ((_finish # 3) - (_start # 3)) * 60 + (_finish # 4) - (_start # 4)
