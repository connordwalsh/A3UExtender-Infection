// Real roof geometry and the native random building decoration transaction.
// Client particle rendering and terrain-model coverage remain NOT_RUN.
private _hadDestroyed = !isNil "destroyedBuildings";
private _savedDestroyed = missionNamespace getVariable ["destroyedBuildings",[]];
destroyedBuildings = [];
private _building = createVehicle ["Land_i_House_Small_01_V1_F",getMarkerPos _town vectorAdd [0,70,0],[],0,"CAN_COLLIDE"];
private _markerObject = createVehicle ["Land_HelipadEmpty_F",getMarkerPos _town,[],0,"CAN_COLLIDE"];
sleep 0.3;
["lib_roof_missing_object_empty",[objNull] call A3I_fnc_liberationRoofPosition isEqualTo []] call _check;
["lib_roof_nonbuilding_empty",[_markerObject] call A3I_fnc_liberationRoofPosition isEqualTo []] call _check;
private _roof = [_building] call A3I_fnc_liberationRoofPosition;
["lib_roof_real_geometry",count _roof == 3 && {_roof # 2 > 2}
    && {_roof distance2D _building < 10}
    && {(_roof findIf {!finite _x}) == -1},_roof] call _check;
_building hideObjectGlobal true;
["lib_roof_hidden_building_empty",[_building] call A3I_fnc_liberationRoofPosition isEqualTo []] call _check;
_building hideObjectGlobal false;
private _record = call _newSurvivor;
[_record,_building] remoteExecCall ["A3I_fnc_decorateLiberationBuilding",2]; sleep 0.3;
["lib_roof_remote_decoration_refused",damage _building == 0 && {isNil {_record get "sceneBuildings"}}] call _check;
private _result = [_record,_building] call A3I_fnc_decorateLiberationBuilding;
private _effects = +(_record getOrDefault ["sceneEffects",[]]);
private _nativeLocal = [];
{_nativeLocal append (_x getVariable ["effects",[]])} forEach (_effects select {typeOf _x == "test_EmptyObjectForSmoke"});
private _entry = (_record getOrDefault ["sceneBuildings",[]]) param [0,createHashMap];
["lib_roof_native_decoration_owned",_result # 0 && {damage _building >= 0.7}
    && {_entry getOrDefault ["building",objNull] == _building} && {count _effects <= 2}
    && {(_effects findIf {_x distance _roof > 0.2}) == -1},
    [_result,damage _building,_effects apply {typeOf _x}]] call _check;
_result = [_record,_building] call A3I_fnc_decorateLiberationBuilding;
["lib_roof_decoration_idempotent",_result # 0 && {_result # 1 == "already_applied"}
    && {_record getOrDefault ["sceneEffects",[]] isEqualTo _effects}
    && {count (_record get "sceneBuildings") == 1}] call _check;
private _effectsCleaned = ([_record] call A3I_fnc_cleanupLiberationEffects) # 0;
private _deadline = diag_tickTime + 30;
private _cleaned = false;
waitUntil {sleep 0.2; _cleaned = ([_record] call A3I_fnc_cleanupLiberationBuildings) # 0;
    _cleaned || {diag_tickTime > _deadline}};
["lib_roof_decoration_restoration",_effectsCleaned && {_cleaned} && {alive _building}
    && {damage _building == 0} && {((_effects + _nativeLocal) findIf {!isNull _x}) == -1}
    && {isNil "A3I_liberationBuildingHandler"}] call _check;
deleteVehicle _building; deleteVehicle _markerObject;
sleep 0.3;
destroyedBuildings = if (_hadDestroyed) then {_savedDestroyed} else {nil};
["lib_roof_fixture_cleanup",isNull _building && {isNull _markerObject}
    && {count A3I_liberationBuildings == 0} && {count A3I_liberationEffects == 0}] call _check;
