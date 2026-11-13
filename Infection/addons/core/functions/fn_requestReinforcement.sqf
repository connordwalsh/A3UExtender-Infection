/* One routine request per target, selected by the resource cycle or patrolReinf.
   [target, source, requestedCount] -> [accepted, plannedCount, reason]. */
params [["_target","",[""]], ["_source","",[""]], ["_requested",4,[0]]];
if (!isServer || {isRemoteExecuted && {remoteExecutedOwner != 2}})
    exitWith {[false,0,"server_origin_only"]};
if (canSuspend) exitWith {[A3I_fnc_requestReinforcement,_this] call CBA_fnc_directCall};
if (!finite _requested || {_requested < 1} || {floor _requested != _requested})
    exitWith {[false,0,"invalid_request"]};
private _eligible = [_target] call A3I_fnc_reinforcementEligible;
if !(_eligible # 0) exitWith {[false,0,_eligible # 2]};
if (isNil "A3I_reinforcements") then {A3I_reinforcements = createHashMap; A3I_reinforcementSerial = 0};
if (_target in A3I_reinforcements) exitWith {[false,0,"pending"]};
private _sources = [_target] call A3I_fnc_reinforcementSources;
private _index = _sources findIf {_x # 0 == _source};
if (_index == -1) exitWith {[false,0,"source"]};
private _funds = missionNamespace getVariable ["A3A_resourcesDefenceOcc",0];
if !(_funds isEqualType 0 && {finite _funds} && {_funds >= 10}) exitWith {[false,0,"resources"]};
private _count = _requested min 8 min (_eligible # 1) min floor (_funds / 10);
private _groups = [A3A_faction_occ,if (_count > 4) then {"groupsTierSquads"} else {"groupsTierMedium"}] call SCRT_fnc_unit_flattenTier;
if (_groups isEqualTo []) exitWith {[false,0,"roles"]};
private _roles = (selectRandom _groups) select [0,_count];
if (_roles isEqualTo []) exitWith {[false,0,"roles"]};
private _state = spawner getVariable [_target,2];
if (_state == 2) exitWith {
    // Offscreen repair cannot race an active/cleaning controller or a nearby observer.
    if ((!isNil "A3I_sites" && {_target in A3I_sites})
        || {((call A3I_fnc_spawnObservers) findIf {_x distance2D getMarkerPos _target < distanceSPWN1}) != -1}
        || {missionNamespace getVariable ["garrisonIsChanging",false]})
        exitWith {[false,0,"observed_or_busy"]};
    private _roster = +(garrison getVariable [_target,[]]);
    _roster append _roles;
    garrison setVariable [_target,_roster,true];
    [-10 * count _roles,west,"defence"] call A3A_fnc_addEnemyResources;
    if (isNil "A3I_reinforcementCooldowns") then {A3I_reinforcementCooldowns = createHashMap};
    A3I_reinforcementCooldowns set [_target,time + 600];
    [true,count _roles,"virtual"]
};
if (_state != 0) exitWith {[false,0,"suspended"]};
A3I_reinforcementSerial = A3I_reinforcementSerial + 1;
private _record = createHashMapFromArray [
    ["id",A3I_reinforcementSerial], ["target",_target], ["source",_source],
    ["context","reinf:" + str A3I_reinforcementSerial], ["queue",_roles],
    ["units",[]], ["groups",[]], ["stage","approaching"], ["cleanupOrdered",false],
    ["spawnDeadline",time + 600], ["travelDeadline",time + 900 + ((_sources # _index) # 1)]
];
A3I_reinforcements set [_target,_record];
if (isNil "A3I_reinforcementCooldowns") then {A3I_reinforcementCooldowns = createHashMap};
A3I_reinforcementCooldowns set [_target,time + 600];
_record set ["script",[_record] spawn A3I_fnc_runReinforcement];
if (isNil "A3I_reinforcementWatchdogHandle") then {
    A3I_reinforcementWatchdogHandle = [A3I_fnc_reinforcementWatchdog,2] call CBA_fnc_addPerFrameHandler;
};
[true,count _roles,"foot"]
