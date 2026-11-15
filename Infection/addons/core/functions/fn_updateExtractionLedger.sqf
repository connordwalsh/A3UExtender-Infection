params [["_record",createHashMap,[createHashMap]]];
if (!isServer || {isRemoteExecuted}) exitWith {""};
if (canSuspend) exitWith {[A3I_fnc_updateExtractionLedger,_this] call CBA_fnc_directCall};
private _current = (missionNamespace getVariable ["A3I_extractionLedgers",createHashMap])
    getOrDefault [_record getOrDefault ["name",""],createHashMap];
if (_current getOrDefault ["serial",-1] != _record getOrDefault ["serial",-2]) exitWith {""};
// Operate only on the registered record; a copied/stale record cannot mutate it.
_record = _current;
if (_record get "outcome" != "pending") exitWith {_record get "outcome"};
private _expired = time >= _record get "deadline";
private _entries = _record get "entries";
if (!_expired) then {
    {
        private _unit = _x get "unit";
        if (_x get "state" != "pending" || {_x get "deleted"} || {isNull _unit}
            || {!alive _unit} || {_unit getVariable ["WBK_AI_ISZombie",false]}
            || {!(side group _unit in [teamPlayer,civilian])}
            || {!((_unit getVariable ["A3I_extractionOwner",[]]) isEqualTo
                [_record get "name",_record get "serial",_forEachIndex])}) then {continue};
        private _destination = [_unit,"survivor"] call A3I_fnc_deliveryDestination;
        if (_destination != "") then {
            _x set ["state","rescued"];
            _x set ["destination",_destination];
            _x set ["resolvedAt",time];
        };
    } forEach _entries;
};
private _rescued = {_x get "state" == "rescued"} count _entries;
private _killed = {_x get "state" == "killed"} count _entries;
private _unresolved = count _entries - _rescued - _killed;
_record set ["rescued",_rescued]; _record set ["killed",_killed];
_record set ["unresolved",_unresolved];
if (_expired || {_unresolved == 0}) then {
    _record set ["outcome",["failed","succeeded"] select (_rescued > 0)];
    _record set ["reason",["all_resolved","deadline"] select _expired];
    _record set ["settledAt",time];
};
_record get "outcome"
