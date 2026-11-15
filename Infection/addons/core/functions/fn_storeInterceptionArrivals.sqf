/* Persist one complete, unobserved arrival group before retiring its actors.
   [job, group] -> [success, survivors, reason]. No spawn, capacity clamp or
   resource payment. Live destinations require a separate adoption path. */
params ["_record",["_group",grpNull,[grpNull]]];
if (!isServer || {isRemoteExecuted}) exitWith {[false,0,"server_local_only"]};
if (canSuspend) exitWith {[A3I_fnc_storeInterceptionArrivals,_this] call CBA_fnc_directCall};
private _name = _record getOrDefault ["name",""];
private _current = (missionNamespace getVariable ["A3I_interceptions",createHashMap])
    getOrDefault [_name,createHashMap];
if (_current getOrDefault ["serial",-1] != _record getOrDefault ["serial",-2]
    || {!([west] call A3I_fnc_isActive)} || {_record getOrDefault ["retired",true]}
    || {!(_record getOrDefault ["settled",false])}
    || {_record getOrDefault ["outcome",""] != "arrived"}
    || {_record getOrDefault ["phase",""] != "arrived"})
    exitWith {[false,0,"inactive_job"]};
if (isNull _group || {!local _group} || {side _group != west})
    exitWith {[false,0,"invalid_group"]};
if (_group getVariable ["A3I_garrisoned",""] != "")
    exitWith {[false,0,"already_adopted"]};
private _marker = _record get "target";
private _context = _record get "context";
if (!(_group in (_record get "groups")) || {_group getVariable ["A3I_context",""] != _context})
    exitWith {[false,0,"foreign_group"]};
if (isNil "garrison" || {isNil "spawner"} || {isNil "sidesX"}
    || {!(_marker in allMapMarkers)} || {sidesX getVariable [_marker,sideUnknown] != west})
    exitWith {[false,0,"inactive_destination"]};
// Regenerated towns/administrations keep these roles as persistent additions.
private _locations = call A3I_fnc_interceptionLocations;
if (!(_marker in _locations) || {spawner getVariable [_marker,2] != 2}
    || {count ((missionNamespace getVariable ["A3I_sites",createHashMap])
        getOrDefault [_marker,createHashMap]) != 0})
    exitWith {[false,0,"destination_live_or_unsupported"]};
if (missionNamespace getVariable ["garrisonIsChanging",false])
    exitWith {[false,0,"garrison_busy"]};
private _units = units _group select {alive _x};
if (_units isEqualTo []) exitWith {[false,0,"empty_group"]};
private _ticket = (_units # 0) getVariable ["A3I_budgetTicket",""];
private _definitions = A3A_faction_occ get "loadouts";
if ((_units findIf {
    private _role = _x getVariable ["unitType",""];
    !local _x || {!([_x] call A3I_fnc_isManagedUnit)} || {isObjectHidden _x}
    || {!(_x in (_record get "units"))}
    || {_x getVariable ["A3I_interceptionName",""] != _name}
    || {_x getVariable ["A3I_interceptionSerial",-1] != _record get "serial"}
    || {_x getVariable ["A3I_interceptionResolved",false]}
    || {_x getVariable ["markerX",""] != ""}
    || {_x getVariable ["A3I_budgetTicket",""] != _ticket}
    || {!([_x,_marker] call A3I_fnc_interceptionContains)} || {!(_x call A3A_fnc_canFight)}
    || {!(_role isEqualType "")} || {_role find "loadouts_occ_" != 0}
    || {!((_role select [13]) in _definitions)}
}) != -1) exitWith {[false,0,"invalid_arrivals"]};
private _binding = (missionNamespace getVariable ["A3I_budgetRecords",createHashMap])
    getOrDefault [_ticket,[]];
if (_binding isEqualTo [] || {_binding # 0 != _context} || {!(_binding param [7,false])}
    || {!(_binding # 4)} || {_binding # 1 != 0}
    || {((_binding # 2) select {alive _x}) - _units isNotEqualTo []}
    || {_units - (_binding # 2) isNotEqualTo []})
    exitWith {[false,0,"invalid_ticket"]};
private _observers = call A3I_fnc_spawnObservers;
private _distance = (missionNamespace getVariable ["distanceSPWN",1000]) max 150;
private _siteDistance = (missionNamespace getVariable ["distanceSPWN1",1000]) max 150;
if ((_observers findIf {
    private _observer = _x;
    _observer distance2D getMarkerPos _marker < _siteDistance
    || {(_units findIf {_observer distance2D _x < _distance}) != -1}
}) != -1) exitWith {[false,0,"observed"]};
// Atomic roster append and actor retirement: retries cannot duplicate survivors,
// and native healthy deletion neither refunds resources nor removes saved roles.
private _roster = +(garrison getVariable [_marker,[]]);
_roster append (_units apply {_x getVariable "unitType"});
garrison setVariable [_marker,_roster,true];
_group setVariable ["A3I_garrisoned",_marker];
_group setVariable ["A3I_context",""];
{
    _x setVariable ["A3A_resPool","garrison",true];
    _x setVariable ["markerX",_marker,true];
    _x setVariable ["A3I_interceptionResolved",true];
} forEach _units;
_record set ["storedArrivals",(_record getOrDefault ["storedArrivals",0]) + count _units];
_record set ["units",(_record get "units") - _units];
_record set ["groups",(_record get "groups") - [_group]];
["cancel",[_ticket]] call A3I_fnc_budget;
[[_group]] call A3I_fnc_cleanupGroups;
[true,count _units,"stored"]
