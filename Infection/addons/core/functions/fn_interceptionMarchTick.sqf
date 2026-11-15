// Recover stalled individual march orders without replacing native combat AI.
// Internal CBA callback: arguments are [job name, serial].
params ["_arguments","_handle"];
if (!isServer || {isRemoteExecuted}) exitWith {};
_arguments params ["_name","_serial"];
private _record = (missionNamespace getVariable ["A3I_interceptions",createHashMap])
    getOrDefault [_name,createHashMap];
if (_record getOrDefault ["serial",-1] != _serial
    || {_record getOrDefault ["retired",true]}
    || {!(_record getOrDefault ["phase",""] in ["marching","arrived"])}
    || {scriptDone (_record getOrDefault ["script",scriptNull])}) exitWith {
    [_handle] call CBA_fnc_removePerFrameHandler;
    if (_record getOrDefault ["marchHandle",-1] == _handle) then {_record deleteAt "marchHandle"};
};
if (_record getOrDefault ["marchHandle",-1] != _handle
    || {!([west] call A3I_fnc_isActive)}
    || {!(_record get "target" in allMapMarkers)}) exitWith {};
private _destination = _record get "destinationPosition";
private _pursuitRange = missionNamespace getVariable ["WBK_Zombies_MoveDistanceLimit",0];
{
    private _unit = _x;
    if (isNull _unit || {!alive _unit} || {!local _unit} || {isPlayer _unit}
        || {!isNull (remoteControlled _unit)} || {vehicle _unit != _unit}
        || {isObjectHidden _unit} || {!simulationEnabled _unit}
        || {_unit getVariable ["A3I_interceptionName",""] != _name}
        || {_unit getVariable ["A3I_interceptionSerial",-1] != _serial}
        || {_unit getVariable ["markerX",""] != ""}) then {continue};
    if (time - (_unit getVariable ["A3I_marchCheckedAt",time]) < 10) then {continue};
    private _oldPosition = _unit getVariable ["A3I_marchPosition",getPosATL _unit];
    _unit setVariable ["A3I_marchCheckedAt",time];
    _unit setVariable ["A3I_marchPosition",getPosATL _unit];
    if (_unit distance2D _oldPosition >= 1 || {_unit distance2D _destination <= 10}
        || {!isNil {_unit getVariable "WBK_IsUnitLocked"}}) then {continue};
    private _enemy = _unit findNearestEnemy _unit;
    if (!isNull _enemy && {alive _enemy}
        && {_pursuitRange <= 0 || {_unit distance _enemy < _pursuitRange}}) then {continue};
    // A MOVE command can remain present while the actor makes no progress.
    // Reissue only the destination order; never teleport or change AI flags.
    _unit doMove _destination;
    _unit setVariable ["A3I_marchRecoveries",(_unit getVariable ["A3I_marchRecoveries",0]) + 1];
    _record set ["marchRecoveries",(_record getOrDefault ["marchRecoveries",0]) + 1];
} forEach (_record get "units");
