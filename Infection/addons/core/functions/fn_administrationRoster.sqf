/* Ultimate 12.4.2 administration role/count selection, without a vehicle or
   human-officer objective. [marker] -> [roles, branch, registered building]. */
params [["_marker","",[""]]];
if !([west] call A3I_fnc_isActive) exitWith {[[],"inactive",objNull]};
if (!(_marker in allMapMarkers) || {isNil "milAdministrationsX"}
    || {!(_marker in milAdministrationsX)} || {isNil "A3A_milAdministrations"}
    || {isNil "A3A_destroyedMilAdministrations"}) exitWith {[[],"invalid_administration",objNull]};
private _center = getMarkerPos _marker;
private _index = A3A_milAdministrations findIf {!isNull _x && {_x distance2D _center < 30}};
if (_index == -1) exitWith {[[],"missing_building",objNull]};
private _building = A3A_milAdministrations # _index;
if (_building in A3A_destroyedMilAdministrations) exitWith {[[],"completed",_building]};
if (_marker in townSkirmishes) exitWith {[[],"skirmish",_building]};
// A ruined building can still contain an uncleared Infection objective.
private _difficult = [_marker] call A3A_fnc_isFrontline || {random 10 < tierWar + aggressionOccupants / 10};
private _faction = A3A_faction_occ;
private _pool = if (_difficult) then {
    ["unitMilitiaGrunt","unitMilitiaMarksman","unitMilitiaGrenadier","unitMilitiaSniper","unitMilitiaMedic"]
} else {["unitPoliceGrunt"]};
_pool = _pool apply {_faction get _x};
private _leader = _faction get (if (_difficult) then {"unitMilitiaGrunt"} else {"unitPoliceOfficer"});
private _roles = [_leader,selectRandom _pool];
private _count = round (if (_difficult) then {random [4,6,8]} else {random [3,5,7]});
// The upstream loop is inclusive, so preserve count + 1 interior guard roles.
for "_i" from 0 to _count do {_roles pushBack selectRandom _pool};
_roles pushBack (_faction get "unitOfficial");
[_roles,if (_difficult) then {"militia"} else {"police"},_building]
