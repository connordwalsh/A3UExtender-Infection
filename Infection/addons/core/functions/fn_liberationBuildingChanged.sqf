// Runs after Ultimate's BuildingChanged handler. Keep temporary scene ruins out
// of the permanent destroyed-building save list and retain their exact identity.
params ["_from","_to","_isRuin"];
if (!isServer || {isRemoteExecuted}) exitWith {};
private _building = if (_isRuin) then {_from} else {_to};
private _entry = _building getVariable ["A3I_sceneBuilding",createHashMap];
if (count _entry == 0 || {_entry getOrDefault ["restored",false]}) exitWith {};
private _owned = (missionNamespace getVariable ["A3I_liberationBuildings",createHashMap])
    getOrDefault [_entry getOrDefault ["name",""],[]];
if (_owned isEqualTo [] || {((_owned # 1) findIf {_x isEqualRef _entry}) == -1}
    || {_entry get "building" != _building}) exitWith {};
_entry set ["lastChangeAt",diag_tickTime];
if (_isRuin) then {
    _entry set ["ruin",_to];
    // Preserve the native repair contract even if the model event comes from a
    // standalone fixture. Only this owned building and its exact ruin are linked.
    _building setVariable ["ruins",_to];
    _to setVariable ["building",_building];
    destroyedBuildings = destroyedBuildings - [_building];
};
