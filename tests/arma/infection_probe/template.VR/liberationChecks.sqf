// Selector contracts only. Synthetic navigation does not certify Redux travel,
// survivor interaction, defense pacing, political fallback or mission settlement.
private _before = entities [[],[],true,false];
private _groupsBefore = +allGroups;
sidesX = [true] call A3A_fnc_createNamespace;
spawner = [true] call A3A_fnc_createNamespace;
server = [true] call A3A_fnc_createNamespace;
private _town = "a3i_lib_target";
private _sources = ["a3i_lib_airport","a3i_lib_outpost","a3i_lib_base","a3i_lib_port",
    "a3i_lib_factory","a3i_lib_resource","a3i_lib_town","a3i_lib_admin"];
respawnTeamPlayer = "a3i_lib_hq";
createMarker [_town,[5000,4500,0]];
createMarker [respawnTeamPlayer,[6000,5000,0]];
{createMarker [_x,[4000,4500,0]]} forEach _sources;
private _markers = _sources + [_town,respawnTeamPlayer];
{
    _x setMarkerShape "ELLIPSE"; _x setMarkerSize [200,200];
    sidesX setVariable [_x,west]; spawner setVariable [_x,2]; server setVariable [_x,0];
} forEach _markers;
sidesX setVariable [respawnTeamPlayer,teamPlayer];
airportsX = [_sources # 0]; outposts = [_sources # 1]; milbases = [_sources # 2];
seaports = [_sources # 3]; factories = [_sources # 4]; resourcesX = [_sources # 5];
citiesX = [_sources # 6,_town]; milAdministrationsX = [_sources # 7];
forcedSpawn = []; townSkirmishes = []; bigAttackInProgress = false;
areOccupantsDefeated = false; distanceForLandAttack = 2000;
A3I_majorGlobalOwner = nil; A3I_majorSourceCooldowns = createHashMap;
A3A_recentDamageOcc = [];
private _population = [100,4,20,80];
server setVariable [_town,+_population]; server setVariable [_sources # 6,+_population];
NavGrid = [[[4000,4500,0],1,0,[[1,0,1000]]],[[5000,4500,0],1,0,[[0,0,1000]]]];
A3A_navCellHM = createHashMap; {_forEachIndex call A3A_fnc_addToNavCells} forEach NavGrid;
A3A_markerNavPoints = createHashMap;
private _select = {[_town] call A3I_fnc_liberationSources};

["lib_sources_registered",!isNil "A3I_fnc_liberationSources"] call _check;
private _routes = call _select;
["lib_all_permanent_sources",count _routes == 8
    && {((_routes apply {_x # 0}) arrayIntersect _sources) isEqualTo _sources},_routes] call _check;
citiesX append [_sources # 6,_town];
_routes = call _select;
["lib_target_excluded_duplicates_collapsed",count _routes == 8
    && {(_routes findIf {_x # 0 == _town}) == -1}] call _check;
citiesX = [_sources # 6,_town];
["lib_non_town_refused",[_sources # 0] call A3I_fnc_liberationSources isEqualTo []
    && {["missing"] call A3I_fnc_liberationSources isEqualTo []}] call _check;
sidesX setVariable [_town,teamPlayer];
["lib_rebel_town_refused",call _select isEqualTo []] call _check;
sidesX setVariable [_town,Invaders];
["lib_invader_town_refused",call _select isEqualTo []] call _check;
sidesX setVariable [_town,west];
townSkirmishes = [_town];
["lib_existing_skirmish_refused",call _select isEqualTo []] call _check;
townSkirmishes = []; forcedSpawn = [_town];
["lib_forced_target_refused",call _select isEqualTo []] call _check;
forcedSpawn = []; bigAttackInProgress = true;
["lib_other_attack_preserved",call _select isEqualTo [] && {bigAttackInProgress}] call _check;
bigAttackInProgress = false; A3I_majorGlobalOwner = "foreign";
["lib_other_horde_preserved",call _select isEqualTo [] && {A3I_majorGlobalOwner == "foreign"}] call _check;
A3I_majorGlobalOwner = nil; areOccupantsDefeated = true;
["lib_defeated_refused",call _select isEqualTo []] call _check;
areOccupantsDefeated = false; A3A_faction_occ set ["infectionTemplate",""];
["lib_inactive_refused",call _select isEqualTo []] call _check;
A3A_faction_occ set ["infectionTemplate","A3I_Infected"]; A3I_dependencies set ["available",false];
["lib_missing_dependencies_refused",call _select isEqualTo []] call _check;
A3I_dependencies set ["available",true];
{sidesX setVariable [_x,Invaders]} forEach _sources;
["lib_unowned_sources_refused",call _select isEqualTo []] call _check;
private _source = _sources # 6;
sidesX setVariable [_source,west]; spawner setVariable [_source,0];
["lib_active_source_refused",call _select isEqualTo []] call _check;
spawner setVariable [_source,2]; A3I_majorSourceCooldowns set [_source,time + 600];
["lib_source_cooldown_honored",call _select isEqualTo []] call _check;
A3I_majorSourceCooldowns deleteAt _source; A3A_recentDamageOcc = [[4000,4500,60]];
["lib_combat_source_refused",call _select isEqualTo []] call _check;
A3A_recentDamageOcc = []; _source setMarkerPos [9000,4500,0];
["lib_distant_source_refused",call _select isEqualTo []] call _check;
_source setMarkerPos [4000,4500,0];
private _nav = +NavGrid;
NavGrid = [[[4000,4500,0],1,0,[]],[[5000,4500,0],1,0,[]]];
["lib_disconnected_source_refused",call _select isEqualTo []] call _check;
NavGrid = _nav;
private _unscheduled = [A3I_fnc_liberationSources,[_town]] call CBA_fnc_directCall;
["lib_scheduled_only",_unscheduled isEqualTo []] call _check;
_routes = call _select;
["lib_selection_has_no_campaign_effects",count _routes == 1 && {_routes # 0 # 0 == _source}
    && {sidesX getVariable _town == west} && {server getVariable _town isEqualTo _population}
    && {server getVariable _source isEqualTo _population} && {count A3I_majorSourceCooldowns == 0}
    && {!bigAttackInProgress} && {townSkirmishes isEqualTo []} && {forcedSpawn isEqualTo []}] call _check;
// No alternate origin: the selector must not silently reinsert a default base.
airportsX = []; outposts = []; milbases = []; seaports = []; factories = [];
resourcesX = []; citiesX = [_town]; milAdministrationsX = [];
["lib_no_external_origin_empty",call _select isEqualTo [] && {sidesX getVariable _town == west}] call _check;

{deleteMarker _x} forEach _markers;
deleteVehicle sidesX; deleteVehicle spawner; deleteVehicle server;
sleep 0.2;
["lib_sources_cleanup",entities [[],[],true,false] - _before isEqualTo []
    && {allGroups - _groupsBefore isEqualTo []}
    && {(_markers findIf {_x in allMapMarkers}) == -1}] call _check;
