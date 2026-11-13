// Authoritative observer objects, including remote-controlled soldiers and UAVs.
// Headless-client entities are not player viewpoints. No client camera is assumed.
private _observers = allPlayers - entities "HeadlessClient_F";
{
    private _operator = _x getVariable ["owner", objNull];
    if (!isNull _operator && {isPlayer _operator}) then {_observers pushBackUnique _x};
} forEach allUnits;
{
    private _uav = getConnectedUAV _x;
    if (!isNull _uav) then {_observers pushBackUnique _uav};
} forEach +_observers;
_observers
