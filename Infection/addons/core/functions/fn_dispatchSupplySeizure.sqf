// Legacy LOG requests accept a marker, or the bank object used by native LOG_Bank.
params [["_source","",["",objNull]]];
if (!([west] call A3I_fnc_isActive)) exitWith {};
if (!isServer) exitWith {
    if (!hasInterface && {isRemoteExecuted && {remoteExecutedOwner == 2}}) then {
        [_source] remoteExec ["A3I_fnc_dispatchSupplySeizure",2];
    };
};
if (isRemoteExecuted && {!(remoteExecutedOwner in ([2] + (missionNamespace getVariable ["hcArray",[]])))}) exitWith {};
[{
    _this spawn {
        params ["_source"];
        if (_source isEqualType objNull) then {
            if (isNull _source) exitWith {_source = ""};
            private _object = _source;
            private _candidates = (call A3I_fnc_supplyTargets) select {[_object,_x] call A3I_fnc_interceptionContains};
            private _distances = _candidates apply {[_object distance2D getMarkerPos _x,_x]};
            _distances sort true;
            _source = if (_distances isEqualTo []) then {""} else {_distances # 0 # 1};
        };
        if (_source == "") exitWith {};
        [_source] call A3I_fnc_startSupplySeizure;
    };
},[_source]] call CBA_fnc_execNextFrame;
