// Native town arrays, size/threat rules and navigation with controlled markers.
// Lifecycle and dispatch cases follow the selector checks below.
private _before = entities [[],[],true,false];
private _groupsBefore = +allGroups;
sidesX = [true] call A3A_fnc_createNamespace;
spawner = [true] call A3A_fnc_createNamespace;
garrison = [true] call A3A_fnc_createNamespace;
server = [true] call A3A_fnc_createNamespace;
private _sources = ["a3i_major_airport","a3i_major_outpost","a3i_major_base","a3i_major_resource",
    "a3i_major_factory","a3i_major_port","a3i_major_town","a3i_major_administration"];
private _town = "a3i_major_rebel_town";
private _enemySite = "a3i_major_enemy_site";
private _position = [5000,4500,0];
respawnTeamPlayer = "Synd_HQ";
createMarker [respawnTeamPlayer,[5000,4700,0]];
createMarker [_town,_position];
createMarker [_enemySite,_position];
{createMarker [_x,[4000,4500,0]]} forEach _sources;
private _markers = _sources + [_town,_enemySite,respawnTeamPlayer];
{
    _x setMarkerShape "ELLIPSE"; _x setMarkerSize [50,50];
    sidesX setVariable [_x,west]; spawner setVariable [_x,2];
    garrison setVariable [_x,[]]; server setVariable [_x,0];
} forEach _markers;
sidesX setVariable [_town,teamPlayer]; sidesX setVariable [respawnTeamPlayer,teamPlayer];
sidesX setVariable [_enemySite,Invaders];
airportsX = [_sources # 0]; outposts = [_sources # 1]; milbases = [_sources # 2];
resourcesX = [_sources # 3]; factories = [_sources # 4]; seaports = [_sources # 5];
citiesX = [_sources # 6,_town]; milAdministrationsX = [_sources # 7];
markersX = _sources + [_town]; controlsX = []; forcedSpawn = [];
antennas = []; antennasDead = []; staticsToSave = []; A3A_milBuildingWhitelist = [];
distanceForLandAttack = 2000; distanceSPWN = 1000; tierWar = 1; gameMode = 3;
A3A_curHQInfoOcc = 0; A3A_recentDamageOcc = []; A3A_recentDamageInv = [];
areOccupantsDefeated = false; plusGarrison = true;
A3I_majorSourceCooldowns = createHashMap;
private _sourceTownData = [123,10,75,0];
private _targetTownData = [400,3,40,60];
server setVariable [_sources # 6,+_sourceTownData]; server setVariable [_town,+_targetTownData];
NavGrid = [[[4000,4500,0],1,0,[[1,0,1000]]],[[5000,4500,0],1,0,[[0,0,1000]]]];
A3A_navCellHM = createHashMap; {_forEachIndex call A3A_fnc_addToNavCells} forEach NavGrid;
A3A_markerNavPoints = createHashMap;
private _role = "loadouts_occ_militia_Rifleman";

["major_functions_registered",!isNil "A3I_fnc_majorAttackTargets" && {!isNil "A3I_fnc_majorSourceEligible"}] call _check;
["major_all_permanent_origins",(_sources findIf {!([_x] call A3I_fnc_majorSourceEligible)}) == -1] call _check;
["major_transient_origin_refused",!([_enemySite] call A3I_fnc_majorSourceEligible)
    && {!(["missing"] call A3I_fnc_majorSourceEligible)}] call _check;
sidesX setVariable [_sources # 6,east];
["major_source_owner_checked",!([_sources # 6] call A3I_fnc_majorSourceEligible)] call _check;
sidesX setVariable [_sources # 6,west];
spawner setVariable [_sources # 6,0];
["major_active_source_refused",!([_sources # 6] call A3I_fnc_majorSourceEligible)] call _check;
spawner setVariable [_sources # 6,2];
forcedSpawn = [_sources # 6];
["major_forced_source_refused",!([_sources # 6] call A3I_fnc_majorSourceEligible)] call _check;
forcedSpawn = [];
A3I_majorSourceCooldowns set [_sources # 6,time + 60];
["major_town_cooldown_separate",!([_sources # 6] call A3I_fnc_majorSourceEligible)
    && {[_sources # 6,false] call A3I_fnc_majorSourceEligible}
    && {server getVariable (_sources # 6) isEqualTo _sourceTownData}] call _check;
A3I_majorSourceCooldowns deleteAt (_sources # 6);
server setVariable [_sources # 1,dateToNumber date + 0.01];
["major_military_idle_honored",!([_sources # 1] call A3I_fnc_majorSourceEligible)
    && {[_sources # 1,false] call A3I_fnc_majorSourceEligible}] call _check;
server setVariable [_sources # 1,[]];
["major_malformed_idle_refused",!([_sources # 1] call A3I_fnc_majorSourceEligible)] call _check;
server setVariable [_sources # 1,0];
A3A_recentDamageOcc = [[4000,4500,60]];
["major_source_combat_refused",!([_sources # 6] call A3I_fnc_majorSourceEligible)] call _check;
A3A_recentDamageOcc = [];

private _result = [teamPlayer] call A3I_fnc_majorAttackTargets;
["major_town_target_all_origins",count (_result # 0) == 8 && {count (_result # 1) == 8}
    && {count (((_result # 0) apply {_x # 1}) arrayIntersect _sources) == 8},_result # 0] call _check;
["major_native_town_value",((_result # 0) findIf {_x # 0 != _town || {abs (_x # 2 - 28) > 0.001}}) == -1] call _check;
["major_ground_record_contract",((_result # 0) findIf {count _x != 6 || {_x # 3 != 150}
    || {_x # 4 != 0} || {_x # 5 != 8}}) == -1] call _check;
["major_finite_positive_weights",((_result # 1) findIf {!finite _x || {_x <= 0}}) == -1] call _check;
["major_population_arrays_unchanged",server getVariable (_sources # 6) isEqualTo _sourceTownData
    && {server getVariable _town isEqualTo _targetTownData}] call _check;
private _expectedWeight = (28 / (150 * (0.5 + 1000 / 2500 + 3^(-8)))^0.8)^2;
private _sumWeight = 0; {_sumWeight = _sumWeight + _x} forEach (_result # 1);
["major_normalized_origin_weights",abs (_sumWeight - 10 * _expectedWeight) < 0.001,[_sumWeight,10 * _expectedWeight]] call _check;
outposts pushBack (_sources # 0);
["major_duplicate_origins_removed",count (([teamPlayer] call A3I_fnc_majorAttackTargets) # 0) == 8] call _check;
outposts = [_sources # 1];
server setVariable [_town,"invalid"];
["major_invalid_population_refused",[teamPlayer] call A3I_fnc_majorAttackTargets isEqualTo [[],[]]] call _check;
server setVariable [_town,+_targetTownData];
garrison setVariable [_town,[_role,_role,_role]];
_result = [teamPlayer] call A3I_fnc_majorAttackTargets;
["major_native_garrison_threat",((_result # 0) findIf {_x # 3 != 180}) == -1] call _check;
garrison setVariable [_town,[]];
sidesX setVariable [_town,west];
["major_owned_target_excluded",[teamPlayer] call A3I_fnc_majorAttackTargets isEqualTo [[],[]]] call _check;
sidesX setVariable [_town,teamPlayer];
["major_hq_unknown_excluded",((_result # 0) findIf {_x # 0 == respawnTeamPlayer}) == -1] call _check;
A3A_curHQInfoOcc = 1;
_result = [teamPlayer] call A3I_fnc_majorAttackTargets;
["major_hq_known_included",count ((_result # 0) select {_x # 0 == respawnTeamPlayer}) == 8] call _check;
A3A_curHQInfoOcc = 0;
factories pushBack _enemySite; markersX pushBack _enemySite;
_result = [Invaders] call A3I_fnc_majorAttackTargets;
["major_invader_sites_targeted",count (_result # 0) == 8 && {((_result # 0) findIf {_x # 0 != _enemySite}) == -1}] call _check;
["major_empty_enemy_threat_finite",((_result # 0) findIf {_x # 3 != 0}) == -1
    && {((_result # 1) findIf {!finite _x || {_x <= 0}}) == -1}] call _check;
private _siteValue = 15 + ([_enemySite,true] call A3A_fnc_garrisonSize) / 2;
["major_native_site_value",((_result # 0) findIf {_x # 2 != _siteValue}) == -1] call _check;
factories = [_sources # 4]; airportsX pushBack _enemySite;
_result = [Invaders] call A3I_fnc_majorAttackTargets;
private _airportValue = 60 + ([_enemySite,true] call A3A_fnc_garrisonSize) / 2;
["major_ready_airport_priority",((_result # 0) findIf {_x # 2 != _airportValue}) == -1] call _check;
forcedSpawn = [_sources # 0];
_result = [Invaders] call A3I_fnc_majorAttackTargets;
["major_no_airport_priority",count (_result # 0) == 7
    && {((_result # 0) findIf {_x # 2 != _airportValue + 30}) == -1}] call _check;
forcedSpawn = []; airportsX = [_sources # 0]; factories pushBack _enemySite;
_town setMarkerPos [8000,4500,0];
["major_distant_town_refused",[teamPlayer] call A3I_fnc_majorAttackTargets isEqualTo [[],[]]] call _check;
_town setMarkerPos _position;
private _savedNav = +NavGrid;
NavGrid = [[[4000,4500,0],1,0,[]],[[5000,4500,0],1,0,[]]];
["major_disconnected_route_refused",[teamPlayer] call A3I_fnc_majorAttackTargets isEqualTo [[],[]]] call _check;
NavGrid = _savedNav;
private _savedCells = A3A_navCellHM; A3A_navCellHM = createHashMap;
["major_missing_navigation_refused",[teamPlayer] call A3I_fnc_majorAttackTargets isEqualTo [[],[]]] call _check;
A3A_navCellHM = _savedCells;
distanceForLandAttack = 500;
["major_native_range_respected",[teamPlayer] call A3I_fnc_majorAttackTargets isEqualTo [[],[]]] call _check;
distanceForLandAttack = 2000;
forcedSpawn = +_sources;
["major_no_ready_source",[teamPlayer] call A3I_fnc_majorAttackTargets isEqualTo [[],[]]] call _check;
forcedSpawn = [];
areOccupantsDefeated = true;
["major_defeated_refused",[teamPlayer] call A3I_fnc_majorAttackTargets isEqualTo [[],[]]] call _check;
areOccupantsDefeated = false;
A3A_faction_occ set ["infectionTemplate",""];
["major_inactive_refused",[teamPlayer] call A3I_fnc_majorAttackTargets isEqualTo [[],[]]] call _check;
A3A_faction_occ set ["infectionTemplate","A3I_Infected"];
A3I_dependencies set ["available",false];
["major_missing_dependencies_refused",[teamPlayer] call A3I_fnc_majorAttackTargets isEqualTo [[],[]]] call _check;
A3I_dependencies set ["available",true];
["major_invalid_target_side",[west] call A3I_fnc_majorAttackTargets isEqualTo [[],[]]
    && {[civilian] call A3I_fnc_majorAttackTargets isEqualTo [[],[]]}] call _check;
private _atomic = []; isNil {_atomic = [teamPlayer] call A3I_fnc_majorAttackTargets};
["major_scheduled_required",_atomic isEqualTo [[],[]]] call _check;
// Broad major origins must not loosen the existing tactical default predicate.
["major_tactical_roster_guard_retained",[_position] call A3I_fnc_tacticalSources isEqualTo []] call _check;
private _roster = []; for "_i" from 1 to 16 do {_roster pushBack _role};
{garrison setVariable [_x,+_roster]} forEach (_sources select [0,3]);
private _tactical = [_position] call A3I_fnc_tacticalSources;
["major_tactical_candidates_unchanged",count _tactical == 3
    && {(_tactical findIf {!(_x # 0 in (_sources select [0,3]))}) == -1}] call _check;
["major_explicit_town_route",count ([_position,[_sources # 6],{_this call A3I_fnc_majorSourceEligible}]
    call A3I_fnc_tacticalSources) == 1] call _check;

["major_selector_no_actors",(entities [[],[],true,false]) - _before isEqualTo []
    && {allGroups - _groupsBefore isEqualTo []}] call _check;
call compile preprocessFileLineNumbers "majorLifecycleChecks.sqf";
{deleteMarker _x} forEach _markers;
{deleteVehicle _x} forEach [sidesX,spawner,garrison,server];
sleep 0.2;
["major_all_clean",(entities [[],[],true,false]) - _before isEqualTo []
    && {allGroups - _groupsBefore isEqualTo []}
    && {isNil "A3I_majorWatchdogHandle"} && {count A3I_majorAttacks == 0}
    && {A3A_tasksData isEqualTo []} && {!bigAttackInProgress} && {!HQAttackInProgress}
    && {forcedSpawn isEqualTo []},[A3A_tasksData,forcedSpawn,keys A3I_majorAttacks,
    ((entities [[],[],true,false]) - _before) apply {[typeOf _x,alive _x,_x getVariable ["A3I_context",""]]},
    (allGroups - _groupsBefore) apply {[side _x,count units _x,_x getVariable ["A3I_context",""]]},
    isNil "A3I_majorWatchdogHandle",bigAttackInProgress,HQAttackInProgress,
    (["stats"] call A3I_fnc_budget) # 1]] call _check;
