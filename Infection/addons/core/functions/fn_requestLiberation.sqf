// Resourcecheck's infected skirmish branch. Only an absent eligible origin may
// use the owner's peaceful fallback; busy claims/player presence are refusals.
params [["_town","",[""]]];
if (!isServer || {!canSuspend} || {isRemoteExecuted}) exitWith {[false,"server_local_scheduled"]};
private _eligible = {
    if (!([west] call A3I_fnc_isActive) || {missionNamespace getVariable ["areOccupantsDefeated",false]}
        || {isNil "sidesX"} || {isNil "spawner"}
        || {!(_town in (missionNamespace getVariable ["citiesX",[]]))} || {!(_town in allMapMarkers)}
        || {sidesX getVariable [_town,sideUnknown] != west}
        || {_town in (missionNamespace getVariable ["destroyedSites",[]])}
        || {_town in (missionNamespace getVariable ["townSkirmishes",[]])}
        || {_town in (missionNamespace getVariable ["forcedSpawn",[]])}
        || {missionNamespace getVariable ["bigAttackInProgress",false]} || {!isNil "A3I_majorGlobalOwner"}
        || {"townBattle" in (missionNamespace getVariable ["A3A_activeTasks",[]])}
        || {((values (missionNamespace getVariable ["A3I_liberations",createHashMap]))
            findIf {!(_x getOrDefault ["settled",false])}) != -1}) exitWith {false};
    private _data = (missionNamespace getVariable ["A3A_townData",createHashMap]) getOrDefault [_town,[]];
    if (!(_data isEqualType []) || {count _data < 4}
        || {(_data findIf {!(_x isEqualType 0) || {!finite _x}}) != -1}) exitWith {false};
    _data params ["_population","_vehicles","_government","_rebels"];
    if (round _population < 20 || {round (_population * _rebels / 100) < 1.5 * round (_population * _government / 100)})
        exitWith {false};
    private _radius = 200 max ([_town] call A3A_fnc_sizeMarker);
    ((call SCRT_fnc_misc_getRebelPlayers) findIf {alive _x && {_x distance2D getMarkerPos _town < _radius}}) == -1
};
if !(call _eligible) exitWith {[false,"ineligible"]};
private _routes = [_town] call A3I_fnc_liberationSources;
if !(call _eligible) exitWith {[false,"changed"]};
if (_routes isNotEqualTo []) exitWith {
    // If launch races with another job or loses its source, do not turn that
    // refused mission into a free town capture. A later resource tick can retry.
    private _result = [_town,(selectRandom _routes) # 0] call A3I_fnc_startLiberation;
    [_result # 0,if (_result # 0) then {"started"} else {_result # 1}]
};
// Preserve the ordinary native political transaction, including its delayed
// control/tier maintenance. This path has no rescue task or mission reward.
[_town,true] call A3A_fnc_cityChangeSide;
[true,"peaceful"]
