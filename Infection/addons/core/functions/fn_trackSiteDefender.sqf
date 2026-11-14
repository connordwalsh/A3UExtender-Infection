// Site-local kill ledger for full-clear objectives. The site already counts its
// queued roster; attaching an actor does not add another obligation. Adoption
// explicitly adds arriving reinforcements before attaching them here.
params ["_unit","_marker","_context"];
if (!isServer || {isRemoteExecuted && {remoteExecutedOwner != 2}}
    || {isNull _unit} || {!local _unit}) exitWith {false};
private _record = (missionNamespace getVariable ["A3I_sites",createHashMap])
    getOrDefault [_marker,createHashMap];
if (count _record == 0 || {_record getOrDefault ["cleaned",true]}
    || {_record getOrDefault ["context",""] != _context}
    || {isNil {_record get "clearanceRemaining"}}
    || {_unit getVariable ["A3I_clearanceTracked",false]}) exitWith {false};
_unit setVariable ["A3I_clearanceTracked",true];
_unit setVariable ["A3I_clearanceMarker",_marker];
_unit setVariable ["A3I_clearanceSiteId",_record get "id"];
_unit setVariable ["A3I_clearanceResolved",false];
_unit addEventHandler ["Killed",{["Killed",_this # 0] call A3I_fnc_siteDefenderEvent}];
_unit addEventHandler ["Deleted",{["Deleted",_this # 0] call A3I_fnc_siteDefenderEvent}];
true
