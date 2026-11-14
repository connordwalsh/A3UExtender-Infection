// Local server rebuilding response: one attempt per active native rebuild.
// [site, position] -> [accepted, estimate, reason].
params [["_site","",[""]],["_position",[],[[]]]];
if (!isServer || {!canSuspend} || {isRemoteExecuted}) exitWith {[false,0,"server_local_only"]};
if (!([west] call A3I_fnc_isActive) || {!(_site in (missionNamespace getVariable ["markersX",[]]))}
    || {!(_site in allMapMarkers)} || {!(count _position in [2,3])}
    || {(_position findIf {!(_x isEqualType 0) || {!finite _x}}) != -1}
    || {getMarkerPos _site distance2D _position > 50}
    || {sidesX getVariable [_site,sideUnknown] != teamPlayer}
    || {!(missionNamespace getVariable ["A3U_rebuilding_" + _site,false])})
    exitWith {[false,0,"inactive_rebuild"]};
private _enemies = (airportsX + milbases + outposts + seaports + factories + resourcesX) select {
    _x in allMapMarkers && {sidesX getVariable [_x,sideUnknown] in [Occupants,Invaders]}
};
if (_enemies isEqualTo []) exitWith {[false,0,"source"]};
private _nearest = [_enemies,_position] call BIS_fnc_nearestPosition;
if (sidesX getVariable [_nearest,sideUnknown] != west) exitWith {[false,0,"source_changed"]};
private _cost = missionNamespace getVariable ["A3A_balanceVehicleCost",0];
private _tier = missionNamespace getVariable ["tierWar",0];
if !(_cost isEqualType 0 && {finite _cost} && {_cost > 0}
    && {_tier isEqualType 0} && {finite _tier} && {_tier >= 0}) exitWith {[false,0,"allowance"]};
private _name = "";
isNil {
    if (isNil "A3I_rebuildClaims") then {A3I_rebuildClaims = createHashMap; A3I_rebuildSerial = 0};
    if (_site in A3I_rebuildClaims) exitWith {};
    A3I_rebuildSerial = A3I_rebuildSerial + 1;
    _name = "REBUILD_FOOT_" + str A3I_rebuildSerial;
    A3I_rebuildClaims set [_site,_name];
    if (isNil "A3I_rebuildWatchdogHandle") then {
        A3I_rebuildWatchdogHandle = [A3I_fnc_rebuildSupportWatchdog,2] call CBA_fnc_addPerFrameHandler;
    };
};
if (_name == "") exitWith {[false,0,"pending"]};
// Match native rebuild sizing; startTacticalSupport applies its own affordable
// actor ceiling and charges only actual births. No client-supplied budget enters.
[_name,"attack",_cost * (2 + round (_tier / 3)),false,_position,1,-1]
    call A3I_fnc_startTacticalSupport
