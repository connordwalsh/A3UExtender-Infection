// Real emitter/light ownership and deletion. A dedicated server has no visual
// display; client rendering, observer refusal and JIP presentation are NOT_RUN.
private _record = call _newSurvivor;
private _position = getMarkerPos _town;
private _result = [_record,["invalid",0,0]] call A3I_fnc_createLiberationFire;
["lib_effect_invalid_position_refused",!(_result # 0)
    && {isNil {_record get "sceneEffects"}}] call _check;
_result = [_record,_position,"invalid"] call A3I_fnc_createLiberationFire;
["lib_effect_unknown_type_refused",!(_result # 0) && {_result # 1 == "effect_type"}
    && {isNil {_record get "sceneEffects"}}] call _check;
A3I_test_sceneEffectsCreated = [];
private _createdHandler = addMissionEventHandler ["EntityCreated",{A3I_test_sceneEffectsCreated pushBack (_this # 0)}];
[_record,_position] remoteExecCall ["A3I_fnc_createLiberationFire",2]; sleep 0.3;
removeMissionEventHandler ["EntityCreated",_createdHandler];
["lib_effect_remote_creation_refused",A3I_test_sceneEffectsCreated isEqualTo []
    && {isNil {_record get "sceneEffects"}}] call _check;
_result = [_record,_position] call A3I_fnc_createLiberationFire;
private _effects = +(_record getOrDefault ["sceneEffects",[]]);
["lib_effect_real_pair_owned",_result # 0 && {count _effects == 2}
    && {(_effects findIf {isNull _x}) == -1}
    && {((A3I_liberationEffects get (_record get "name")) # 0) isEqualRef _record}
    && {((A3I_liberationEffects get (_record get "name")) # 1) isEqualRef (_record get "sceneEffects")},
    [_result,_effects apply {typeOf _x}]] call _check;
["lib_effect_network_objects",count _effects == 2
    && {(_effects findIf {netId _x in ["","0:0"]}) == -1}
    && {netId (_effects # 0) != netId (_effects # 1)},_effects apply {netId _x}] call _check;
["lib_effect_local_presentation_refused",!([_effects # 0,_effects # 1,"BigDestructionFire"]
    call A3I_fnc_applyLiberationFire)] call _check;
[_record] remoteExecCall ["A3I_fnc_cleanupLiberationEffects",2]; sleep 0.3;
["lib_effect_remote_cleanup_refused",(_effects findIf {isNull _x}) == -1
    && {!(_record getOrDefault ["sceneEffectsRetired",false])}] call _check;
private _foreign = createHashMapFromArray [["name","foreign"],["sceneEffects",_effects]];
_result = [_foreign] call A3I_fnc_cleanupLiberationEffects;
["lib_effect_foreign_cleanup_refused",!(_result # 0) && {_result # 1 == "ownership"}
    && {(_effects findIf {isNull _x}) == -1}] call _check;
private _copy = createHashMapFromArray [["name",_record get "name"],["town",_town],
    ["sceneEffects",_record get "sceneEffects"]];
_result = [_copy] call A3I_fnc_cleanupLiberationEffects;
["lib_effect_same_name_copy_refused",!(_result # 0) && {_result # 1 == "ownership"}
    && {!(([_copy,_position] call A3I_fnc_createLiberationFire) # 0)}
    && {(_effects findIf {isNull _x}) == -1}] call _check;
_result = [_record,_position vectorAdd [10,0,0],"SmallDestructionFire"] call A3I_fnc_createLiberationFire;
_effects = +(_record getOrDefault ["sceneEffects",[]]);
["lib_effect_multiple_pairs_tracked",_result # 0 && {count _effects == 4}] call _check;
_result = [_record] call A3I_fnc_cleanupLiberationEffects;
private _deadline = diag_tickTime + 8;
waitUntil {sleep 0.05;(_effects findIf {!isNull _x}) == -1 || {diag_tickTime > _deadline}};
["lib_effect_exact_cleanup",_result # 0 && {(_effects findIf {!isNull _x}) == -1}
    && {_record get "sceneEffects" isEqualTo []}
    && {isNil {A3I_liberationEffects get (_record get "name")}}] call _check;
["lib_effect_retirement_idempotent",([_record] call A3I_fnc_cleanupLiberationEffects) # 0
    && {!(([_record,_position] call A3I_fnc_createLiberationFire) # 0)}] call _check;
// Reproduce the recoverable state after the particle is owned but light setup
// did not complete. The remaining particle must still be deleted exactly.
_record = call _newSurvivor;
_result = [_record,_position] call A3I_fnc_createLiberationFire;
_effects = _record getOrDefault ["sceneEffects",[]];
private _partial = +_effects;
if (count _effects == 2) then {deleteVehicle (_effects deleteAt 1)};
_result = [_record] call A3I_fnc_cleanupLiberationEffects;
_deadline = diag_tickTime + 8;
waitUntil {sleep 0.05;(_partial findIf {!isNull _x}) == -1 || {diag_tickTime > _deadline}};
["lib_effect_partial_creation_cleanup",count _partial == 2 && {_result # 0}
    && {(_partial findIf {!isNull _x}) == -1}
    && {isNil {A3I_liberationEffects get (_record get "name")}}] call _check;

// Native smoke owns two local particles and a light through its config script.
_record = call _newSurvivor;
_result = [_record,_position,"Smoke"] call A3I_fnc_createLiberationFire;
private _anchor = (_record getOrDefault ["sceneEffects",[]]) param [0,objNull];
sleep 0.2;
private _localEffects = +(_anchor getVariable ["effects",[]]);
["lib_effect_native_smoke_owned",_result # 0 && {!isNull _anchor}
    && {typeOf _anchor == "test_EmptyObjectForSmoke"} && {netId _anchor != "0:0"}
    && {count _localEffects == 3} && {(_localEffects findIf {isNull _x || {!local _x}}) == -1},
    [_result,typeOf _anchor,_localEffects apply {typeOf _x}]] call _check;
_result = [_record,_position vectorAdd [10,0,0],"BigDestructionFire"] call A3I_fnc_createLiberationFire;
_effects = +(_record get "sceneEffects");
["lib_effect_mixed_smoke_fire_registry",_result # 0 && {count _effects == 3}
    && {((A3I_liberationEffects get (_record get "name")) # 1) isEqualRef (_record get "sceneEffects")}] call _check;
_result = [_record] call A3I_fnc_cleanupLiberationEffects;
_deadline = diag_tickTime + 8;
waitUntil {sleep 0.05;((_effects + _localEffects) findIf {!isNull _x}) == -1 || {diag_tickTime > _deadline}};
["lib_effect_smoke_children_deleted_by_native_handler",_result # 0
    && {((_effects + _localEffects) findIf {!isNull _x}) == -1}] call _check;
_record = call _newSurvivor;
[_record,_position,"Smoke"] call A3I_fnc_createLiberationFire;
_anchor = (_record get "sceneEffects") # 0;
_localEffects = +(_anchor getVariable ["effects",[]]);
if (_localEffects isNotEqualTo []) then {deleteVehicle (_localEffects # 0)};
_result = [_record] call A3I_fnc_cleanupLiberationEffects;
_deadline = diag_tickTime + 8;
waitUntil {sleep 0.05;((_localEffects + [_anchor]) findIf {!isNull _x}) == -1 || {diag_tickTime > _deadline}};
["lib_effect_partial_native_smoke_cleanup",_result # 0 && {count _localEffects == 3}
    && {((_localEffects + [_anchor]) findIf {!isNull _x}) == -1}] call _check;
