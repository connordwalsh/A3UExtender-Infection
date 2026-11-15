/* Internal asset creation: [kind, ATL position, heading, optional class]
   -> [vehicle or objNull, reason]. The mission owner must retain/clean its asset.
   No infected crew, task, extra loot, enemy cost or automatic despawner. */
params [["_kind","",[""]],["_position",[],[[]]],
    ["_heading",0,[0]],["_class","",[""]]];
if (!isServer || {isRemoteExecuted}) exitWith {[objNull,"server_local_only"]};
if (canSuspend) exitWith {[A3I_fnc_createSupplyTruck,_this] call CBA_fnc_directCall};
if (!([west] call A3I_fnc_isActive)) exitWith {[objNull,"inactive"]};
private _classes = [_kind] call A3I_fnc_supplyTruckClasses;
if (_classes isEqualTo []) exitWith {[objNull,"truck_pool"]};
if (_class == "") then {_class = selectRandom _classes};
if (!(_class in _classes) || {!finite _heading}) exitWith {[objNull,"class_or_heading"]};
// Native skin initialization needs the compiled faction maps. sideUnknown
// cannot be passed directly to AIVEHinit because it is not a faction template.
private _civilian = missionNamespace getVariable ["A3A_faction_civ",createHashMap];
if (!(_civilian isEqualType createHashMap)
    || {!((_civilian getOrDefault ["animations",[]]) isEqualType createHashMap)}
    || {!((_civilian getOrDefault ["variants",[]]) isEqualType createHashMap)}
    || {isNil "serverInitDone"} || {!serverInitDone}) exitWith {[objNull,"campaign_not_ready"]};
private _hq = missionNamespace getVariable ["respawnTeamPlayer",""];
if !(_hq in allMapMarkers) exitWith {[objNull,"hq_unavailable"]};
private _safe = [_position,_class,call A3I_fnc_spawnObservers,getMarkerPos _hq] call A3I_fnc_positionSafety;
if !(_safe # 0) exitWith {[objNull,_safe # 1]};
private _vehicle = createVehicle [_class,_position,[],0,"NONE"];
if (isNull _vehicle) exitWith {[objNull,"creation_failed"]};
if (!alive _vehicle || {_vehicle distance2D _position > 0.5}) exitWith {
    deleteVehicle _vehicle; [objNull,"placement_changed"]
};
_vehicle setDir _heading;
// Complete civilian setup and neutral ownership in one unscheduled call. Native
// capture/destruction handlers read the neutral owner later, avoiding both enemy
// resource charges and the penalty for stealing an inhabited civilian vehicle.
[_vehicle,civilian] call A3A_fnc_AIVEHinit;
_vehicle setVariable ["originalSide",sideUnknown,true];
_vehicle setVariable ["ownerSide",sideUnknown,true];
_vehicle setVariable ["A3I_abandoned",true,true];
_vehicle setVariable ["A3I_supplyKind",_kind,true];
// These are recoverable service trucks, not the damaged ambient-wreck pool.
_vehicle lock 0;
[_vehicle,false] remoteExecCall ["lockInventory",0,_vehicle];
if (!alive _vehicle) exitWith {deleteVehicle _vehicle; [objNull,"initialization_failed"]};
[_vehicle,""]
