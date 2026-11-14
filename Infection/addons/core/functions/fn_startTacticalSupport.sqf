/* [name, pool, allowance, target, position, reveal, delay, caller=[]]
   -> [accepted, estimated resource cost, reason]. The estimate is telemetry;
   only actual births debit the supplied pool. No caller may prepay this job. */
if !(_this isEqualType [] && {count _this >= 6}) exitWith {[false,0,"invalid_request"]};
params ["_name","_pool","_allowance","_target","_position","_reveal",["_delay",-1],["_caller",[]]];
if (!isServer || {isRemoteExecuted && {remoteExecutedOwner != 2}}) exitWith {[false,0,"server_origin_only"]};
if (!canSuspend) exitWith {[false,0,"scheduled_required"]};
if (!([west] call A3I_fnc_isActive) || {missionNamespace getVariable ["areOccupantsDefeated",false]})
    exitWith {[false,0,"inactive"]};
if !(_name isEqualType "" && {_name != ""} && {count _name <= 128}
    && {_pool in ["attack","defence"]} && {_allowance isEqualType 0} && {finite _allowance} && {_allowance >= 10}
    && {_target isEqualType objNull || {_target isEqualTo false}}
    && {_reveal isEqualType 0} && {finite _reveal} && {_reveal >= 0} && {_reveal <= 1}
    && {_delay isEqualType 0} && {finite _delay} && {_delay >= -1}
    && {_caller isEqualType []} && {count _caller in [0,2,3]}
    && {(_caller findIf {!(_x isEqualType 0) || {!finite _x}}) == -1}) exitWith {[false,0,"invalid_request"]};
if (_target isEqualType objNull && {_target isKindOf "Air"}) exitWith {[false,0,"air_target"]};
private _vehicleAllowance = missionNamespace getVariable ["A3A_balanceVehicleCost",0];
if !(_vehicleAllowance isEqualType 0 && {finite _vehicleAllowance} && {_vehicleAllowance > 0})
    exitWith {[false,0,"allowance"]};
// Native land QRFs are limited to three vehicle allowances. Convert that
// resource ceiling to basic actors, also respecting the caller's exact budget.
private _ceiling = if (_vehicleAllowance >= 640 / 3) then {640} else {3 * _vehicleAllowance};
private _requested = floor ((_allowance min _ceiling min 640) / 10);
private _sources = [_position] call A3I_fnc_tacticalSources;
if (_sources isEqualTo []) exitWith {[false,0,"source"]};
private _chosen = _sources selectRandomWeighted (_sources apply {1 / (((_x # 1) max 100)^2)});
_chosen params ["_source","_distance","_destination"];
private _choices = [A3A_faction_occ,"groupsTierSquads"] call SCRT_fnc_unit_flattenTier;
_choices = _choices select {_x isEqualType [] && {_x isNotEqualTo []}};
if (_choices isEqualTo []) exitWith {[false,0,"roles"]};
private _result = [false,0,"race"];
isNil {
    if (!([west] call A3I_fnc_isActive) || {missionNamespace getVariable ["areOccupantsDefeated",false]}
        || {!([_source] call A3I_fnc_counterattackSourceEligible)}) exitWith {};
    if (isNil "A3I_tacticalSupports") then {A3I_tacticalSupports = createHashMap; A3I_tacticalSerial = 0};
    if (_name in A3I_tacticalSupports) exitWith {_result = [false,0,"pending"]};
    private _resourceName = ["A3A_resourcesDefenceOcc","A3A_resourcesAttackOcc"] select (_pool == "attack");
    private _funds = missionNamespace getVariable [_resourceName,0];
    if !(_funds isEqualType 0 && {finite _funds} && {_funds >= 10}) exitWith {_result = [false,0,"resources"]};
    private _count = _requested min floor (_funds / 10);
    if (_count < 1) exitWith {_result = [false,0,"resources"]};
    private _roles = [];
    while {count _roles < _count} do {_roles append (selectRandom _choices)};
    _roles resize _count;
    A3I_tacticalSerial = A3I_tacticalSerial + 1;
    private _ready = time + (_delay max 0);
    private _record = createHashMapFromArray [
        ["name",_name], ["source",_source], ["pool",_pool], ["context","support:" + str A3I_tacticalSerial],
        ["position",_destination], ["distance",_distance], ["queue",_roles], ["units",[]], ["groups",[]],
        ["planned",_count], ["created",0], ["reveal",_reveal], ["announced",false],
        ["readyAt",_ready], ["spawnDeadline",_ready + 600], ["endTime",_ready + 1800],
        ["searchDeadline",-1], ["outcome","pending"], ["cleanupOrdered",false]
    ];
    A3I_tacticalSupports set [_name,_record];
    // Claim the native one-minute source cooldown. This job ignores its own
    // idle claim while retaining ownership, activation, combat and observer checks.
    [_source,1] call A3A_fnc_addTimeForIdle;
    private _cost = 10 * _count;
    A3A_supportStrikes pushBack [west,"TROOPS",+_position,_ready + 2700,2700,_cost];
    if (_caller isNotEqualTo []) then {A3A_supportSpends pushBack [west,+_caller,+_position,_cost,time]};
    _record set ["script",[_record] spawn A3I_fnc_runTacticalSupport];
    if (isNil "A3I_tacticalWatchdogHandle") then {
        A3I_tacticalWatchdogHandle = [A3I_fnc_tacticalWatchdog,2] call CBA_fnc_addPerFrameHandler;
    };
    _result = [true,_cost,"foot"];
};
_result
