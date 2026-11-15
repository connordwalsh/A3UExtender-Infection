// Internal binding; the ledger remains authoritative and owns no rewards.
params [["_record",createHashMap,[createHashMap]],["_enable",true,[false]]];
if (!isServer || {isRemoteExecuted}) exitWith {false};
if (canSuspend) exitWith {[A3I_fnc_setExtractionActions,_this] call CBA_fnc_directCall};
private _name = _record getOrDefault ["name",""];
private _current = (missionNamespace getVariable ["A3I_extractionLedgers",createHashMap]) getOrDefault [_name,createHashMap];
if (_current getOrDefault ["serial",-1] != _record getOrDefault ["serial",-2]) exitWith {false};
_record = _current;
if (_enable && {(_record get "outcome") != "pending" || {time >= _record get "deadline"}}) exitWith {false};
{
    private _unit = _x get "unit";
    private _owned = !isNull _unit && {(_unit getVariable ["A3I_extractionOwner",[]]) isEqualTo
        [_name,_record get "serial",_forEachIndex]};
    private _key = format ["A3I_extraction_%1_%2",_record get "serial",_forEachIndex];
    if (_enable) then {
        if (!_owned || {_x getOrDefault ["releaseState",""] != ""} || {_x get "state" != "pending"}
            || {isNull _unit} || {!alive _unit} || {!local _unit}) then {continue};
        _x set ["releaseState","waiting"];
        _x set ["actionKey",_key];
        _unit setVariable ["A3I_extractionReleaseState","waiting",true];
        [_unit] remoteExecCall ["A3I_fnc_extractionAction",[teamPlayer,civilian],_key];
    } else {
        private _bound = _x getOrDefault ["actionKey",""];
        if (_bound == "" && {_x getOrDefault ["releaseState",""] in ["","closed"]}) then {continue};
        if (_bound != "") then {remoteExec ["",_bound]; _x set ["actionKey",""]};
        if (_owned) then {
            _unit setVariable ["A3I_extractionReleaseState",nil,true];
            [_unit,true] remoteExecCall ["A3I_fnc_extractionAction",[teamPlayer,civilian]];
        };
        _x set ["releaseState","closed"];
    };
} forEach (_record get "entries");
if (_enable && {isNil "A3I_extractionReleaseHandle"}) then {
    A3I_extractionReleaseHandle = [A3I_fnc_extractionReleaseTick,0.5] call CBA_fnc_addPerFrameHandler;
};
true
