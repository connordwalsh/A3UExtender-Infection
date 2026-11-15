// Internal asset factory. The town adapter must own the returned vehicle.
// No patrol crew, campaign stock ledger, or automatic despawner is created here.
params [["_town","",[""]],["_kind","",[""]],["_position",[],[[]]],
    ["_heading",0,[0]],["_class","",[""]]];
if (!isServer || {isRemoteExecuted}) exitWith {[objNull,"server_local_only"]};
if (canSuspend) exitWith {[A3I_fnc_createAbandonedVehicle,_this] call CBA_fnc_directCall};
if (!([west] call A3I_fnc_isActive)) exitWith {[objNull,"inactive"]};
if (isNil "sidesX" || {!(_town in allMapMarkers)}
    || {!(_town in (missionNamespace getVariable ["citiesX",[]]))}
    || {_town in (missionNamespace getVariable ["destroyedSites",[]])}
    || {sidesX getVariable [_town,sideUnknown] != west}) exitWith {[objNull,"town_unavailable"]};
private _classes = [_kind] call A3I_fnc_abandonedVehicleClasses;
if (_classes isEqualTo []) exitWith {[objNull,"vehicle_pool"]};
if (_class == "") then {_class = selectRandom _classes};
if (!(_class in _classes) || {!finite _heading}) exitWith {[objNull,"class_or_heading"]};
private _civilian = missionNamespace getVariable ["A3A_faction_civ",createHashMap];
if (!(_civilian isEqualType createHashMap)
    || {!((_civilian getOrDefault ["animations",[]]) isEqualType createHashMap)}
    || {!((_civilian getOrDefault ["variants",[]]) isEqualType createHashMap)}
    || {isNil "serverInitDone"} || {!serverInitDone}) exitWith {[objNull,"campaign_not_ready"]};
private _hq = missionNamespace getVariable ["respawnTeamPlayer",""];
if !(_hq in allMapMarkers) exitWith {[objNull,"hq_unavailable"]};
private _safe = [_position,_class,call A3I_fnc_spawnObservers,getMarkerPos _hq] call A3I_fnc_positionSafety;
if !(_safe # 0) exitWith {[objNull,_safe # 1]};
if (_position distance2D getMarkerPos _town > 250) exitWith {[objNull,"town_distance"]};
private _vehicle = createVehicle [_class,_position,[],0,"NONE"];
if (isNull _vehicle) exitWith {[objNull,"creation_failed"]};
if (!alive _vehicle || {_vehicle distance2D _position > 0.5}) exitWith {
    deleteVehicle _vehicle; [objNull,"placement_changed"]
};
_vehicle setDir _heading;
[_vehicle,civilian] call A3A_fnc_AIVEHinit;
// Native capture/destruction handlers subsequently read neutral ownership.
// This avoids civilian theft penalties and both enemy army-resource pools.
_vehicle setVariable ["originalSide",sideUnknown,true];
_vehicle setVariable ["ownerSide",sideUnknown,true];
_vehicle setVariable ["A3I_abandoned",true,true];
_vehicle setVariable ["A3I_abandonedKind",_kind,true];
_vehicle setVariable ["originalPos",getPosATL _vehicle];
[_vehicle,true,true,true,true] call A3A_fnc_clearVehicleCargo;
_vehicle setFuel random [0.10,0.30,0.50];
_vehicle setDamage random [0.15,0.35,0.55];
_vehicle lock 0;
[_vehicle,false] remoteExecCall ["lockInventory",0,_vehicle];
if (!alive _vehicle) exitWith {deleteVehicle _vehicle; [objNull,"initialization_failed"]};
[_vehicle,""]
