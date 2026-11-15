// [optional target, optional source] -> [accepted, job name, reason].
// Claim before preparation; no public task exists until the complete horde moves.
params [["_target","",[""]],["_source","",[""]]];
if (!isServer || {!canSuspend} || {isRemoteExecuted}) exitWith {[false,"","server_scheduled_only"]};
private _available = {
    [west] call A3I_fnc_isActive
    && {!(missionNamespace getVariable ["areOccupantsDefeated",false])}
    && {!(missionNamespace getVariable ["bigAttackInProgress",false])}
    && {!call A3I_fnc_interceptionBusy}
};
if (!call _available) exitWith {[false,"","unavailable"]};
private _routes = [_target,_source] call A3I_fnc_interceptionRoutes;
if (_routes isEqualTo []) exitWith {[false,"","no_route"]};
if (!call _available) exitWith {[false,"","unavailable"]};
private _choices = [A3A_faction_occ,"groupsTierSquads"] call SCRT_fnc_unit_flattenTier;
private _definitions = A3A_faction_occ get "loadouts";
_choices = _choices select {_x isEqualType [] && {_x isNotEqualTo []}
    && {(_x findIf {!(_x isEqualType "") || {_x find "loadouts_occ_" != 0}
        || {!((_x select [13]) in _definitions)}}) == -1}};
if (_choices isEqualTo []) exitWith {[false,"","roles"]};
private _size = [] call A3I_fnc_interceptionSize;
private _roles = [];
while {count _roles < _size} do {_roles append selectRandom _choices};
_roles resize _size;
private _route = selectRandom _routes;
_route params ["_destination","_origin","_end","_start","_distance"];
private _result = [false,"","race"];
isNil {
    if (!call _available || {!([_origin] call A3I_fnc_majorSourceEligible)}
        || {!(_destination in (call A3I_fnc_interceptionLocations))}
        || {!(sidesX getVariable [_destination,sideUnknown] in [west,teamPlayer])}) exitWith {};
    if (isNil "A3I_interceptions") then {A3I_interceptions = createHashMap};
    A3I_interceptionSerial = (missionNamespace getVariable ["A3I_interceptionSerial",0]) + 1;
    private _name = "A3I_HI_" + str A3I_interceptionSerial;
    private _record = createHashMapFromArray [
        ["name",_name],["serial",A3I_interceptionSerial],["context","interception:" + _name],
        ["target",_destination],["source",_origin],["destinationPosition",+_end],
        ["spawnPosition",+_start],["routeDistance",_distance],["size",_size],["roles",_roles],
        ["difficult",random 10 < tierWar],["phase","preparing"],["fault",""],
        ["created",0],["remaining",_size],["missing",0],["killed",0],["arrived",false],
        ["units",[]],["groups",[]],["prepared",false],["retired",false],
        ["settled",false],["outcome","pending"],["taskRegistered",false]
    ];
    A3I_interceptions set [_name,_record];
    _record set ["script",[_record] spawn A3I_fnc_runInterception];
    [_record] call A3I_fnc_watchInterceptionLifecycle;
    _result = [true,_name,""];
};
_result
