// Selection only. Does not certify the later task/capture/reward lifecycle.
private _names = ["sidesX","petros","tierWar","distanceMission","citiesX","milAdministrationsX",
    "airportsX","milbases","outposts","seaports","factories","resourcesX","controlsX"];
private _saved = createHashMap;
{_saved set [_x,missionNamespace getVariable [_x,nil]]} forEach _names;
sidesX = [true] call A3A_fnc_createNamespace;
private _group = createGroup [civilian,false];
petros = _group createUnit ["C_man_1",[4000,4000,0],[],0,"NONE"];
petros disableAI "ALL";
tierWar = 1; distanceMission = 1000;
private _spec = [["citiesX","City"],["milAdministrationsX","MilAdmin"],
    ["airportsX","Airport"],["milbases","Milbase"],["outposts","Outpost"],
    ["seaports","Outpost"],["factories","Resource"],["resourcesX","Resource"]];
private _markers = [];
{
    private _marker = "a3i_liquidation_" + (_x # 0);
    createMarker [_marker,[4000 + 20 * _forEachIndex,4100,0]];
    sidesX setVariable [_marker,west];
    missionNamespace setVariable [_x # 0,[_marker]];
    _markers pushBack _marker;
} forEach _spec;
controlsX = [];
["liquidation_kinds_resolve",(_spec findIf {
    ["a3i_liquidation_" + (_x # 0)] call A3I_fnc_liquidationTargetKind != _x # 1
}) == -1 && {["missing"] call A3I_fnc_liquidationTargetKind == ""}] call _check;
private _early = call A3I_fnc_liquidationTargets;
["liquidation_early_towns_and_sites",count _early == 6 && {citiesX # 0 in _early}
    && {(_early arrayIntersect (airportsX + milbases)) isEqualTo []}] call _check;
outposts append airportsX;
["liquidation_military_alias_cannot_bypass_tier",((call A3I_fnc_liquidationTargets) arrayIntersect airportsX) isEqualTo []] call _check;
outposts = ["a3i_liquidation_outposts"];
tierWar = 3;
private _all = call A3I_fnc_liquidationTargets;
["liquidation_tier_three_all_sites",count _all == 8 && {_markers - _all isEqualTo []}] call _check;
factories append resourcesX;
["liquidation_duplicate_lists_unique",count (call A3I_fnc_liquidationTargets) == 8] call _check;
factories = ["a3i_liquidation_factories"];
sidesX setVariable [citiesX # 0,east];
sidesX setVariable [outposts # 0,teamPlayer];
sidesX setVariable [resourcesX # 0,civilian];
private _hostile = call A3I_fnc_liquidationTargets;
["liquidation_infected_only",count _hostile == 5
    && {(_hostile arrayIntersect (citiesX + outposts + resourcesX)) isEqualTo []}] call _check;
{sidesX setVariable [_x,west]} forEach _markers;
(citiesX # 0) setMarkerPos [12000,12000,0];
["liquidation_native_distance_restriction",!(citiesX # 0 in (call A3I_fnc_liquidationTargets))] call _check;
(citiesX # 0) setMarkerPos [4000,4100,0];
private _field = "a3i_liquidation_field_control";
createMarker [_field,[4500,4500,0]]; controlsX = [_field]; sidesX setVariable [_field,west];
["liquidation_field_controls_excluded",!isOnRoad getMarkerPos _field
    && {[_field] call A3I_fnc_liquidationTargetKind == ""}
    && {!(_field in (call A3I_fnc_liquidationTargets))}] call _check;
A3A_faction_occ set ["infectionTemplate",""];
["liquidation_unselected_inactive",call A3I_fnc_liquidationTargets isEqualTo []] call _check;
A3A_faction_occ set ["infectionTemplate","A3I_Infected"];
A3I_dependencies set ["available",false];
["liquidation_dependencies_required",call A3I_fnc_liquidationTargets isEqualTo []] call _check;
A3I_dependencies set ["available",true];
deleteVehicle petros; sleep 0.1;
["liquidation_missing_hq_refused",call A3I_fnc_liquidationTargets isEqualTo []] call _check;
deleteGroup _group;
{deleteMarker _x} forEach (_markers + [_field]);
deleteVehicle sidesX;
{missionNamespace setVariable [_x,_saved get _x]} forEach _names;
