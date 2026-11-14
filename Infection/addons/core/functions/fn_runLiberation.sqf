params ["_record"];
if (!isServer || {!canSuspend} || {isRemoteExecuted}) exitWith {};
private _town = _record get "town";
private _created = [_record] call A3I_fnc_createLiberationSurvivor;
if !(_created # 0) exitWith {
    _record set ["cancelReason",_created # 1]; _record set ["outcome","cancelled"];
};
if ("townBattle" in A3A_activeTasks) exitWith {_record set ["outcome","cancelled"]};
private _destination = [_town] call A3A_fnc_localizar;
private _description = format ["Find and recruit the survivor in %1, then keep them alive and inside the town. You have three minutes to prepare after recruitment. Defend for ten minutes after the approaching infected horde reaches the town, or defeat most of its attackers. The operation expires forty minutes after it begins.",_destination];
[[teamPlayer,civilian],_record get "name",[_description,"Rescue and defend the survivor",_town],
    _record get "position",false,0,true,"Defend",true] call BIS_fnc_taskCreate;
[_record get "name","townBattle","CREATED"] call A3A_fnc_taskUpdate;
_record set ["taskRegistered",true]; _record set ["phase","rescue"];
private _nextAttempt = 0;
while {_record get "outcome" == "pending"} do {
    private _outcome = [_record] call A3I_fnc_liberationOutcome;
    if (_outcome != "pending") exitWith {_record set ["outcome",_outcome]};
    private _vip = _record get "vip";
    if (_record get "phase" == "rescue" && {side group _vip == teamPlayer}
        && {group _vip != _record get "vipGroup"}) then {
        _record set ["recruited",true]; _record set ["phase","prepare"];
        _record set ["readyAt",time + 180];
    };
    if (_record get "phase" == "prepare" && {time >= _record get "readyAt"} && {time >= _nextAttempt}) then {
        _record set ["phase","horde"];
        private _result = [_town,_record get "source",1,0,false,_record get "name","liberation"]
            call A3I_fnc_startMajorAttack;
        if !(_result # 0) then {
            _record set ["phase","prepare"]; _record set ["lastLaunchFailure",_result # 2];
            // A busy shared attack slot or a temporarily ineligible source may
            // recover inside the native overall deadline. Never steal the slot.
            if !(_result # 2 in ["pending","source","race"]) then {_record set ["outcome","cancelled"]};
            _nextAttempt = time + 5;
        };
    };
    sleep 1;
};
[_record] call A3I_fnc_finishLiberation;
