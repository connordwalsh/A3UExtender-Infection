// Internal outcome evaluation. Survivor failure takes precedence over a defense
// timer or force threshold reached in the same frame. No rewards or side effects.
params [["_record",createHashMap,[createHashMap]]];
if (!isServer || {isRemoteExecuted}) exitWith {"cancelled"};
if (canSuspend) exitWith {[A3I_fnc_liberationOutcome,_this] call CBA_fnc_directCall};
private _outcome = _record getOrDefault ["outcome","cancelled"];
if (_outcome != "pending") exitWith {_outcome};
private _town = _record getOrDefault ["town",""];
private _source = _record getOrDefault ["source",""];
if (!([west] call A3I_fnc_isActive) || {missionNamespace getVariable ["areOccupantsDefeated",false]}
    || {!(_town in allMapMarkers)} || {!(_source in allMapMarkers)}
    || {sidesX getVariable [_town,sideUnknown] != west}
    || {sidesX getVariable [_source,sideUnknown] != west}) exitWith {"cancelled"};
private _vip = _record getOrDefault ["vip",objNull];
if (!(_vip call A3A_fnc_canFight)
    || {_vip distance2D getMarkerPos _town > (200 max ([_town] call A3A_fnc_sizeMarker))})
    exitWith {"survivor_lost"};
if (time >= _record getOrDefault ["expiresAt",0]) exitWith {"expired"};
private _horde = _record getOrDefault ["majorRecord",createHashMap];
if (count _horde == 0) exitWith {"pending"};
if (_horde getOrDefault ["outcome","cancelled"] in ["cancelled","interrupted","no_force","unreached"])
    exitWith {"cancelled"};
if (_horde get "paidActors" == 0) exitWith {"pending"};
private _remaining = {_x call A3A_fnc_canFight} count (_horde get "units");
_remaining = _remaining + count (_horde get "queue");
if (_remaining <= round ((_horde get "planned") * 0.3)) exitWith {"won"};
if (_horde get "arrived" && {!isNil {_horde get "arrivedAt"}}
    && {time >= (_horde get "arrivedAt") + 600}) exitWith {"won"};
"pending"
