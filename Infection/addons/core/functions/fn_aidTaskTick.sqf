params ["_arguments","_handle"];
if (!isServer || {isRemoteExecuted}) exitWith {};
{
    private _record = A3I_aidTasks get _x;
    if !(_record get "settled") then {[_record] call A3I_fnc_finishHumanitarianAid};
    if (_record get "settled") then {
        if ([_record] call A3I_fnc_cleanupHumanitarianAid) then {A3I_aidTasks deleteAt _x};
    } else {
        if (_record get "phase" == "active") then {
            private _package = _record get "package"; private _ledger = _record get "ledger";
            private _pickup = _record get "pickupMarker";
            if (_pickup != "" && {_package distance2D getMarkerPos _pickup > 1}) then {_pickup setMarkerPos getPosATL _package};
            // Native supply distribution exposes the nearby escort; other units are untouched.
            if (_package distance getMarkerPos (_record get "target") < 40 && {isNull attachedTo _package}
                && {isNull ropeAttachedTo _package}) then {
                {if (captive _x) then {[_x,false] remoteExecCall ["setCaptive",_x]}}
                    forEach ([80,0,_package,teamPlayer] call A3A_fnc_distanceUnits);
            };
            private _state = ["paused","unloading"] select (_ledger get "wasEligible");
            private _data = [_record get "serial",_record get "townName",ceil ((_ledger get "requiredSeconds")-(_ledger get "unloadedSeconds")),_state];
            if (_data isNotEqualTo (_package getVariable ["A3I_aidDisplay",[]])) then {_package setVariable ["A3I_aidDisplay",_data,true]};
            private _owners = [];
            {if (side group _x == teamPlayer && {_x distance _package < 80}) then {_owners pushBackUnique owner _x}}
                forEach (allPlayers - entities "HeadlessClient_F");
            private _left = (_record get "notifiedOwners") - _owners;
            if (_left isNotEqualTo []) then {[_record get "serial","",0,"stop"] remoteExecCall ["A3I_fnc_aidProgressHint",_left]};
            if (_owners isNotEqualTo []) then {_data remoteExecCall ["A3I_fnc_aidProgressHint",_owners]};
            _record set ["notifiedOwners",_owners];
        };
    };
} forEach keys A3I_aidTasks;
if (count A3I_aidTasks == 0) then {[_handle] call CBA_fnc_removePerFrameHandler; A3I_aidTaskHandle = nil};
