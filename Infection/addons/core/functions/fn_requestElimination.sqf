params [["_requester",clientOwner,[0]],["_silent",false,[false]]];
if (!isServer || {!canSuspend} || {isRemoteExecuted}) exitWith {};
waitUntil {sleep 0.1; isNil "A3A_missionRequestInProgress" || {!([west] call A3I_fnc_isActive)}};
if (!([west] call A3I_fnc_isActive) || {isNil "petros"} || {isNull petros}
    || {!alive petros} || {leader group petros != petros}) exitWith {};
if (call A3I_fnc_eliminationTaskBusy) exitWith {
    if (!_silent) then {[petros,"globalChat",localize "STR_chats_mission_request_already_type"]
        remoteExec ["A3A_fnc_commsMP",_requester]};
};
private _accepted = [] call A3I_fnc_startElimination;
private _registered = false;
if (_accepted) then {
    private _job = A3I_eliminationTasks getOrDefault ["A3I_ELIM_" + str A3I_eliminationTaskSerial,createHashMap];
    if (count _job > 0) then {
        waitUntil {sleep 0.1; _job getOrDefault ["taskRegistered",false] || {_job getOrDefault ["settled",false]}};
        _registered = _job getOrDefault ["taskRegistered",false];
    };
};
if (_silent) exitWith {};
if (_registered) then {
    [petros,"globalChat",localize "STR_chats_mission_request_success"] remoteExec ["A3A_fnc_commsMP",_requester];
} else {
    [petros,"globalChat","No Elimination Task is available."] remoteExec ["A3A_fnc_commsMP",_requester];
    [petros,"hint","No special infected and escort can currently be placed safely at a nearby infected-held location.",
        "Elimination Task"] remoteExec ["A3A_fnc_commsMP",_requester];
};
