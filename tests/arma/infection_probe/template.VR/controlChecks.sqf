// Real server controller, basic units, budget, ownership, calendar and cleanup.
// VR has no roads: road roster branches are exercised with explicit classification;
// actual world classification/controller routing uses off-road markers here.
#include "\x\a3a\addons\core\script_component.hpp"
private _before = entities [[],[],true,false];
private _groupsBefore = +allGroups;
private _savedCap = A3I_activeLimit;
private _savedContext = A3I_contextLimit;
private _savedDate = +date;
private _savedTierMode = plusGarrison;
plusGarrison = true;
private _setLimits = {
    params ["_global","_context"];
    ["A3I_activeLimit",_global,2,"server",false] call CBA_settings_fnc_set;
    ["A3I_contextLimit",_context,2,"server",false] call CBA_settings_fnc_set;
};
private _wait = {
    params ["_predicate",["_timeout",10]];
    private _deadline = diag_tickTime + _timeout;
    waitUntil {sleep 0.05;call _predicate || {diag_tickTime > _deadline}};
    call _predicate
};
private _stats = {(["stats"] call A3I_fnc_budget) # 1};
sidesX = [true] call A3A_fnc_createNamespace;
spawner = [true] call A3A_fnc_createNamespace;
garrison = [true] call A3A_fnc_createNamespace;
garrisonIsChanging = false;
respawnTeamPlayer = "a3i_controls_hq";
createMarker [respawnTeamPlayer,[500,500,0]];
controlsX = ["a3i_control_static","a3i_control_generated"];
defaultControlIndex = 0;
markersX = controlsX + ["a3i_control_base"];
watchpostsFIA = []; roadblocksFIA = []; aapostsFIA = []; atpostsFIA = []; hmgpostsFIA = [];
hcArray = [999];
aggressionOccupants = 0;
A3A_roadBlocksBaseChance = 0;
tierWar = 1;
private _savedGroups = str A3A_faction_occ;
A3I_test_originals = [];
A3I_test_siteEvents = [];
private _event = [CBA_EVENT_SERVER_SPAWN_LOCATION,{A3I_test_siteEvents pushBack +_this}] call CBA_fnc_addEventHandler;
private _prepare = {
    params ["_marker"];
    if !(_marker in allMapMarkers) then {
        createMarker [_marker,if (_marker == "a3i_control_base") then {[6000,4500,0]} else {[4500,4500,0]}];
    };
    _marker setMarkerShape "ELLIPSE";
    _marker setMarkerSize [50,50];
    sidesX setVariable [_marker,west];
    spawner setVariable [_marker,0];
    garrison setVariable [_marker,["unrelated_saved_entry"]];
};
{[_x] call _prepare} forEach markersX;
private _stop = {
    params ["_marker"];
    spawner setVariable [_marker,2];
    [{!(_marker in A3I_sites)},5] call _wait
};
private _marker = controlsX # 0;
["control_override_registered",getText (configFile >> "CfgFunctions" >> "A3A" >> "CREATE" >> "createAIcontrols" >> "file")
    == "\x\a3i\addons\core\overrides\fn_createAIcontrols.sqf"
    && {getText (configFile >> "CfgFunctions" >> "A3I" >> "Originals" >> "originalCreateAIcontrols" >> "file")
        == "\x\a3i\tests\contracts\fn_originalCreateAIcontrols.sqf"}] call _check;
sidesX setVariable [_marker,east]; [_marker,"retained_argument"] call A3A_fnc_createAIcontrols;
sidesX setVariable [_marker,west];
A3A_faction_occ set ["infectionTemplate",""]; [_marker,"retained_argument"] call A3A_fnc_createAIcontrols;
A3A_faction_occ set ["infectionTemplate","A3I_Infected"];
A3I_dependencies set ["available",false]; [_marker,"retained_argument"] call A3A_fnc_createAIcontrols;
["control_inactive_roster",([true,true] call A3I_fnc_controlRoster) isEqualTo [[],"inactive"]] call _check;
A3I_dependencies set ["available",true];
["control_other_factions_delegate",count A3I_test_originals == 3
    && {(A3I_test_originals findIf {_x # 1 isNotEqualTo [_marker,"retained_argument"]}) == -1}] call _check;
["control_road_skip",([true,false] call A3I_fnc_controlRoster) isEqualTo [[],"road_skipped"]] call _check;
A3A_roadBlocksBaseChance = 100;
private _front = [true,true] call A3I_fnc_controlRoster;
private _crew = [A3A_faction_occ get "unitTierStaticCrew"] call SCRT_fnc_unit_getTiered;
["control_road_frontline",_front # 1 == "road_frontline"
    && {(_front # 0) select [(count (_front # 0)) - 2] isEqualTo [_crew,_crew]}
    && {((_front # 0) select [0,(count (_front # 0)) - 2]) in (A3A_faction_occ get "groupsMilitiaMedium")},_front] call _check;
aggressionOccupants = 120;
tierWar = 8;
private _military = [true,false] call A3I_fnc_controlRoster;
["control_road_military",_military # 1 == "road_military"
    && {count (_military # 0) == 7}
    && {((_military # 0) findIf {isNil {A3A_customUnitTypes getVariable _x}}) == -1},_military] call _check;
aggressionOccupants = 0;
tierWar = 1;
private _samples = [];
for "_i" from 1 to 64 do {_samples pushBack ([true,false] call A3I_fnc_controlRoster)};
private _policeRoles = +(A3A_faction_occ get "groupPoliceOfficers");
_policeRoles pushBack (A3A_faction_occ get "unitPoliceOfficer");
private _bad = _samples select {
    if (_x # 1 == "road_police") then {_x # 0 isNotEqualTo _policeRoles} else {
        _x # 1 != "road_military" || {count (_x # 0) != 7}
    }
};
["control_road_weighted_roles",_bad isEqualTo [],[count (_samples select {_x # 1 == "road_police"}),count _bad]] call _check;
tierWar = 0;
["control_field_skip",([false,false] call A3I_fnc_controlRoster) isEqualTo [[],"field_skipped"]] call _check;
tierWar = 1;
private _special = [false,true] call A3I_fnc_controlRoster;
["control_field_frontline",_special # 1 == "field_frontline"
    && {_special # 0 in (A3A_faction_occ get "groupSpecOpsRandom")},_special] call _check;
aggressionOccupants = 500; // Deterministically selects the non-frontline branch in this fixture.
private _pair = [false,false] call A3I_fnc_controlRoster;
["control_field_patrol",_pair # 1 == "field_patrol" && {count (_pair # 0) == 2},_pair] call _check;
["control_template_unchanged",str A3A_faction_occ == _savedGroups] call _check;

// A conflicting main marker blocks the controller before creating any actors.
"a3i_control_base" setMarkerPos getMarkerPos _marker;
sidesX setVariable ["a3i_control_base",east];
private _started = [_marker,"Control"] call A3I_fnc_startSite;
["control_overlap_rejected",!_started && {!(_marker in A3I_sites)}] call _check;
"a3i_control_base" setMarkerPos [6000,4500,0];
sidesX setVariable ["a3i_control_base",west];
[1,1] call _setLimits;
private _full = ["reserve",["control-test-pressure",1,1]] call A3I_fnc_budget;
[[_marker],"A3A_fnc_createAIcontrols"] call A3A_fnc_scheduler;
[{_marker in A3I_sites}] call _wait;
sleep 1.5;
private _record = A3I_sites get _marker;
["control_capacity_retains_queue",count (_record get "queue") == 2 && {(_record get "units") isEqualTo []}
    && {!(_record get "spawnedAny")} && {[_marker,_record] call A3I_fnc_tryCaptureControl == sideUnknown}
    && {sidesX getVariable _marker == west},[call _stats,_record get "queue"]] call _check;
["control_duplicate_rejected",!([_marker,"Control"] call A3I_fnc_startSite)] call _check;
["close",[_full # 1 # 0]] call A3I_fnc_budget;
[{count (_record get "units") == 1}] call _wait;
private _first = (_record get "units") # 0;
["control_budgeted_legacy_spawn",alive _first && {owner _first == 2} && {side group _first == west}
    && {_first getVariable ["markerX",""] == ""} && {_first getVariable ["A3A_resPool",""] == "legacy"}
    && {count (_record get "queue") == 1} && {count A3I_test_originals == 3}
    && {isNull (_record get "flag")} && {_record get "crates" isEqualTo []},[typeOf _first,call _stats]] call _check;
spawner setVariable [_marker,1];
private _disabled = [{!simulationEnabled _first},3] call _wait;
spawner setVariable [_marker,0];
private _enabled = [{simulationEnabled _first},3] call _wait;
["control_simulation_transition",_disabled && {_enabled}] call _check;
A3A_resourcesAttackOcc = 1000; A3A_resourcesDefenceOcc = 1000;
A3I_test_zones = [];
_first setDamage 1;
sleep 0.5;
["control_death_legacy_accounting",[A3A_resourcesAttackOcc,A3A_resourcesDefenceOcc] isEqualTo [995,995]
    && {garrison getVariable _marker isEqualTo ["unrelated_saved_entry"]}
    && {A3I_test_zones isEqualTo []}] call _check;
["control_unspawned_blocks_capture",[_marker,_record] call A3I_fnc_tryCaptureControl == sideUnknown
    && {sidesX getVariable _marker == west}] call _check;
private _arrived = [{count (_record get "queue") == 0 && {({alive _x} count (_record get "units")) == 1}},20] call _wait;
private _second = ((_record get "units") select {alive _x}) # 0;
["control_full_queue_arrives",_arrived && {(call _stats) select [1,2] isEqualTo [1,0]},[call _stats]] call _check;
// Force the boundary positions after the real unit creation/initialization.
private _rebelGroup = createGroup [teamPlayer,false];
private _rebel = _rebelGroup createUnit ["I_Soldier_F",getMarkerPos _marker,[],0,"NONE"];
_rebel allowDamage false; _rebel disableAI "ALL";
_second disableAI "MOVE";
_second setPosATL [4700,4500,0];
_second setVariable ["A3I_controlArrived",false];
["control_approach_blocks_capture",[_marker,_record] call A3I_fnc_tryCaptureControl == sideUnknown] call _check;
_second setPosATL getMarkerPos _marker;
_second setVariable ["A3I_controlArrived",true];
["control_present_defender_blocks_capture",[_marker,_record] call A3I_fnc_tryCaptureControl == sideUnknown] call _check;
_rebel setCaptive true;
_second setDamage 1;
sleep 1.5;
["control_captive_cannot_capture",[_marker,_record] call A3I_fnc_tryCaptureControl == sideUnknown
    && {sidesX getVariable _marker == west}] call _check;
_rebel setPosATL [5000,4500,0]; _rebel setCaptive false;
["control_distant_unit_cannot_capture",[_marker,_record] call A3I_fnc_tryCaptureControl == sideUnknown] call _check;
_rebel setPosATL getMarkerPos _marker;
private _winner = [_marker,_record] call A3I_fnc_tryCaptureControl;
["control_rebel_capture_once",_winner == teamPlayer && {sidesX getVariable _marker == teamPlayer}
    && {[_marker,_record] call A3I_fnc_tryCaptureControl == sideUnknown}
    && {_record get "captured" == teamPlayer}] call _check;
[_marker] call _stop;
["control_static_cleanup",_record get "cleaned" && {garrison getVariable _marker isEqualTo ["unrelated_saved_entry"]}
    && {isNil "A3I_controlResets" || {count A3I_controlResets == 0}}
    && {(call _stats) select [1,3] isEqualTo [0,0,0]}] call _check;
deleteVehicle _first; deleteVehicle _second;
_rebel setPosATL [7000,7000,0]; _rebel setCaptive true;

// Reentry recreates the native transient patrol; an external ownership change
// cancels only the waiting actors, leaving visible living actors until despawn.
[_marker] call _prepare;
[_marker,"Control"] call A3I_fnc_startSite;
[{count ((A3I_sites get _marker) get "units") == 1}] call _wait;
_record = A3I_sites get _marker;
["control_visit_regenerates",count (_record get "queue") == 1 && {garrison getVariable _marker isEqualTo ["unrelated_saved_entry"]}] call _check;
sidesX setVariable [_marker,east];
sleep 1.5;
["control_ownership_cancels_queue",_record get "queue" isEqualTo []
    && {({alive _x} count (_record get "units")) == 1} && {_record get "captured" == sideUnknown}] call _check;
[_marker] call _stop;
[_marker] call _prepare;
[_marker,"Control"] call A3I_fnc_startSite;
[{count ((A3I_sites get _marker) get "units") == 1}] call _wait;
_record = A3I_sites get _marker;
terminate (_record get "script");
private _recovered = [{!(_marker in A3I_sites)},4] call _wait;
["control_interrupted_cleanup",_recovered && {(call _stats) select [1,3] isEqualTo [0,0,0]}] call _check;

// Generated-control capture and the real watchdog's campaign-clock reset.
private _marker = controlsX # 1;
[2,2] call _setLimits;
[_marker,"Control"] call A3I_fnc_startSite;
[{count ((A3I_sites get _marker) get "units") == 2}] call _wait;
_record = A3I_sites get _marker;
private _dead = +(_record get "units");
{_x setDamage 1} forEach _dead;
sleep 0.5;
private _invaderGroup = createGroup [east,false];
private _invader = _invaderGroup createUnit ["O_Soldier_F",getMarkerPos _marker,[],0,"NONE"];
_invader allowDamage false; _invader disableAI "ALL";
A3I_test_support = [];
_winner = [_marker,_record] call A3I_fnc_tryCaptureControl;
sleep 0.3;
["control_invader_capture",_winner == east && {sidesX getVariable _marker == east}
    && {(A3I_test_support apply {_x select [0,2]}) isEqualTo [[-5,0]]}] call _check;
setDate [2026,12,31,23,0];
[_marker] call _stop;
["control_generated_reset_scheduled",_marker in A3I_controlResets && {!isNil "A3I_siteWatchdogHandle"}
    && {count A3I_sites == 0}] call _check;
setDate [2027,1,1,0,59];
call A3I_fnc_controlResetTick;
["control_reset_waits_120_minutes",sidesX getVariable _marker == east && {_marker in A3I_controlResets}] call _check;
spawner setVariable [_marker,1];
setDate [2027,1,1,1,0];
call A3I_fnc_controlResetTick;
["control_reset_waits_for_despawn",sidesX getVariable _marker == east && {_marker in A3I_controlResets}] call _check;
spawner setVariable [_marker,2];
call A3I_fnc_controlResetTick;
["control_reset_nearest_owner",sidesX getVariable _marker == west && {!(_marker in A3I_controlResets)}] call _check;
{deleteVehicle _x} forEach _dead;
A3I_controlResets set [_marker,[[2026,12,31,23,0],east]];
sidesX setVariable [_marker,teamPlayer];
call A3I_fnc_controlResetTick;
["control_reset_ownership_race",sidesX getVariable _marker == teamPlayer && {!(_marker in A3I_controlResets)}] call _check;
A3I_controlResets set [_marker,[[2026,12,31,23,0],teamPlayer]];
sidesX setVariable ["a3i_control_base",teamPlayer];
call A3I_fnc_controlResetTick;
["control_reset_rebel_base_preserved",sidesX getVariable _marker == teamPlayer && {!(_marker in A3I_controlResets)}] call _check;
private _dates = [
    [[2026,12,31,23,0],[2027,1,1,1,0],120],
    [[2028,2,28,23,0],[2028,3,1,1,0],1560],
    [[2100,2,28,23,0],[2100,3,1,1,0],120],
    [[2000,2,28,23,0],[2000,3,1,1,0],1560],
    [[2027,1,1,1,0],[2026,12,31,23,0],-120]
];
private _dateResults = _dates apply {[_x # 0,_x # 1] call A3I_fnc_elapsedDateMinutes};
["control_calendar_boundaries",_dateResults isEqualTo (_dates apply {_x # 2}),_dateResults] call _check;
deleteVehicle _rebel; deleteVehicle _invader;
deleteGroup _rebelGroup; deleteGroup _invaderGroup;
sleep 3;
{deleteGroup _x} forEach (allGroups - _groupsBefore);
[CBA_EVENT_SERVER_SPAWN_LOCATION,_event] call CBA_fnc_removeEventHandler;
{deleteMarker _x} forEach (markersX + [respawnTeamPlayer]);
deleteVehicle garrison; deleteVehicle spawner; deleteVehicle sidesX;
garrison = nil; spawner = nil; sidesX = nil; respawnTeamPlayer = nil;
[_savedCap,_savedContext] call _setLimits;
setDate _savedDate;
plusGarrison = _savedTierMode;
GVAR(despawnQueue) = [];
private _remaining = (entities [[],[],true,false]) - _before;
["control_all_clean",_remaining isEqualTo [] && {(allGroups - _groupsBefore) isEqualTo []}
    && {count A3I_sites == 0} && {count A3I_controlResets == 0}
    && {isNil "A3I_siteWatchdogHandle"} && {(call _stats) select [1,3] isEqualTo [0,0,0]},
    [_remaining apply {typeOf _x},call _stats,A3I_test_siteEvents]] call _check;
