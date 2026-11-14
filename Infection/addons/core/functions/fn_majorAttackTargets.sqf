/* Scheduled server planning for infected major attacks.
   [target side] -> [targets, weights], retaining Ultimate's six-field target
   record: [target, origin, value, local threat, flyover threat, ground sources].
   Adapted from Ultimate 12.4.2 findAttackTargets (MIT). No campaign dispatch here. */
params [["_targetSide",sideUnknown,[sideUnknown]]];
if (!isServer || {!canSuspend} || {isRemoteExecuted && {remoteExecutedOwner != 2}}
    || {!([west] call A3I_fnc_isActive)} || {!(_targetSide in [teamPlayer,Invaders])}
    || {missionNamespace getVariable ["areOccupantsDefeated",false]}) exitWith {[[],[]]};
private _origins = (airportsX + outposts + milbases) arrayIntersect (airportsX + outposts + milbases);
_origins = _origins select {[_x] call A3I_fnc_counterattackSourceEligible};
if (_origins isEqualTo []) exitWith {[[],[]]};
private _targets = airportsX + outposts + seaports + factories + resourcesX + milbases;
if (_targetSide == teamPlayer) then {_targets append citiesX};
_targets = _targets select {_x in allMapMarkers && {sidesX getVariable [_x,sideUnknown] == _targetSide}};
if (_targetSide == teamPlayer && {"Synd_HQ" in allMapMarkers}
    && {A3A_curHQInfoOcc >= 1}) then {_targets pushBackUnique "Synd_HQ"};
_targets = _targets arrayIntersect _targets;
if (_targets isEqualTo []) exitWith {[[],[]]};
private _markersXYT = [];
{
    if !(_x in allMapMarkers) then {continue};
    private _owner = sidesX getVariable [_x,sideUnknown];
    if (_owner == west || {gameMode != 1 && {_owner != _targetSide}}) then {continue};
    private _threat = 10 * count (garrison getVariable [_x,[]]);
    if (_owner == teamPlayer) then {
        _threat = _threat + 50 * count (staticsToSave inAreaArray _x);
    } else {
        _threat = _threat + (switch (true) do {
            case (_x in controlsX || {_x in seaports}): {50};
            case (_x in outposts): {150};
            case (_x in milbases): {350};
            case (_x in airportsX): {600};
            default {0};
        });
    };
    if (_threat > 0) then {_markersXYT pushBack [getMarkerPos _x # 0,getMarkerPos _x # 1,_threat]};
} forEach markersX;
private _players = allPlayers - entities "HeadlessClient_F";
private _rebelSpawners = (units teamPlayer - _players) select {_x getVariable ["spawner",false]};
private _radioTowers = antennas + antennasDead;
private _noReadyAirport = (_origins findIf {_x in airportsX}) == -1;
private _maximum = distanceForLandAttack min 2000;
if (_maximum <= 0) exitWith {[[],[]]};
private _result = [];
private _resultWeights = [];
{
    private _target = _x;
    private _position = getMarkerPos _target;
    private _routes = [_position] call A3I_fnc_tacticalSources;
    _routes = _routes select {_x # 0 in _origins};
    _routes = _routes arrayIntersect _routes;
    if (_routes isEqualTo []) then {continue};
    // Preserve the original target values, including population-based towns and
    // the airport priority when no ready airport remains. No supply convoy route.
    private _value = 0;
    if (_target in citiesX) then {
        private _data = [_target] call A3A_fnc_getCityData;
        private _population = _data param [0,-1];
        if (_population isEqualType 0 && {finite _population} && {_population >= 0}) then {
            _value = sqrt _population * (1.5 - tierWar / 10);
        };
    } else {
        private _base = switch (true) do {
            case (_target in outposts): {[20,25] select (count (_radioTowers inAreaArray _target) > 0)};
            case (_target == "Synd_HQ"): {60};
            case (_target in seaports): {20};
            case (_target in milbases): {40};
            case (_target in airportsX): {[60,90] select _noReadyAirport};
            case (_target in factories): {15};
            default {10};
        };
        _value = _base + ([_target,true] call A3A_fnc_garrisonSize) / 2;
    };
    if (!finite _value || {_value <= 0}) then {continue};
    private _localThreat = 0;
    {
        _localThreat = _localThreat + (_x # 2) * linearConversion [500,1500,_x distance2D _position,1,0,true];
    } forEach (_markersXYT inAreaArray [_position,1500,1500]);
    _localThreat = _localThreat + (if (_targetSide == teamPlayer) then {150} else {
        30 * count (_players inAreaArray [_position,500,500])
    });
    _localThreat = _localThreat + 10 * count (_rebelSpawners inAreaArray [_position,500,500]);
    // Empty enemy economic sites still have finite difficulty; do not produce
    // infinite weights when the native garrison/static threat is zero.
    private _difficultyThreat = _localThreat max 1;
    private _countLand = count _routes;
    private _weights = [];
    {
        _x params ["_origin","_roadDistance"];
        private _distanceFactor = linearConversion [0,_maximum + 500,_roadDistance,0.5,1.5,true];
        private _difficulty = _difficultyThreat * (_distanceFactor + 3^(-_countLand));
        private _weight = (_value / _difficulty^0.8)^2;
        _weights pushBack _weight;
        _result pushBack [_target,_origin,_value,_localThreat,0,_countLand];
    } forEach _routes;
    // Native normalization prevents extra origins alone raising target priority.
    private _sum = 0; {_sum = _sum + _x} forEach _weights;
    private _maximumWeight = selectMax _weights;
    {_resultWeights pushBack (10 * _x * _maximumWeight / _sum)} forEach _weights;
} forEach _targets;
[_result,_resultWeights]
