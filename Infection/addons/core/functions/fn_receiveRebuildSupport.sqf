// The only player-origin ingress for rebuilding responses. Ignore client costs,
// faction choices, support types and names; the server recomputes those values.
params [["_site","",[""]],["_position",[],[[]]],["_requester",objNull,[objNull]]];
if (!isServer || {!canSuspend} || {!isRemoteExecuted} || {isNull _requester}
    || {!isPlayer _requester} || {owner _requester != remoteExecutedOwner}
    || {!(_requester in (allPlayers - entities "HeadlessClient_F"))}
    || {side group _requester != teamPlayer}
    || {!([west] call A3I_fnc_isActive)}
    || {!(_site in (missionNamespace getVariable ["markersX",[]]))}
    || {!(_site in allMapMarkers)} || {!(count _position in [2,3])}
    || {(_position findIf {!(_x isEqualType 0) || {!finite _x}}) != -1}
    || {getMarkerPos _site distance2D _position > 50}) exitWith {};
// Allow the native public rebuilding flag to arrive, then enter a local server
// script. Spawning remains independent of the remote caller's execution context.
[_site,+_position] spawn {
    params ["_site","_position"];
    private _deadline = diag_tickTime + 5;
    waitUntil {
        sleep 0.05;
        missionNamespace getVariable ["A3U_rebuilding_" + _site,false]
            || {diag_tickTime >= _deadline}
    };
    [_site,_position] call A3I_fnc_rebuildSupport;
};
