// Internal post-capture payment. Native tier maintenance must finish first;
// a busy faction-resource lock defers this entire once-only transaction.
params ["_record"];
if (!isServer || {isRemoteExecuted}) exitWith {false};
if (canSuspend) exitWith {[A3I_fnc_rewardLiberation,_this] call CBA_fnc_directCall};
if (_record getOrDefault ["rewarded",false]) exitWith {true};
if (!(_record getOrDefault ["settled",false]) || {_record get "outcome" != "won"}
    || {!(_record getOrDefault ["cityMaintenanceDone",false])}
    || {missionNamespace getVariable ["resourcesIsChanging",false]}) exitWith {false};
private _rewardTier = _record get "rewardTier";
[west,-10,90] call A3A_fnc_addAggression;
{
    [round (7 * _rewardTier),_x] call A3A_fnc_addScorePlayer;
    [round (75 * _rewardTier),_x] call A3A_fnc_addMoneyPlayer;
} forEach (call SCRT_fnc_misc_getRebelPlayers);
private _commander = missionNamespace getVariable ["theBoss",objNull];
if (!isNull _commander) then {
    [10,_commander] call A3A_fnc_addScorePlayer;
    [round (100 * ((_rewardTier / 3) max 1)),_commander,true] call A3A_fnc_addMoneyPlayer;
};
private _baseReward = ((_record get "population") / 100) * (2 - overallHRGain / 100);
[round _baseReward,round (100 * _baseReward)] call A3A_fnc_resourcesFIA;
_record set ["rewarded",true];
true
