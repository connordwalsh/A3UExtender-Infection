// Empty, repairable native scene wreck. Civilian initialization supplies the
// native capture/logistics handlers; neutralize ownership before leaving this
// unscheduled call, so abandoned vehicles are neither enemy assets nor theft.
params [["_record",createHashMap,[createHashMap]],["_position",[],[[]]],
    ["_class","",[""]]];
if (!isServer || {isRemoteExecuted}) exitWith {[false,"server_local_only"]};
if (canSuspend) exitWith {[A3I_fnc_createLiberationWreck,_this] call CBA_fnc_directCall};
if (!([west] call A3I_fnc_isActive) || {_record getOrDefault ["sceneWrecksRetired",false]})
    exitWith {[false,"inactive"]};
private _name = _record getOrDefault ["name",""];
private _town = _record getOrDefault ["town",""];
if (_name == "" || {!(_town in allMapMarkers)} || {isNil "sidesX"}
    || {!(_town in (missionNamespace getVariable ["citiesX",[]]))}
    || {sidesX getVariable [_town,sideUnknown] != west}) exitWith {[false,"town"]};
private _classes = call A3I_fnc_liberationWreckClasses;
if (_classes isEqualTo []) exitWith {[false,"wreck_pool"]};
if (_class == "") then {_class = selectRandom _classes};
if !(_class in _classes) exitWith {[false,"class"]};
// Native compileMissionAssets must have finished the vehicle skin maps before
// AIVEHinit is callable. Refuse a partial campaign setup before creating objects.
private _civilians = missionNamespace getVariable ["A3A_faction_civ",createHashMap];
if (!(_civilians isEqualType createHashMap)
    || {!((_civilians getOrDefault ["animations",[]]) isEqualType createHashMap)}
    || {!((_civilians getOrDefault ["variants",[]]) isEqualType createHashMap)})
    exitWith {[false,"campaign_not_ready"]};
private _hq = missionNamespace getVariable ["respawnTeamPlayer",""];
if !(_hq in allMapMarkers) exitWith {[false,"hq_unavailable"]};
private _safety = [_position,_class,call A3I_fnc_spawnObservers,getMarkerPos _hq] call A3I_fnc_positionSafety;
if !(_safety # 0) exitWith {_safety};
if !(_position inArea _town) exitWith {[false,"town_bounds"]};
private _wrecks = _record getOrDefault ["sceneWrecks",[]];
_record set ["sceneWrecks",_wrecks];
private _vehicle = createVehicle [_class,_position,[],0,"NONE"];
if (isNull _vehicle) exitWith {[false,"creation_failed"]};
_wrecks pushBack _vehicle;
_vehicle setVariable ["A3I_sceneWreckId",_name];
_vehicle setVariable ["A3I_abandoned",true,true];
if (!alive _vehicle || {!(_vehicle inArea _town)} || {_vehicle distance2D _position > 0.5})
    exitWith {deleteVehicle _vehicle; [false,"placement_changed"]};
_vehicle setDir random 360;
// Unknown side cannot be passed to AIVEHinit: its skin helper requires an
// actual faction. CIV has no infected-resource bookkeeping. Its capture handler
// reads ownerSide at capture time, after the atomic neutral transition below.
[_vehicle,civilian] call A3A_fnc_AIVEHinit;
_vehicle setVariable ["originalSide",sideUnknown,true];
_vehicle setVariable ["ownerSide",sideUnknown,true];
_vehicle setDamage random [0.5,0.6,0.7];
_vehicle setFuel 0;
// Reset any civilian-auto-lock initialization, then retain the scene's own
// native overturn/lock chances and the campaign's enableVehicleAutoLock option.
_vehicle lock 0;
[_vehicle,false] remoteExecCall ["lockInventory",0,_vehicle];
if (round (random 100) < 5) then {_vehicle setVectorUp [1,selectRandom [0,1],0]};
if (round (random 100) < 30) then {[_vehicle,true] call A3U_fnc_setLock};
if (!alive _vehicle) exitWith {[false,"damaged_creation"]};
[true,""]
