// Restore only pristine houses changed by this scene, after its caller has
// ended the mission and the town has despawned. Observer/in-use checks remain
// here so a direct cleanup or interrupted worker cannot rebuild around actors.
params [["_record",createHashMap,[createHashMap]]];
if (!isServer || {isRemoteExecuted}) exitWith {[false,"server_local_only"]};
if (canSuspend) exitWith {[A3I_fnc_cleanupLiberationBuildings,_this] call CBA_fnc_directCall};
if (_record getOrDefault ["sceneBuildingsRetired",false]) exitWith {[true,"already_retired"]};
private _name = _record getOrDefault ["name",""];
private _entries = _record getOrDefault ["sceneBuildings",[]];
private _owners = missionNamespace getVariable ["A3I_liberationBuildings",createHashMap];
private _owned = _owners getOrDefault [_name,[]];
if (_name == "" || {!(_entries isEqualType [])}
    || {_owned isEqualTo [] && {_entries isNotEqualTo []}}
    || {_owned isNotEqualTo [] && {!((_owned # 0) isEqualRef _record)
        || {!((_owned # 1) isEqualRef _entries)}}}
    || {(_entries findIf {
        !(_x isEqualType createHashMap) || {private _building = _x getOrDefault ["building",objNull];
            !isNull _building && {!(_x getOrDefault ["restored",false])}
                && {!((_building getVariable ["A3I_sceneBuilding",createHashMap]) isEqualRef _x)}}
    }) != -1}) exitWith {[false,"ownership"]};
private _pending = false;
private _reason = "settling";
private _observers = call A3I_fnc_spawnObservers;
{
    private _entry = _x;
    if (_entry get "restored") then {continue};
    private _building = _entry get "building";
    private _ruin = _entry get "ruin";
    private _position = ASLToATL (_entry get "position");
    if ((_observers findIf {_x distance2D _position < ((missionNamespace getVariable ["distanceSPWN",1000]) max 150)}) != -1)
        then {_pending = true; _reason = "observed"; continue};
    if ((nearestObjects [_position,["CAManBase","LandVehicle","Air","Ship"],_entry get "clearance"]
        findIf {alive _x}) != -1) then {_pending = true; _reason = "occupied"; continue};
    if (isNull _building) then {
        // A different system removed the original. Do not invent a replacement.
        if (!isNull _ruin) then {deleteVehicle _ruin};
        _entry set ["restored",true]; continue;
    };
    if (diag_tickTime < (_entry get "lastChangeAt") + 2
        || {damage _building >= 1 && {diag_tickTime < (_entry get "appliedAt") + 15}})
        then {_pending = true; continue};
    if (!isNull _ruin && {_ruin getVariable ["building",objNull] != _building})
        then {_pending = true; _reason = "ruin_ownership"; continue};
    if (isNil {_entry get "restoreAt"}) then {
        if (!isNull _ruin) then {[_building] call A3A_fnc_repairRuinedBuilding}
        else {_building setDamage 0};
        _building setVectorDirAndUp [_entry get "direction",_entry get "up"];
        _building setPosWorld (_entry get "position");
        {_building animate [_x # 0,_x # 1,true]} forEach (_entry get "animations");
        _entry set ["restoreAt",diag_tickTime];
        _pending = true; continue;
    };
    // Deletion and the model restoration complete asynchronously. Keep ownership
    // until the next tick confirms a live building at its original transform.
    if (diag_tickTime < (_entry get "restoreAt") + 2 || {!isNull _ruin}) then {_pending = true; continue};
    if (!alive _building || {damage _building > 0} || {getPosWorld _building distance (_entry get "position") > 0.1}) then {
        _entry deleteAt "restoreAt"; _pending = true; continue;
    };
    _building setVariable ["A3I_sceneBuilding",nil];
    _building setVariable ["ruins",nil];
    destroyedBuildings = destroyedBuildings - [_building];
    _entry set ["restored",true];
} forEach _entries;
if (_pending) exitWith {[false,_reason]};
_record set ["sceneBuildingsRetired",true]; _record set ["sceneBuildings",[]];
_owners deleteAt _name;
if (count _owners == 0 && {!isNil "A3I_liberationBuildingHandler"}) then {
    removeMissionEventHandler ["BuildingChanged",A3I_liberationBuildingHandler];
    A3I_liberationBuildingHandler = nil;
};
[true,""]
