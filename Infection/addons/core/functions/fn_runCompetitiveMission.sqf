params ["_record"];
if (!isServer || {!canSuspend} || {isRemoteExecuted}) exitWith {};
private _target = _record get "target";
private _result = [_target,_record get "source",_record get "strength",-1,false,_record get "name"]
    call A3I_fnc_startMajorAttack;
if !(_result # 0) exitWith {_record set ["outcome","cancelled"]};
private _horde = A3I_majorAttacks get A3I_majorGlobalOwner;
_record set ["majorRecord",_horde];
if (_record get "outcome" != "pending") exitWith {};
private _destination = [_target] call A3A_fnc_localizar;
private _description = format ["Capture %1 before the infected horde does. If the infected take the site first, the mission fails. Complete the capture by %2.",
    _destination,_record get "displayTime"];
[[teamPlayer,civilian],_record get "name",[_description,"Beat the infected to the capture",_target],
    _record get "position",false,0,true,"Target",true] call BIS_fnc_taskCreate;
[_record get "name","CON","CREATED"] call A3A_fnc_taskUpdate;
_record set ["taskRegistered",true];
while {_record get "outcome" == "pending"} do {
    if (!([west] call A3I_fnc_isActive) || {!(_target in allMapMarkers)})
        exitWith {_record set ["outcome","cancelled"]};
    // The native marker-change event records the first capture immediately.
    // Poll as recovery for a state change that did not publish that event.
    private _owner = sidesX getVariable [_target,sideUnknown];
    if (_owner == west) exitWith {_record set ["outcome","lost_race"]};
    if (_owner == teamPlayer) exitWith {_record set ["outcome","won"]};
    if (_owner != Invaders) exitWith {_record set ["outcome","cancelled"]};
    if (dateToNumber date > _record get "deadline") exitWith {_record set ["outcome","timeout"]};
    if (_horde get "outcome" in ["cancelled","interrupted","no_force"] && {_horde get "paidActors" == 0})
        exitWith {_record set ["outcome","cancelled"]};
    sleep 1;
};
[_record] call A3I_fnc_finishCompetitiveMission;
