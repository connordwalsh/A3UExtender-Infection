// Exact native parked-car count, separate from road-placement success.
// [population, road entries, war level, civTraffic multiplier, time of day].
params [["_population",-1,[0]],["_roads",-1,[0]],["_war",-1,[0]],
    ["_traffic",-1,[0]],["_hour",-1,[0]]];
if ((_this findIf {!(_x isEqualType 0) || {!finite _x}}) != -1
    || {_population < 0} || {_roads < 0} || {_roads != floor _roads}
    || {_war < 0} || {_war > 10} || {_traffic < 0} || {_hour < 0} || {_hour >= 24}) exitWith {-1};
if (_roads == 0) exitWith {0};
private _count = 15 * sqrt _population * (1 - _war / 20) * (1/60) * _traffic;
if (_hour < 8 || {_hour > 21}) then {_count = _count * 1.5};
// Native behavior retains a minimum of one, even with a zero traffic multiplier.
1 max (round _count) min _roads
