// Real building geometry and native human creation; no public mission yet.
private _before = entities [[],[],true,false]; private _groupsBefore = +allGroups;
sidesX = [true] call A3A_fnc_createNamespace;
respawnTeamPlayer = "a3i_esc_hq";
private _town = "a3i_esc_town"; private _site = "a3i_esc_site";
createMarker [respawnTeamPlayer,[3000,3000,0]];
createMarker [_town,[4500,4500,0]]; createMarker [_site,[6000,4500,0]];
private _markers = [respawnTeamPlayer,_town,_site];
{_x setMarkerShape "ELLIPSE"; _x setMarkerSize [100,100]; sidesX setVariable [_x,west]} forEach _markers;
markersX = +_markers; citiesX = [_town]; outposts = [_site]; airportsX = []; milbases = [];
factories = []; resourcesX = []; seaports = []; controlsX = []; milAdministrationsX = [];
private _hqGroup = createGroup teamPlayer;
petros = _hqGroup createUnit ["I_G_Soldier_F",getMarkerPos respawnTeamPlayer,[],0,"NONE"];
petros enableSimulationGlobal false; distanceMission = 5000;
A3A_faction_reb = createHashMapFromArray [["unitUnarmed","C_man_1"],["uniforms",["U_C_Poloshirt_blue"]]];
A3A_buildingBlacklist = []; A3I_test_observers = [];
private _building = createVehicle ["Land_i_Barracks_V1_F",getMarkerPos _town,[],0,"CAN_COLLIDE"];
private _nativeRole = A3A_faction_reb get "unitUnarmed";
sleep 0.5;
["esc_sources_infected_only",(call A3I_fnc_extractionLocations) isEqualTo [_town,_site]] call _check;
private _valid = true; outposts = [];
{
    missionNamespace setVariable [_x,[_site]];
    _valid = _valid && {_site in (call A3I_fnc_extractionLocations)};
    missionNamespace setVariable [_x,[]];
} forEach ["milbases","outposts","airportsX"];
citiesX = [_town]; outposts = [_site];
["esc_all_approved_source_types",_valid] call _check;
citiesX = []; outposts = []; factories = [_town]; resourcesX = [_site]; seaports = [_site];
["esc_other_permanent_sources_excluded",(call A3I_fnc_extractionLocations) isEqualTo []] call _check;
citiesX = [_town]; outposts = [_site]; factories = []; resourcesX = []; seaports = [];
sidesX setVariable [_site,east];
["esc_russian_source_excluded",(call A3I_fnc_extractionLocations) isEqualTo [_town]] call _check;
sidesX setVariable [_site,teamPlayer];
["esc_rebel_source_excluded",(call A3I_fnc_extractionLocations) isEqualTo [_town]] call _check;
sidesX setVariable [_site,west];
controlsX = [_site];
["esc_control_overlap_excluded",!(_site in (call A3I_fnc_extractionLocations))] call _check;
controlsX = [];
distanceMission = 2500;
["esc_native_distance_filter",(call A3I_fnc_extractionTargets) isEqualTo [_town]] call _check;
distanceMission = 5000;
private _scene = [_town,6] call A3I_fnc_findExtractionShelter;
["esc_shelter_real_positions",_scene # 0 == _building && {count (_scene # 1) == 6}
    && {((_scene # 1) findIf {!(_x inArea _town)}) == -1}] call _check;
private _points = _scene # 1; private _separated = true;
{private _p = _x; if ((_points findIf {_x isNotEqualTo _p && {_x distance _p < 1.5}}) != -1) then {_separated = false}} forEach _points;
["esc_shelter_distinct_positions",_separated] call _check;
["esc_empty_site_no_center_fallback",([_site,2] call A3I_fnc_findExtractionShelter) isEqualTo [objNull,[]]] call _check;
["esc_bad_count_refused",([_town,1] call A3I_fnc_findExtractionShelter) isEqualTo [objNull,[]]
    && {([_town,7] call A3I_fnc_findExtractionShelter) isEqualTo [objNull,[]]}
    && {([_town,2.5] call A3I_fnc_findExtractionShelter) isEqualTo [objNull,[]]}] call _check;
A3A_buildingBlacklist = [typeOf _building];
["esc_blacklisted_building_refused",([_town,2] call A3I_fnc_findExtractionShelter) isEqualTo [objNull,[]]] call _check;
A3A_buildingBlacklist = [];
private _oldHQ = getMarkerPos respawnTeamPlayer;
respawnTeamPlayer setMarkerPos getMarkerPos _town;
["esc_hq_proximity_refused",([_town,2] call A3I_fnc_findExtractionShelter) isEqualTo [objNull,[]]] call _check;
respawnTeamPlayer setMarkerPos _oldHQ;
petros setPosATL getMarkerPos _town; A3I_test_observers = [petros];
["esc_near_observer_refused",([_town,2] call A3I_fnc_findExtractionShelter) isEqualTo [objNull,[]]] call _check;
A3I_test_observers = []; petros setPosATL _oldHQ;
private _rolledUnits=[]; private _rolledGroup=grpNull;
private _rolled=[_town,2,{params ["_units","_group"];_rolledUnits=+_units;_rolledGroup=_group;false}] call A3I_fnc_createExtractionSurvivors;
sleep 0.3;
["esc_callback_rejection_rolls_back",_rolled # 2 == "registration_failed"
    && {(_rolledUnits findIf {!isNull _x}) == -1} && {isNull _rolledGroup}] call _check;
private _registeredUnits=[]; private _registeredGroup=grpNull;
private _accepted=[_town,2,{params ["_units","_group"];_registeredUnits=+_units;_registeredGroup=_group;true}] call A3I_fnc_createExtractionSurvivors;
["esc_callback_owns_actual_scene",_accepted # 0 isEqualTo _registeredUnits
    && {_accepted # 1 == _registeredGroup} && {count _registeredUnits == 2}] call _check;
{deleteVehicle _x} forEach _registeredUnits;deleteGroup _registeredGroup;sleep 0.3;
private _made = [_town,2] call A3I_fnc_createExtractionSurvivors;
private _actors = _made # 0; private _group = _made # 1;
["esc_two_real_survivors",count _actors == 2 && {!isNull _group} && {_made # 2 == ""}
    && {(_actors findIf {!alive _x || {side group _x != teamPlayer} || {!local _x}}) == -1}] call _check;
["esc_native_waiting_survivors",(_actors findIf {!captive _x || {_x checkAIFeature "MOVE"}
    || {weapons _x isNotEqualTo []} || {!isDamageAllowed _x}}) == -1] call _check;
["esc_no_implicit_task_or_ledger",(_actors findIf {!isNil {_x getVariable "A3I_extractionOwner"}}) == -1] call _check;
{deleteVehicle _x} forEach _actors; deleteGroup _group; sleep 0.2;
_made = [_town,6] call A3I_fnc_createExtractionSurvivors;
_actors = _made # 0; _group = _made # 1;
["esc_six_real_survivors",count _actors == 6 && {_made # 2 == ""}] call _check;
private _ledger = ["scene_fixture",_actors,time+30] call A3I_fnc_createExtractionLedger;
["esc_actors_register_with_ledger",count _ledger > 0 && {_ledger get "unresolved" == 6}] call _check;
if (count _ledger > 0) then {[_ledger get "name",_ledger get "serial"] call A3I_fnc_releaseExtractionLedger};
{deleteVehicle _x} forEach _actors; deleteGroup _group; sleep 0.2;
_made = [_town] call A3I_fnc_createExtractionSurvivors;
_actors = _made # 0; _group = _made # 1;
["esc_default_group_in_range",count _actors >= 2 && {count _actors <= 6}] call _check;
{deleteVehicle _x} forEach _actors; deleteGroup _group; sleep 0.2;
A3A_faction_reb set ["unitUnarmed","B_MRAP_01_F"];
["esc_nonhuman_role_refused",([_town,2] call A3I_fnc_createExtractionSurvivors) isEqualTo [[],grpNull,"unarmed_role_unavailable"]] call _check;
A3A_faction_reb set ["unitUnarmed",_nativeRole];
sidesX setVariable [_town,east];
["esc_changed_owner_refuses_creation",([_town,2] call A3I_fnc_createExtractionSurvivors) isEqualTo [[],grpNull,"no_safe_shelter"]] call _check;
sidesX setVariable [_town,west];
private _count = count allUnits;
[_town,2] remoteExecCall ["A3I_fnc_createExtractionSurvivors",2]; sleep 0.3;
["esc_remote_factory_refused",count allUnits == _count] call _check;
{deleteVehicle _x} forEach [_building,petros,sidesX];
{deleteMarker _x} forEach _markers;
sleep 0.3; deleteGroup _hqGroup; sleep 0.5;
["esc_cleanup",(entities [[],[],true,false]) - _before isEqualTo []
    && {allGroups - _groupsBefore isEqualTo []}] call _check;
