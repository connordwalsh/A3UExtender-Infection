params [["_requester",clientOwner,[0]],["_silent",false,[false]]];
if (!isServer || {!canSuspend} || {isRemoteExecuted}) exitWith {};
waitUntil {sleep 0.1; isNil "A3A_missionRequestInProgress" || {!([west] call A3I_fnc_isActive)}};
if (!([west] call A3I_fnc_isActive) || {isNil "petros"} || {isNull petros}
    || {!alive petros} || {leader group petros != petros}) exitWith {};
if (call A3I_fnc_interceptionBusy) exitWith {
    if (!_silent) then {[petros,"globalChat",localize "STR_chats_mission_request_already_type"]
        remoteExec ["A3A_fnc_commsMP",_requester]};
};
private _result = [] call A3I_fnc_startInterception;
private _registered = false;
if (_result # 0) then {
    private _job = A3I_interceptions get (_result # 1);
    waitUntil {sleep 0.1; _job getOrDefault ["taskRegistered",false] || {_job getOrDefault ["settled",false]}};
    _registered = _job getOrDefault ["taskRegistered",false];
};
if (_silent) exitWith {};
if (_registered) then {
    [petros,"globalChat",localize "STR_chats_mission_request_success"] remoteExec ["A3A_fnc_commsMP",_requester];
} else {
    [petros,"globalChat","No Horde Interception is available."] remoteExec ["A3A_fnc_commsMP",_requester];
    [petros,"hint","No safe walking route from a nearby infected-held location is currently available, or another major battle is underway.",
        "Horde Interception"] remoteExec ["A3A_fnc_commsMP",_requester];
};
