// One internal handler owns the delayed rescue transitions and removes itself.
params ["_arguments","_handle"];
if (!isServer || {isRemoteExecuted}) exitWith {};
{
    private _key = _x;
    private _state = A3I_rescues get _key;
    _state params ["_unit","_rescuer","_stage","_deadline","_marker","_siteId","_escapeGroup"];
    if (!alive _unit) then {
        if (_stage == "releasing" && {!isNull _rescuer}) then {[_rescuer,""] remoteExec ["playMove",_rescuer]};
        if (!isNull _escapeGroup) then {[_escapeGroup] spawn A3A_fnc_groupDespawner};
        A3I_rescues deleteAt _key;
        continue;
    };
    if (_stage == "releasing") then {
        private _record = A3I_sites getOrDefault [_marker,createHashMap];
        private _valid = alive _rescuer && {side group _rescuer == teamPlayer}
            && {!(_rescuer getVariable ["incapacitated",false])} && {!(_rescuer getVariable ["surrendered",false])}
            && {_unit distance _rescuer <= 4}
            && {_record getOrDefault ["id",-1] == _siteId} && {!(_record get "cleaned")};
        if (!_valid) then {
            _unit setVariable ["A3I_survivorState","waiting",true];
            if (!isNull _rescuer) then {[_rescuer,""] remoteExec ["playMove",_rescuer]};
            A3I_rescues deleteAt _key;
            continue;
        };
        if (diag_tickTime < _deadline) then {continue};
        _escapeGroup = createGroup [teamPlayer,true];
        if (isNull _escapeGroup) then {
            _unit setVariable ["A3I_survivorState","waiting",true];
            [_rescuer,""] remoteExec ["playMove",_rescuer];
            A3I_rescues deleteAt _key;
            continue;
        };
        [_unit] joinSilent _escapeGroup;
        _record set ["civilians",(_record get "civilians") - [_unit]];
        _unit setVariable ["A3I_survivorState","escaping",true];
        {_unit enableAI _x} forEach ["MOVE","AUTOTARGET","TARGET","ANIM"];
        _unit setCaptive false;
        [_unit,true,false] spawn A3A_fnc_FIAinit;
        [_unit,teamPlayer,false] call A3A_fnc_fleeToSide;
        [_rescuer,""] remoteExec ["playMove",_rescuer];
        garrison setVariable [_marker + "_powCD",time + 3600,true];
        _state set [2,"escaping"];
        _state set [3,diag_tickTime + 32];
        _state set [6,_escapeGroup];
    } else {
        if (diag_tickTime < _deadline) then {continue};
        // A dead/incapacitated survivor cannot produce the delayed native HR.
        if (_unit call A3A_fnc_canFight) then {
            _unit setVariable ["A3I_survivorState","rescued",true];
            [1,0] spawn A3A_fnc_resourcesFIA;
        } else {_unit setVariable ["A3I_survivorState","rescue_failed",true]};
        // Never hand a player's or another system's group to garbage collection.
        if (!isNull _escapeGroup && {group _unit == _escapeGroup}) then {
            [_escapeGroup] spawn A3A_fnc_groupDespawner;
        };
        A3I_rescues deleteAt _key;
    };
} forEach keys A3I_rescues;
if (count A3I_rescues == 0) then {
    [_handle] call CBA_fnc_removePerFrameHandler;
    A3I_rescueHandle = nil;
};
