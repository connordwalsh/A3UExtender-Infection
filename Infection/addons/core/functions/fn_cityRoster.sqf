/* Per-visit town selection adapted from Ultimate 12.4.2 createAICities (MIT).
   Population controls quantity; frontline/ruined status selects basic roles.
   [marker] -> [roles, branch, batch size]. No saved garrison or civilian edits. */
params [["_marker","",[""]]];
if !([west] call A3I_fnc_isActive) exitWith {[[],"inactive",2]};
if (isNil "citiesX" || {!(_marker in citiesX)} || {!(_marker in allMapMarkers)}
    || {isNil "A3A_townData"}) exitWith {[[],"invalid_town",2]};
if (isNil "sidesX" || {sidesX getVariable [_marker,sideUnknown] != west})
    exitWith {[[],"inactive",2]};
private _center = getMarkerPos _marker;
if (((markersX - controlsX - milAdministrationsX) findIf {
    getMarkerPos _x inArea _marker && {sidesX getVariable [_x,sideUnknown] != west}
}) != -1) exitWith {[[],"overlap",2]};
private _data = A3A_townData getOrDefault [_marker,[]];
if !(_data isEqualType [] && {count _data >= 4}
    && {(_data # 0) isEqualType 0} && {finite (_data # 0)} && {_data # 0 >= 0})
    exitWith {[[],"invalid_town_data",2]};
if (_marker in townSkirmishes) exitWith {[[],"skirmish",2]};
if (A3A_faction_civ getOrDefault ["attributeCivNonHuman",false]
    && {selectRandom [1,2,3] == 2}) exitWith {[[],"nonhuman_skip",2]};
// getCityData stores [population, vehicles, government support, rebel support].
// Keep the ratio in one place for the later owner-requested server setting.
private _citizensPerInfected = 3;
private _number = round ((_data # 0) / _citizensPerInfected);
private _group = [];
private _branch = "";
if (_marker in destroyedSites) then {
    _group = selectRandom (A3A_faction_occ get "groupSpecOpsRandom");
    _branch = "destroyed";
} else {
    if ([_marker] call A3A_fnc_isFrontline) then {
        _group = selectRandom ([A3A_faction_occ,"groupsTierSmall"] call SCRT_fnc_unit_flattenTier);
        _branch = "frontline";
    } else {
        _group = A3A_faction_occ get "groupPolice";
        _branch = "police";
    };
};
private _roles = [];
if (_group isEqualTo []) exitWith {[[],"invalid_town_data",2]};
for "_index" from 0 to (_number - 1) do {_roles pushBack (_group # (_index mod count _group))};
// Police/frontline pairs remain pairs; larger ruined-town groups arrive in fours.
[_roles,_branch,(count _group) min 4]
