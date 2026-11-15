params [["_requester",clientOwner,[0]],["_silent",false,[false]]];
if (!isServer || {!canSuspend} || {isRemoteExecuted}) exitWith {};
waitUntil {sleep 0.1; isNil "A3A_missionRequestInProgress" || {!([west] call A3I_fnc_isActive)}};
if (!([west] call A3I_fnc_isActive) || {isNil "petros"} || {isNull petros}
    || {!alive petros} || {leader group petros != petros}) exitWith {};
if (call A3I_fnc_aidTaskBusy) exitWith {
    if (!_silent) then {[petros,"globalChat",localize "STR_chats_mission_request_already_type"]
        remoteExec ["A3A_fnc_commsMP",_requester]};
};
private _accepted = [] call A3I_fnc_startHumanitarianAid;
private _registered = false;
if (_accepted) then {
    private _job = A3I_aidTasks getOrDefault ["A3I_AID_" + str A3I_aidTaskSerial,createHashMap];
    if (count _job > 0) then {
        waitUntil {sleep 0.1; _job getOrDefault ["taskRegistered",false] || {_job getOrDefault ["settled",false]}};
        _registered = _job getOrDefault ["taskRegistered",false];
    };
};
if (_silent) exitWith {};
if (_registered) then {
    [petros,"globalChat",localize "STR_chats_mission_request_success"] remoteExec ["A3A_fnc_commsMP",_requester];
} else {
    [petros,"globalChat","No Humanitarian Aid is available."] remoteExec ["A3A_fnc_commsMP",_requester];
    [petros,"hint","No nearby infected-held town currently qualifies, or supplies cannot be placed safely at HQ.",
        "Humanitarian Aid"] remoteExec ["A3A_fnc_commsMP",_requester];
};
