/* Scheduled server replacement for infected chooseAttack. Adapted from
   Ultimate 12.4.2 (MIT): keep HQ proximity, enemy balance and the 10:1 cull,
   then use one walking horde or the native offscreen territory transaction. */
if (!isServer || {!canSuspend} || {isRemoteExecuted && {remoteExecutedOwner != 2}}
    || {!([west] call A3I_fnc_isActive)}
    || {missionNamespace getVariable ["areOccupantsDefeated",false]}
    || {missionNamespace getVariable ["bigAttackInProgress",false]}) exitWith {false};
private _funds = missionNamespace getVariable ["A3A_resourcesAttackOcc",0];
if !(_funds isEqualType 0 && {finite _funds} && {_funds > 0}) exitWith {false};
private _targetsAndWeights = [teamPlayer,west] call A3A_fnc_findAttackTargets;
_targetsAndWeights params ["_targets","_weights"];
private _rebelWeightMultiplier = 1;
if (_targets isNotEqualTo []) then {
    private _total = 0; private _adjusted = 0;
    private _hqPosition = getMarkerPos "Synd_HQ";
    {
        _total = _total + _x;
        private _distance = getMarkerPos (_targets # _forEachIndex # 0) distance2D _hqPosition;
        private _multiplier = linearConversion [3000,8000,_distance,A3A_attackHQProximityMul,1,true];
        _adjusted = _adjusted + _x * _multiplier;
        _weights set [_forEachIndex,_x * _multiplier];
    } forEach _weights;
    _rebelWeightMultiplier = _adjusted / _total;
};
if (gameMode == 1 && {!(missionNamespace getVariable ["areInvadersDefeated",false])}) then {
    private _enemy = [Invaders,west] call A3A_fnc_findAttackTargets;
    if (_enemy # 0 isNotEqualTo []) then {
        private _factor = (0.4 + tierWar / 30 + aggressionOccupants / 200) / _rebelWeightMultiplier;
        _weights = _weights apply {_x * _factor};
        _targets append (_enemy # 0); _weights append (_enemy # 1);
    };
};
if (_targets isEqualTo []) exitWith {false};
private _minimum = selectMax _weights / 10;
private _choices = [];
{
    private _weight = _weights # _forEachIndex;
    if (finite _weight && {_weight > _minimum}) then {_choices append [_x,_weight]};
} forEach _targets;
if (_choices isEqualTo []) exitWith {false};
private _choice = selectRandomWeighted _choices;
_choice params ["_target","_source","","_threat"];
private _owner = sidesX getVariable [_target,sideUnknown];
if (!(_owner in [teamPlayer,Invaders]) || {sidesX getVariable [_source,sideUnknown] != west}) exitWith {false};
if (_owner == Invaders && {spawner getVariable [_target,2] == 2}) exitWith {
    [_choice] call A3I_fnc_simulateMajorAttack
};
private _strength = (round (1 + random 1 + _threat / 1000)) max 1 min 3;
([_target,_source,_strength] call A3I_fnc_startMajorAttack) # 0
