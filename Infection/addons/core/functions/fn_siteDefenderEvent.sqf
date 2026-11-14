// Object absence is not kill credit. An interrupted/cleaned old visit cannot
// change a later visit's record, even when the marker name is reused.
params ["_event","_unit"];
if (!isServer || {isNil "_thisEvent"} || {_thisEvent != _event}
    || {!(_event in ["Killed","Deleted"])}
    || {_unit getVariable ["A3I_clearanceResolved",false]}) exitWith {};
private _marker = _unit getVariable ["A3I_clearanceMarker",""];
private _record = (missionNamespace getVariable ["A3I_sites",createHashMap])
    getOrDefault [_marker,createHashMap];
if (_record getOrDefault ["id",-1] != _unit getVariable ["A3I_clearanceSiteId",-2]
    || {_record getOrDefault ["cleaned",true]}) exitWith {};
_unit setVariable ["A3I_clearanceResolved",true];
if (_event == "Killed" && {!alive _unit}) exitWith {
    _record set ["clearanceRemaining",((_record get "clearanceRemaining") - 1) max 0];
};
// Administrative strongholds already replace live-deleted defenders without
// consuming their remaining roster count. Other sites have no such replacement
// contract: retain the obligation and expose the missing actor to the mission.
if (_event == "Deleted" && {_record getOrDefault ["kind",""] != "MilAdmin"}) then {
    _record set ["clearanceMissing",(_record getOrDefault ["clearanceMissing",0]) + 1];
};
