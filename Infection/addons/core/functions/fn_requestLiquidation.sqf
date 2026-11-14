// Preserve native request eligibility and notifications. The CON claim is
// atomic, so it needs no sleeping ownership of the shared request lock.
params [["_requester",clientOwner,[0]],["_silent",false,[false]]];
if (!isServer || {!canSuspend} || {isRemoteExecuted}) exitWith {};
waitUntil {sleep 0.1; isNil "A3A_missionRequestInProgress" || {!([west] call A3I_fnc_isActive)}};
if (!([west] call A3I_fnc_isActive) || {isNil "petros"} || {isNull petros}
    || {!alive petros} || {leader group petros != petros}) exitWith {};
if ("CON" in (missionNamespace getVariable ["A3A_activeTasks",[]])
    || {count (missionNamespace getVariable ["A3I_liquidationClaims",createHashMap]) > 0}) exitWith {
    if (!_silent) then {[petros,"globalChat",localize "STR_chats_mission_request_already_type"]
        remoteExec ["A3A_fnc_commsMP",_requester]};
};
private _targets = call A3I_fnc_liquidationTargets;
private _accepted = _targets isNotEqualTo [] && {[selectRandom _targets] call A3I_fnc_startLiquidation};
if (_silent) exitWith {};
if (_accepted) then {
    [petros,"globalChat",localize "STR_chats_mission_request_success"] remoteExec ["A3A_fnc_commsMP",_requester];
} else {
    [petros,"globalChat","No Liquidation Assignment is available."] remoteExec ["A3A_fnc_commsMP",_requester];
    [petros,"hint",format ["No eligible infected-held location is within %1 metres of HQ. Military bases and airfields require war level 3.",distanceMission],
        "Liquidation Assignment"] remoteExec ["A3A_fnc_commsMP",_requester];
};
