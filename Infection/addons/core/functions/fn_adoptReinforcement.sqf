/* Atomically hand a paid, budgeted foot group to an active persistent site.
   [group, marker] -> [success, count, reason]. No additional spawn or resource
   debit occurs. A repeated handoff cannot add the same survivors twice. */
params [["_group",grpNull,[grpNull]], ["_marker","",[""]]];
if (!isServer || {isRemoteExecuted && {remoteExecutedOwner != 2}})
    exitWith {[false,0,"server_origin_only"]};
if (canSuspend) exitWith {[A3I_fnc_adoptReinforcement,_this] call CBA_fnc_directCall};
if (isNull _group || {!local _group} || {side _group != west}
    || {!([west] call A3I_fnc_isActive)} || {isNil "A3I_sites"} || {isNil "A3I_budgetRecords"}
    || {isNil "garrison"} || {isNil "spawner"} || {isNil "sidesX"})
    exitWith {[false,0,"inactive"]};
if (_group getVariable ["A3I_garrisoned",""] != "")
    exitWith {[false,0,"already_adopted"]};
private _site = A3I_sites getOrDefault [_marker,createHashMap];
if (!(_site getOrDefault ["kind",""] in ["Resource","Outpost","Milbase","Airport"])
    || {_site get "cleaned"} || {scriptDone (_site get "script")}
    || {_site get "fault" != ""} || {spawner getVariable [_marker,2] != 0}
    || {sidesX getVariable [_marker,sideUnknown] != west})
    exitWith {[false,0,"inactive_site"]};
private _units = units _group select {alive _x};
if (_units isEqualTo []) exitWith {[false,0,"empty_group"]};
private _ticket = (_units # 0) getVariable ["A3I_budgetTicket",""];
if (_ticket == "" || {(_units findIf {
    !local _x || {!([_x] call A3I_fnc_isManagedUnit)}
    || {!(_x getVariable ["A3I_reinforcementPaid",false])}
    || {_x getVariable ["A3A_resPool",""] != "defence"}
    || {_x getVariable ["markerX",""] != ""}
    || {_x getVariable ["A3I_budgetTicket",""] != _ticket}
    || {_x distance2D getMarkerPos _marker > 200}
}) != -1}) exitWith {[false,0,"invalid_arrivals"]};
// A ticket must belong to this whole living group, not unrelated actors.
private _binding = A3I_budgetRecords getOrDefault [_ticket,[]];
if (_binding isEqualTo [] || {((_binding # 2) select {alive _x}) - _units isNotEqualTo []}
    || {_units - (_binding # 2) isNotEqualTo []})
    exitWith {[false,0,"mixed_ticket"]};
if (missionNamespace getVariable ["garrisonIsChanging",false])
    exitWith {[false,0,"garrison_busy"]};
private _roster = +(garrison getVariable [_marker,[]]);
private _capacity = [_marker] call A3A_fnc_garrisonSize;
if (_capacity - count _roster < count _units) exitWith {[false,0,"garrison_full"]};
private _moved = ["transfer",[_ticket,_site get "context",24]] call A3I_fnc_budget;
if !(_moved # 0) exitWith {[false,0,_moved # 2]};
_roster append (_units apply {_x getVariable "unitType"});
garrison setVariable [_marker,_roster,true];
{
    _x setVariable ["A3A_resPool","garrison",true];
    _x setVariable ["markerX",_marker,true];
    _x setVariable ["spawner",nil,true];
} forEach _units;
(_site get "units") append _units;
(_site get "groups") pushBackUnique _group;
_group setVariable ["A3I_context",_site get "context"];
_group setVariable ["A3I_garrisoned",_marker];
private _waypoint = _group addWaypoint [getMarkerPos _marker,0];
_waypoint setWaypointType "MOVE";
_waypoint setWaypointCompletionRadius 15;
_group setCurrentWaypoint _waypoint;
[true,count _units,""]
