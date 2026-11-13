// Bounded, atomic creation/registering of captives and optional native loot.
// Survivor count is limited by distinct checked positions, never overlapping cells.
params ["_marker","_record"];
if (!isServer || {isRemoteExecuted && {remoteExecutedOwner != 2}}) exitWith {};
if (canSuspend) exitWith {[A3I_fnc_administrationAssets,_this] call CBA_fnc_directCall};
if (_record getOrDefault ["assetsCreated",false]) exitWith {};
_record set ["assetsCreated",true];
private _building = _record get "building";
private _hqMarker = missionNamespace getVariable ["respawnTeamPlayer",""];
if (!alive _building || {!(_hqMarker in allMapMarkers)}) exitWith {};
private _hq = getMarkerPos _hqMarker;
private _observers = call A3I_fnc_spawnObservers;
private _positions = [_building] call A3I_fnc_administrationPositions;
private _role = A3A_faction_reb getOrDefault ["unitUnarmed",""];
private _cooldown = garrison getVariable [_marker + "_powCD",0];
if (_role isEqualType "" && {_role != ""} && {time >= _cooldown}
    && {isClass (configFile >> "CfgVehicles" >> _role) || {!isNil {A3A_customUnitTypes getVariable _role}}}) then {
    private _group = createGroup [teamPlayer,true];
    (_record get "groups") pushBack _group;
    private _requested = (floor (random [1,3,5])) + 1;
    private _chosen = [];
    {
        if (count _chosen >= _requested) exitWith {};
        private _safe = [_x,_observers,_hq] call A3I_fnc_indoorPosition;
        if !(_safe # 0) then {continue};
        private _position = _safe # 1;
        if ((_chosen findIf {_x distance _position < 1.5}) != -1) then {continue};
        private _unit = [_group,_role,_position,[],0,"NONE"] call A3A_fnc_createUnit;
        if (isNull _unit) then {continue};
        (_record get "civilians") pushBack _unit;
        _chosen pushBack _position;
        [_unit] joinSilent _group;
        _unit setPosATL _position;
        _unit setVariable ["A3I_survivor",true,true];
        _unit setVariable ["A3I_survivorState","waiting",true];
        _unit setVariable ["A3I_survivorMarker",_marker];
        _unit setVariable ["A3I_survivorId",_record get "id"];
        _unit setCaptive true;
        {_unit disableAI _x} forEach ["MOVE","AUTOTARGET","TARGET"];
        _unit setUnitPos "UP";
        _unit setBehaviour "CARELESS";
        _unit allowFleeing 0;
        removeAllWeapons _unit;
        removeAllAssignedItems _unit;
        [_unit] call A3A_fnc_reDress;
        [_unit] remoteExec ["A3I_fnc_survivorAction",[teamPlayer,civilian],_unit];
    } forEach (_positions # 0);
    if (count units _group == 0) then {deleteGroup _group};
};
if (garrison getVariable [_marker + "_lootCD",0] != 0) exitWith {};
private _class = A3A_faction_occ get "equipmentBox";
private _cratePosition = [];
{
    private _safe = [_x,_observers,_hq] call A3I_fnc_indoorPosition;
    if (_safe # 0) exitWith {_cratePosition = _safe # 1};
} forEach (_positions # 1);
if (_cratePosition isEqualTo []) exitWith {};
private _crate = createVehicle [_class,_cratePosition vectorAdd [0,0,0.1],[],0,"CAN_COLLIDE"];
if (isNull _crate) exitWith {};
(_record get "crates") pushBack _crate;
_crate setDir getDir _building;
_crate addEventHandler ["Killed", {[_this # 0] spawn {sleep 10;deleteVehicle (_this # 0)}}];
private _players = count (allPlayers - entities "HeadlessClient_F");
// Preserve all three native administration loot selections and player scaling.
private _contents = selectRandom [
    [_crate,2,_players,0,0,1,round (random [6,8,9]),0,0,0,0,0,0,0,0,1,_players,0,0],
    [_crate,3,_players,0,0,1,round (random [4,5,7]),0,0,0,0,0,0,0,0,0,0,0],
    [_crate,4,_players,0,0,1,round (random [6,8,9]),1,1,0,0,0,0,1,0,0,_players,0,0]
];
_contents call A3A_fnc_fillLootCrate;
[_crate,nil,true] call A3A_Logistics_fnc_addLoadAction;
[_crate] remoteExec ["SCRT_fnc_common_addActionMove",[teamPlayer,civilian],_crate];
