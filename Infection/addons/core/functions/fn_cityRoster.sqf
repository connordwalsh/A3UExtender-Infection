/* Per-visit town selection adapted from Ultimate 12.4.2 createAICities (MIT).
   Preserve support/size/frontline scaling, skip rules and ruined-town roles.
   [marker] -> [roles, branch, batch size]. No saved garrison or civilian edits. */
params [["_marker","",[""]]];
if !([west] call A3I_fnc_isActive) exitWith {[[],"inactive",2]};
if (isNil "citiesX" || {!(_marker in citiesX)} || {!(_marker in allMapMarkers)}
    || {isNil "A3A_townData"}) exitWith {[[],"invalid_town",2]};
private _center = getMarkerPos _marker;
if (((markersX - controlsX - milAdministrationsX) findIf {
    getMarkerPos _x inArea _marker && {sidesX getVariable [_x,sideUnknown] != west}
}) != -1) exitWith {[[],"overlap",2]};
private _data = A3A_townData getOrDefault [_marker,[]];
if !(_data isEqualType [] && {count _data >= 4}
    && {((_data select [2,2]) findIf {!(_x isEqualType 0) || {!finite _x}}) == -1})
    exitWith {[[],"invalid_town_data",2]};
if (_marker in townSkirmishes) exitWith {[[],"skirmish",2]};
if (A3A_faction_civ getOrDefault ["attributeCivNonHuman",false]
    && {selectRandom [1,2,3] == 2}) exitWith {[[],"nonhuman_skip",2]};
private _number = round (([_marker] call A3A_fnc_sizeMarker) / 100);
private _group = [];
private _branch = "";
if (_marker in destroyedSites) then {
    _group = selectRandom (A3A_faction_occ get "groupSpecOpsRandom");
    _branch = "destroyed";
} else {
    _number = round (_number * ((_data # 2) + (_data # 3)) / 100);
    if ([_marker] call A3A_fnc_isFrontline) then {
        _number = _number * 2;
        _group = selectRandom ([A3A_faction_occ,"groupsTierSmall"] call SCRT_fnc_unit_flattenTier);
        _branch = "frontline";
    } else {
        _group = A3A_faction_occ get "groupPolice";
        _branch = "police";
    };
};
_number = _number max 1;
private _roles = [];
for "_index" from 1 to _number do {_roles append _group};
// Police/frontline pairs remain pairs; larger ruined-town groups arrive in fours.
[_roles,_branch,(count _group) min 4]
