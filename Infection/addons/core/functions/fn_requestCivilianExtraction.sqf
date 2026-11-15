// Local scheduled worker; the shared task registry owns the reservation.
params [["_source","",[""]],["_unit",objNull,[objNull]],["_caller",objNull,[objNull]]];
if (!isServer || {isRemoteExecuted} || {!canSuspend} || {isNull _unit} || {isNull _caller}
    || {_source == ""} || {missionNamespace getVariable ["A3U_dialogCivMissionInProgress",false]}) exitWith {false};
private _registered=false;
if ([_source] call A3I_fnc_startExtraction) then {
    private _record=A3I_extractionTasks getOrDefault ["A3I_EXTRACTION_"+str A3I_extractionTaskSerial,createHashMap];
    if (count _record>0) then {
        waitUntil {sleep 0.1; _record getOrDefault ["taskRegistered",false] || {_record getOrDefault ["settled",false]}};
        _registered=_record getOrDefault ["taskRegistered",false];
    };
};
if (!isNull _unit && {!isNull _caller}) then {
    private _message=["Those survivors cannot be reached right now.",
        "A group of survivors is stranded nearby. Their location has been marked; please bring them to safety."] select _registered;
    [_unit,"globalChat",_message] remoteExec ["A3A_fnc_commsMP",owner _caller];
};
_registered
