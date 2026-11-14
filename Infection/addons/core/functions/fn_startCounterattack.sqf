/* [captured marker, native vehicle-count allowance, reveal] -> [accepted, count, reason].
   Native markerChange already records an estimated support spend/strike. It does
   not debit funds; only successfully created actors are paid here, ten each. */
params [["_target","",[""]], ["_vehicleCount",0,[0]], ["_reveal",0,[0]]];
if (!isServer || {isRemoteExecuted && {remoteExecutedOwner != 2}}) exitWith {[false,0,"server_origin_only"]};
if (!canSuspend) exitWith {[false,0,"scheduled_required"]};
if (!finite _vehicleCount || {_vehicleCount < 1} || {floor _vehicleCount != _vehicleCount}
    || {!finite _reveal} || {_reveal < 0} || {_reveal > 1}) exitWith {[false,0,"invalid_request"]};
private _eligible = [_target] call A3I_fnc_counterattackEligible;
if !(_eligible # 0) exitWith {[false,0,_eligible # 2]};
private _allowance = missionNamespace getVariable ["A3A_balanceVehicleCost",0];
if !(_allowance isEqualType 0 && {finite _allowance} && {_allowance > 0}) exitWith {[false,0,"allowance"]};
// Bound the conversion before multiplication, even for an excessive caller value.
private _requested = if (_vehicleCount >= 640 / _allowance) then {64} else {floor (_vehicleCount * _allowance / 10)};
private _sources = [_target] call A3I_fnc_counterattackSources;
if (_sources isEqualTo []) exitWith {[false,0,"source"]};
private _weights = _sources apply {1 / (((_x # 1) max 100)^2)};
private _chosen = _sources selectRandomWeighted _weights;
_chosen params ["_source","_distance","_position"];
private _choices = [A3A_faction_occ,"groupsTierSquads"] call SCRT_fnc_unit_flattenTier;
_choices = _choices select {_x isEqualType [] && {_x isNotEqualTo []}};
if (_choices isEqualTo []) exitWith {[false,0,"roles"]};
private _result = [false,0,"race"];
isNil {
    private _current = [_target] call A3I_fnc_counterattackEligible;
    if (!(_current # 0) || {_current # 1 != _eligible # 1} || {!([_source] call A3I_fnc_counterattackSourceEligible)}) exitWith {};
    if (isNil "A3I_counterattacks") then {A3I_counterattacks = createHashMap; A3I_counterattackSerial = 0};
    if (_target in A3I_counterattacks) exitWith {_result = [false,0,"pending"]};
    private _funds = missionNamespace getVariable ["A3A_resourcesDefenceOcc",0];
    if !(_funds isEqualType 0 && {finite _funds} && {_funds >= 10}) exitWith {_result = [false,0,"resources"]};
    private _count = _requested min floor (_funds / 10);
    if (_count < 1) exitWith {_result = [false,0,"resources"]};
    private _roles = [];
    while {count _roles < _count} do {_roles append (selectRandom _choices)};
    _roles resize _count;
    A3I_counterattackSerial = A3I_counterattackSerial + 1;
    private _record = createHashMapFromArray [
        ["source",_source], ["target",_target], ["targetOwner",_current # 1],
        ["context","counter:" + str A3I_counterattackSerial], ["queue",_roles],
        ["units",[]], ["groups",[]], ["position",_position], ["distance",_distance], ["reveal",_reveal],
        ["created",0], ["announced",false], ["outcome","pending"], ["cleanupOrdered",false],
        ["spawnDeadline",time + 600], ["endTime",time + 2700], ["handoffDeadline",-1]
    ];
    A3I_counterattacks set [_target,_record];
    if (isNil "A3I_counterattackCooldowns") then {A3I_counterattackCooldowns = createHashMap};
    A3I_counterattackCooldowns set [_target,time + 600];
    _record set ["script",[_record] spawn A3I_fnc_runCounterattack];
    if (isNil "A3I_counterattackWatchdogHandle") then {
        A3I_counterattackWatchdogHandle = [A3I_fnc_counterattackWatchdog,2] call CBA_fnc_addPerFrameHandler;
    };
    _result = [true,_count,"foot"];
};
_result
