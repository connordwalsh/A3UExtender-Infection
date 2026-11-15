/* Transfer an arrived living group to an active town/permanent-site controller.
   [job, group] -> [success, survivors, reason]. No new actors or resource debit. */
params ["_record",["_group",grpNull,[grpNull]]];
if (!isServer || {isRemoteExecuted}) exitWith {[false,0,"server_local_only"]};
if (canSuspend) exitWith {[A3I_fnc_adoptInterceptionArrivals,_this] call CBA_fnc_directCall};
private _name = _record getOrDefault ["name",""];
private _current = (missionNamespace getVariable ["A3I_interceptions",createHashMap])
    getOrDefault [_name,createHashMap];
if (_current getOrDefault ["serial",-1] != _record getOrDefault ["serial",-2]
    || {!([west] call A3I_fnc_isActive)} || {_record getOrDefault ["retired",true]}
    || {!(_record getOrDefault ["settled",false])}
    || {_record getOrDefault ["outcome",""] != "arrived"}
    || {_record getOrDefault ["phase",""] != "arrived"})
    exitWith {[false,0,"inactive_job"]};
if (isNull _group || {!local _group} || {side _group != west}) exitWith {[false,0,"invalid_group"]};
if (_group getVariable ["A3I_garrisoned",""] != "") exitWith {[false,0,"already_adopted"]};
private _marker = _record get "target";
private _context = _record get "context";
if (!(_group in (_record get "groups")) || {_group getVariable ["A3I_context",""] != _context})
    exitWith {[false,0,"foreign_group"]};
if (isNil "garrison" || {isNil "spawner"} || {isNil "sidesX"}
    || {!(_marker in allMapMarkers)} || {sidesX getVariable [_marker,sideUnknown] != west})
    exitWith {[false,0,"inactive_destination"]};
private _site = (missionNamespace getVariable ["A3I_sites",createHashMap])
    getOrDefault [_marker,createHashMap];
if (spawner getVariable [_marker,2] != 0 || {_site getOrDefault ["context",""] != "site:" + _marker}
    || {_site getOrDefault ["cleaned",true]} || {_site getOrDefault ["fault","missing"] != ""}
    || {scriptDone (_site getOrDefault ["script",scriptNull])}
    || {!(_site getOrDefault ["kind",""] in ["City","Resource","Outpost","Milbase","Airport","MilAdmin"])}
    || {_site getOrDefault ["captured",sideUnknown] != sideUnknown}
    || {!(_marker in (call A3I_fnc_interceptionLocations))}
    || {isNil {_site get "clearanceRemaining"}})
    exitWith {[false,0,"site_unavailable"]};
if (missionNamespace getVariable ["garrisonIsChanging",false]) exitWith {[false,0,"garrison_busy"]};
private _units = units _group select {alive _x};
if (_units isEqualTo []) exitWith {[false,0,"empty_group"]};
private _ticket = (_units # 0) getVariable ["A3I_budgetTicket",""];
private _definitions = A3A_faction_occ get "loadouts";
if ((_units findIf {
    private _role = _x getVariable ["unitType",""];
    !local _x || {!([_x] call A3I_fnc_isManagedUnit)} || {isObjectHidden _x}
    || {!isNull (remoteControlled _x)} || {vehicle _x != _x}
    || {!(_x in (_record get "units"))}
    || {_x getVariable ["A3I_interceptionName",""] != _name}
    || {_x getVariable ["A3I_interceptionSerial",-1] != _record get "serial"}
    || {_x getVariable ["A3I_interceptionResolved",false]}
    || {_x getVariable ["A3I_clearanceTracked",false]}
    || {_x getVariable ["markerX",""] != ""}
    || {_x getVariable ["A3I_budgetTicket",""] != _ticket} || {!([_x,_marker] call A3I_fnc_interceptionContains)}
    || {!(_role isEqualType "")} || {_role find "loadouts_occ_" != 0}
    || {!((_role select [13]) in _definitions)}
}) != -1) exitWith {[false,0,"invalid_arrivals"]};
private _binding = (missionNamespace getVariable ["A3I_budgetRecords",createHashMap])
    getOrDefault [_ticket,[]];
if (_binding isEqualTo [] || {_binding # 0 != _context} || {!(_binding param [7,false])}
    || {!(_binding # 4)} || {_binding # 1 != 0}
    || {((_binding # 2) select {alive _x}) - _units isNotEqualTo []}
    || {_units - (_binding # 2) isNotEqualTo []}) exitWith {[false,0,"invalid_ticket"]};
private _moved = ["handoff",[_ticket,_name,_record get "serial",_marker,_site get "id"]] call A3I_fnc_budget;
if !(_moved # 0) exitWith {_moved};
// Nothing below yields. The saved roster and live obligations change together.
private _roster = +(garrison getVariable [_marker,[]]);
_roster append (_units apply {_x getVariable "unitType"});
garrison setVariable [_marker,_roster,true];
_site set ["clearanceRemaining",(_site get "clearanceRemaining") + count _units];
if (_site get "kind" == "MilAdmin") then {
    _site set ["remainingDefenders",(_site get "remainingDefenders") + count _units];
    _site set ["extraTarget",(_site getOrDefault ["extraTarget",0]) + count _units];
};
_site set ["adoptedCount",(_site getOrDefault ["adoptedCount",0]) + count _units];
(_site get "units") append _units; (_site get "groups") pushBackUnique _group;
_record set ["units",(_record get "units") - _units];
_record set ["groups",(_record get "groups") - [_group]];
_record set ["adoptedArrivals",(_record getOrDefault ["adoptedArrivals",0]) + count _units];
_group setVariable ["A3I_context",_site get "context"];
_group setVariable ["A3I_garrisoned",_marker];
{
    _x setVariable ["A3A_resPool","garrison",true];
    _x setVariable ["markerX",_marker,true];
    _x setVariable ["spawner",nil,true];
    _x setVariable ["A3I_interceptionResolved",true];
    [_x,_marker,_site get "context"] call A3I_fnc_trackSiteDefender;
    [_x,_marker,_site get "context"] call A3I_fnc_trackAdministrationDefender;
} forEach _units;
// Replace only group routing; native individual combat/pursuit remains intact.
while {waypoints _group isNotEqualTo []} do {deleteWaypoint [_group,0]};
if (_site get "kind" == "City") then {
    _group setVariable ["A3I_patrolCenter",getPosATL leader _group];
    [_group,_marker] call A3I_fnc_patrolWaypoints;
} else {
    private _waypoint = _group addWaypoint [getMarkerPos _marker,0];
    _waypoint setWaypointType "MOVE"; _waypoint setWaypointCompletionRadius 15;
    _group setCurrentWaypoint _waypoint;
};
[true,count _units,"adopted"]
