params [["_requester",clientOwner,[0]],["_silent",false,[false]]];
if (!isServer || {!canSuspend} || {isRemoteExecuted}) exitWith {};
waitUntil {sleep 0.1; isNil "A3A_missionRequestInProgress" || {!([west] call A3I_fnc_isActive)}};
if (!([west] call A3I_fnc_isActive) || {isNil "petros"} || {isNull petros}
    || {!alive petros} || {leader group petros != petros}) exitWith {};
if (call A3I_fnc_extractionTaskBusy) exitWith {
    if (!_silent) then {[petros,"globalChat",localize "STR_chats_mission_request_already_type"]
        remoteExec ["A3A_fnc_commsMP",_requester]};
};
private _accepted = [] call A3I_fnc_startExtraction;
private _registered = false;
if (_accepted) then {
    private _job = A3I_extractionTasks getOrDefault ["A3I_EXTRACTION_" + str A3I_extractionTaskSerial,createHashMap];
    if (count _job > 0) then {
        waitUntil {sleep 0.1; _job getOrDefault ["taskRegistered",false] || {_job getOrDefault ["settled",false]}};
        _registered = _job getOrDefault ["taskRegistered",false];
    };
};
if (_silent) exitWith {};
if (_registered) then {
    [petros,"globalChat",localize "STR_chats_mission_request_success"] remoteExec ["A3A_fnc_commsMP",_requester];
} else {
    [petros,"globalChat","No Extraction Mission is available."] remoteExec ["A3A_fnc_commsMP",_requester];
    [petros,"hint","No sheltered survivor group and infected guards can currently be placed safely at a nearby infected-held location.",
        "Extraction Mission"] remoteExec ["A3A_fnc_commsMP",_requester];
};
