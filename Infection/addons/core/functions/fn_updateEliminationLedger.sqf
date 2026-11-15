params [["_record",createHashMap,[createHashMap]]];
if (!isServer || {isRemoteExecuted}) exitWith {"invalid"};
if (canSuspend) exitWith {[A3I_fnc_updateEliminationLedger,_this] call CBA_fnc_directCall};
private _registry = missionNamespace getVariable ["A3I_eliminationLedgers",createHashMap];
private _current = _registry getOrDefault [_record getOrDefault ["name",""],createHashMap];
if (_current getOrDefault ["serial",-2] != _record getOrDefault ["serial",-1]) exitWith {"invalid"};
_record = _current;
if (_record get "outcome" != "pending") exitWith {_record get "outcome"};
private _unit = _record get "unit";
private _terminal = ""; private _reason = "";
if (!([west] call A3I_fnc_isActive)) then {_terminal = "cancelled"; _reason = "infection_inactive"} else {
    private _killedAt = _record get "killedAt";
    if (_killedAt >= 0) then {
        if (_killedAt <= _record get "deadline") then {
            _terminal = "neutralized"; _reason = "observed_death";
        } else {_terminal = "failed"; _reason = "timeout"};
    } else {
        if (_record get "deleted" || {isNull _unit} || {!((_unit getVariable ["A3I_eliminationOwner",[]]) isEqualTo
            [_record get "name",_record get "serial"])}) then {
            _terminal = "interrupted"; _reason = "target_missing_or_reassigned";
        } else {
            if (time >= _record get "deadline") then {_terminal = "failed"; _reason = "timeout"};
        };
    };
};
// Settlement ownership is intentionally absent: the owner requires continuing
// the hunt after Rebels or Russia capture the target's original location.
if (_terminal != "") then {
    _record set ["outcome",_terminal]; _record set ["reason",_reason]; _record set ["settledAt",time];
};
_record get "outcome"
