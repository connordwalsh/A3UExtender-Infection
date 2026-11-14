/* [target, source, native strength=1, delay=-1, campaign charge=true]
   -> [accepted, planned actors, reason]. Combine native wave allowances into
   one finite horde; actual births use shared capacity and bounded debt credit. */
params [["_target","",[""]],["_source","",[""]],["_strength",1,[0]],
    ["_delay",-1,[0]],["_campaignCharge",true,[true]],["_mission","",[""]]];
if (!isServer || {!canSuspend} || {isRemoteExecuted && {remoteExecutedOwner != 2}})
    exitWith {[false,0,"server_scheduled_only"]};
if (!([west] call A3I_fnc_isActive) || {missionNamespace getVariable ["areOccupantsDefeated",false]})
    exitWith {[false,0,"inactive"]};
if (!finite _strength || {_strength < 1} || {floor _strength != _strength}
    || {!finite _delay} || {_delay < -1} || {_delay > 600}) exitWith {[false,0,"invalid_request"]};
private _hq = _target == "Synd_HQ";
private _targets = airportsX + outposts + milbases + seaports + factories + resourcesX + citiesX + ["Synd_HQ"];
private _owner = sidesX getVariable [_target,sideUnknown];
if (!(_target in _targets) || {!(_target in allMapMarkers)} || {!(_owner in [teamPlayer,Invaders])}
    || {_target in citiesX && {_owner != teamPlayer}}) exitWith {[false,0,"target"]};
private _petros = missionNamespace getVariable ["petros",objNull];
if (_hq && {_owner != teamPlayer || {isNull _petros} || {!alive _petros}})
    exitWith {[false,0,"hq"]};
private _cost = missionNamespace getVariable ["A3A_balanceVehicleCost",0];
private _scale = missionNamespace getVariable ["A3A_balancePlayerScale",0];
if !(_cost isEqualType 0 && {finite _cost} && {_cost > 0}
    && {_scale isEqualType 0} && {finite _scale} && {_scale > 0}) exitWith {[false,0,"allowance"]};
private _routes = [getMarkerPos _target,[_source],{_this call A3I_fnc_majorSourceEligible}]
    call A3I_fnc_tacticalSources;
if (_routes isEqualTo []) exitWith {[false,0,"source"]};
(_routes # 0) params ["","_distance","_position"];
private _choices = [A3A_faction_occ,"groupsTierSquads"] call SCRT_fnc_unit_flattenTier;
_choices = _choices select {_x isEqualType [] && {_x isNotEqualTo []}};
if (_choices isEqualTo []) exitWith {[false,0,"roles"]};
private _requested = 0;
for "_part" from 1 to (if (_hq) then {1} else {_strength min 3}) do {
    private _slots = if (_hq) then {round (1.5 + random 1 + 2 * (_scale min 20))} else {
        private _n = if (_owner == teamPlayer) then {round (2 + random 1 + 3 * (_scale min 20))}
            else {5 + round random 2};
        _n + ([0,2] select (_part == 1))
    };
    // Bound before multiplying. Each native allowance contributes at most 64
    // actors; the combined horde never has more than 192 planned births.
    _requested = _requested + (if (_slots >= 640 / _cost) then {64} else {floor (_slots * _cost / 10)});
};
if (_requested < 1) exitWith {[false,0,"allowance"]};
private _preparation = if (_delay >= 0) then {_delay} else {
    if (_hq) then {(300 / _scale) min 600} else {[0,300] select (_owner == teamPlayer)}
};
private _result = [false,0,"race"];
isNil {
    if (!([west] call A3I_fnc_isActive) || {missionNamespace getVariable ["areOccupantsDefeated",false]}
        || {sidesX getVariable [_target,sideUnknown] != _owner}
        || {!([_source] call A3I_fnc_majorSourceEligible)}) exitWith {};
    if (missionNamespace getVariable ["bigAttackInProgress",false]
        || {_hq && {missionNamespace getVariable ["HQAttackInProgress",false]}} || {_target in forcedSpawn}
        || {!isNil "A3I_majorGlobalOwner"}) exitWith {_result = [false,0,"pending"]};
    private _taskType = ["rebelAttack","DEF_HQ"] select _hq;
    if (_owner == teamPlayer && {_taskType in (missionNamespace getVariable ["A3A_activeTasks",[]])})
        exitWith {_result = [false,0,"task_pending"]};
    private _funds = missionNamespace getVariable ["A3A_resourcesAttackOcc",0];
    if !(_funds isEqualType 0 && {finite _funds} && {!_campaignCharge || {_funds > 0}})
        exitWith {_result = [false,0,"resources"]};
    if (isNil "A3I_majorAttacks") then {A3I_majorAttacks = createHashMap; A3I_majorSerial = 0};
    if (isNil "A3I_majorSourceCooldowns") then {A3I_majorSourceCooldowns = createHashMap};
    private _roles = [];
    while {count _roles < _requested} do {_roles append selectRandom _choices};
    _roles resize _requested;
    A3I_majorSerial = A3I_majorSerial + 1;
    private _name = "A3I_major_" + str A3I_majorSerial;
    private _ready = time + _preparation;
    private _fixedCost = if (_campaignCharge) then {[400,200] select (_target in citiesX)} else {0};
    private _record = createHashMapFromArray [
        ["name",_name],["context","major:" + str A3I_majorSerial],["target",_target],["source",_source],
        ["targetOwner",_owner],["hq",_hq],["petros",_petros],["hqPosition",getMarkerPos "Synd_HQ"],
        ["position",_position],["distance",_distance],["planned",_requested],["queue",_roles],
        ["creditRemaining",_requested],["paidActors",0],["units",[]],["groups",[]],
        ["readyAt",_ready],["emptyDeadline",_ready + 600],["endTime",_ready + 2700],
        ["arrived",false],["outcome","pending"],["fixedCost",_fixedCost],
        ["mission",_mission],
        ["taskId",_name],["taskType",_taskType],["taskRegistered",false],
        ["settled",false],["released",false],["cleanupOrdered",false]
    ];
    A3I_majorAttacks set [_name,_record];
    A3I_majorGlobalOwner = _name;
    bigAttackInProgress = true; publicVariable "bigAttackInProgress";
    if (_hq) then {HQAttackInProgress = true; publicVariable "HQAttackInProgress"};
    forcedSpawn pushBack _target; publicVariable "forcedSpawn";
    A3I_majorSourceCooldowns set [_source,time + 600];
    if (_source in (airportsX + outposts + milbases)) then {[_source,10] call A3A_fnc_addTimeForIdle};
    if (_fixedCost > 0) then {[-_fixedCost,west,"attack"] call A3A_fnc_addEnemyResources};
    A3A_supportStrikes pushBack [west,"TROOPS",+_position,_ready + 2700,2700,10 * _requested];
    _record set ["script",[_record] spawn A3I_fnc_runMajorAttack];
    if (isNil "A3I_majorWatchdogHandle") then {
        A3I_majorWatchdogHandle = [A3I_fnc_majorWatchdog,2] call CBA_fnc_addPerFrameHandler;
    };
    _result = [true,_requested,"horde"];
};
_result
