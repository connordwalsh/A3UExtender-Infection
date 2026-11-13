// Called once for the infected side by Ultimate's existing 600-second cycle.
if (!isServer || {isRemoteExecuted && {remoteExecutedOwner != 2}} || {!([west] call A3I_fnc_isActive)}) exitWith {};
private _funds = missionNamespace getVariable ["A3A_resourcesDefenceOcc",0];
if !(_funds isEqualType 0 && {finite _funds} && {_funds >= 10}) exitWith {};
private _remaining = (4 * round (0.1 * _funds / 40)) min floor (_funds / 10);
private _targets = [];
{
    private _eligible = [_x] call A3I_fnc_reinforcementEligible;
    if (_eligible # 0) then {_targets pushBack [(_eligible # 1) / ([_x] call A3A_fnc_garrisonSize),_x]};
} forEach (airportsX + outposts + seaports + resourcesX + factories + milbases);
_targets sort false;
{
    if (_remaining <= 0) exitWith {};
    private _target = _x # 1;
    private _sources = [_target] call A3I_fnc_reinforcementSources;
    if (_sources isEqualTo []) then {continue};
    private _weights = _sources apply {1 / (((_x # 1) max 100)^2)};
    private _source = (_sources selectRandomWeighted _weights) # 0;
    private _requested = (if (_remaining >= 8 && {random 1 > 0.3}) then {8} else {4}) min _remaining;
    private _result = [_target,_source,_requested] call A3I_fnc_requestReinforcement;
    if (_result # 0) then {_remaining = _remaining - (_result # 1)};
} forEach _targets;
