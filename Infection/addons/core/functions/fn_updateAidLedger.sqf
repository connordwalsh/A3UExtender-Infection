params [["_record",createHashMap,[createHashMap]]];
if (!isServer || {isRemoteExecuted}) exitWith {"invalid"};
if (canSuspend) exitWith {[A3I_fnc_updateAidLedger,_this] call CBA_fnc_directCall};
private _registry = missionNamespace getVariable ["A3I_aidLedgers",createHashMap];
private _current = _registry getOrDefault [_record getOrDefault ["name",""],createHashMap];
if (_current getOrDefault ["serial",-2] != _record getOrDefault ["serial",-1]) exitWith {"invalid"};
_record = _current;
if (_record get "outcome" != "pending") exitWith {_record get "outcome"};
private _marker = _record get "marker";
private _package = _record get "package";
private _terminal = ""; private _reason = "";
// Ownership cancellation wins over an arrival or deadline observed in this tick.
if (!([west] call A3I_fnc_isActive) || {isNil "sidesX"} || {!(_marker in allMapMarkers)}
    || {!(_marker in (missionNamespace getVariable ["citiesX",[]]))}
    || {sidesX getVariable [_marker,sideUnknown] != west}) then {
    _terminal = "cancelled"; _reason = "destination_unavailable";
} else {
    if (_record get "killed") then {_terminal = "failed"; _reason = "destroyed"} else {
        if (_record get "deleted" || {isNull _package} || {!((_package getVariable ["A3I_aidOwner",[]]) isEqualTo
            [_record get "name",_record get "serial"])}) then {
            _terminal = "interrupted"; _reason = "package_missing_or_reassigned";
        } else {
            if (time >= _record get "deadline") then {_terminal = "failed"; _reason = "timeout"};
        };
    };
};
if (_terminal == "") then {
    private _escort = [80,0,_package,teamPlayer] call A3A_fnc_distanceUnits;
    private _eligible = alive _package && {_package distance getMarkerPos _marker < 40}
        && {isNull attachedTo _package} && {isNull ropeAttachedTo _package}
        && {_escort isNotEqualTo []} && {(_escort findIf {!([_x] call A3A_fnc_canFight)}) == -1}
        && {(allUnits findIf {alive _x && {side group _x == west} && {_x distance _package < 50}}) == -1};
    private _delta = ((time - (_record get "lastCheck")) max 0) min 1;
    if (_eligible && {_record get "wasEligible"}) then {
        _record set ["unloadedSeconds",((_record get "unloadedSeconds") + _delta) min (_record get "requiredSeconds")];
    };
    _record set ["wasEligible",_eligible]; _record set ["lastCheck",time];
    if (_record get "unloadedSeconds" >= _record get "requiredSeconds") then {
        _terminal = "delivered"; _reason = "unloaded";
    };
};
if (_terminal != "") then {
    _record set ["outcome",_terminal]; _record set ["reason",_reason]; _record set ["settledAt",time];
};
_record get "outcome"
