// Internal scene factory; caller owns actors and must register task/ledger/actions.
// [source marker, optional desired 2..6] -> [units, group, failure reason].
params [["_marker","",[""]],["_desired",0,[0]],["_afterCreate",{true},[{}]]];
if (!isServer || {isRemoteExecuted} || {!canSuspend}) exitWith {[[],grpNull,"scheduled_server_only"]};
if (_desired == 0) then {_desired = 2 + floor random 5};
private _role = (missionNamespace getVariable ["A3A_faction_reb",createHashMap]) getOrDefault ["unitUnarmed",""];
if (!(_role isEqualType "") || {_role == ""} || {isNil "A3A_customUnitTypes"}
    || {!(isClass (configFile >> "CfgVehicles" >> _role) || {!isNil {A3A_customUnitTypes getVariable _role}})})
    exitWith {[[],grpNull,"unarmed_role_unavailable"]};
if (isClass (configFile >> "CfgVehicles" >> _role)
    && {!(_role isKindOf ["CAManBase",configFile >> "CfgVehicles"])})
    exitWith {[[],grpNull,"unarmed_role_unavailable"]};
private _shelter = [_marker,_desired] call A3I_fnc_findExtractionShelter;
if (isNull (_shelter # 0) || {count (_shelter # 1) < 2}) exitWith {[[],grpNull,"no_safe_shelter"]};
private _result = [[],grpNull,"scene_changed"];
isNil {
    if (!alive (_shelter # 0) || {!(_marker in (call A3I_fnc_extractionLocations))}) exitWith {};
    private _hq = missionNamespace getVariable ["respawnTeamPlayer",""];
    if !(_hq in allMapMarkers) exitWith {};
    private _observers = call A3I_fnc_spawnObservers;
    private _points = [];
    {
        private _safe = [_x,_observers,getMarkerPos _hq] call A3I_fnc_indoorPosition;
        if (_safe # 0 && {(_safe # 1) inArea _marker}) then {_points pushBack (_safe # 1)};
    } forEach (_shelter # 1);
    if (count _points < 2) exitWith {};
    private _group = createGroup [teamPlayer,true];
    if (isNull _group) exitWith {_result = [[],grpNull,"group_creation_failed"]};
    private _units = [];
    {
        private _unit = [_group,_role,_x,[],0,"NONE"] call A3A_fnc_createUnit;
        if (isNull _unit) exitWith {};
        _units pushBack _unit;
        if (!alive _unit || {!(_unit isKindOf "CAManBase")}
            || {_unit getVariable ["WBK_AI_ISZombie",false]}) exitWith {};
        [_unit] joinSilent _group;
        _unit setPosATL _x;
        _unit setCaptive true;
        {_unit disableAI _x} forEach ["MOVE","AUTOTARGET","TARGET"];
        _unit setUnitPos "UP"; _unit setBehaviour "CARELESS"; _unit allowFleeing 0;
        removeAllWeapons _unit; removeAllAssignedItems _unit;
        [_unit] call A3A_fnc_reDress;
    } forEach _points;
    if (count _units != count _points || {(_units findIf {!alive _x || {!(_x isKindOf "CAManBase")}
        || {side group _x != teamPlayer} || {_x getVariable ["WBK_AI_ISZombie",false]}}) != -1}) exitWith {
        {deleteVehicle _x} forEach _units; deleteGroup _group;
        _result = [[],grpNull,"unit_creation_failed"];
    };
    private _registered = [_units,_group] call _afterCreate;
    if (isNil "_registered" || {!(_registered isEqualTo true)}) exitWith {
        {deleteVehicle _x} forEach _units; deleteGroup _group;
        _result = [[],grpNull,"registration_failed"];
    };
    _result = [_units,_group,""];
};
_result
