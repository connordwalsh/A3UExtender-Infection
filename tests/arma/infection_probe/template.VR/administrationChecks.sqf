// Real buildings, infected events, capture registry and delayed HR transaction.
// UI, original-route controls and escaped-group garbage collection are recorded.
#include "\x\a3a\addons\core\script_component.hpp"
private _before = entities [[],[],true,false];
private _groupsBefore = +allGroups;
private _savedCap = A3I_activeLimit;
private _savedContext = A3I_contextLimit;
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
server = [true] call A3A_fnc_createNamespace;
server setVariable ["hr",0]; server setVariable ["resourcesFIA",0];
resourcesIsChanging = false; garrisonIsChanging = false; limitHR = 0;
A3A_GCThreshold = 600; GVAR(despawnQueue) = []; GVAR(despawnerRunning) = nil;
A3A_resourcesAttackOcc = 1000; A3A_resourcesDefenceOcc = 1000;
A3A_recentDamageOcc = []; A3A_hasACE = false; tkPunish = false;
A3A_rebelSkillMul = 1; skillFIA = 1;
distanceSPWN = 1000; plusGarrison = true; tierWar = 0; aggressionOccupants = -100;
A3A_faction_reb = createHashMapFromArray [["unitUnarmed","C_man_1"],["unitSL","I_officer_F"],
    ["unitSniper","I_sniper_F"],["uniforms",["U_C_Poloshirt_blue"]],["name","Fixture Rebels"]];
A3A_faction_civ = createHashMapFromArray [["currencySymbol","$"]];
respawnTeamPlayer = "a3i_admin_hq";
createMarker [respawnTeamPlayer,[500,500,0]];
private _marker = "a3i_administration";
createMarker [_marker,[4500,4500,0]];
_marker setMarkerShape "ICON"; _marker setMarkerType "A3AU_miladmin_mrk";
milAdministrationsX = [_marker];
markersX = []; citiesX = []; controlsX = []; outposts = []; airportsX = [];
seaports = []; milbases = []; factories = []; resourcesX = [];
townSkirmishes = []; destroyedSites = []; A3A_destroyedMilAdministrations = [];
hcArray = [999];
private _building = createVehicle ["Land_i_Barracks_V1_F",[4500,4500,0],[],0,"CAN_COLLIDE"];
_building setVariable ["A3A_milAdminMarker",_marker];
A3A_milAdministrations = [_building];
sidesX setVariable [_marker,west]; spawner setVariable [_marker,0];
garrison setVariable [_marker,["unrelated_saved_entry"]];
A3I_test_originals = []; A3I_test_realAdminCapture = false;
A3I_test_markerUpdates = []; A3I_test_comms = []; A3I_test_groupCleanup = [];
A3I_test_support = []; A3I_test_aggression = []; A3I_test_zones = [];
A3I_test_lootCalls = []; A3I_test_logisticsCalls = []; A3I_test_vehicleCleanup = [];
A3I_test_siteEvents = [];
private _event = [CBA_EVENT_SERVER_SPAWN_LOCATION,{A3I_test_siteEvents pushBack +_this}] call CBA_fnc_addEventHandler;
private _stop = {
    spawner setVariable [_marker,2];
    [{!(_marker in A3I_sites)},6] call _wait
};
probeObserver allowDamage false; probeObserver setCaptive true;
west setFriend [independent,0]; independent setFriend [west,0];
west setFriend [east,0]; east setFriend [west,0];

["admin_override_registered",getText (configFile >> "CfgFunctions" >> "A3A" >> "CREATE" >> "createAIMilAdmin" >> "file")
    == "\x\a3i\addons\core\overrides\fn_createAIMilAdmin.sqf"
    && {getText (configFile >> "CfgFunctions" >> "SCRT" >> "Location" >> "location_removeMilAdmin" >> "file")
        == "\x\a3i\addons\core\overrides\fn_location_removeMilAdmin.sqf"}] call _check;
sidesX setVariable [_marker,east]; [_marker,"unchanged"] call A3A_fnc_createAIMilAdmin;
[_building,"CAPTURE"] call SCRT_fnc_location_removeMilAdmin;
sidesX setVariable [_marker,west];
A3A_faction_occ set ["infectionTemplate",""]; [_marker,"unchanged"] call A3A_fnc_createAIMilAdmin;
[_building,"CAPTURE"] call SCRT_fnc_location_removeMilAdmin;
A3A_faction_occ set ["infectionTemplate","A3I_Infected"];
A3I_dependencies set ["available",false]; [_marker,"unchanged"] call A3A_fnc_createAIMilAdmin;
[_building,"CAPTURE"] call SCRT_fnc_location_removeMilAdmin;
A3I_dependencies set ["available",true];
["admin_other_routes_delegate",count A3I_test_originals == 6] call _check;
[_building,"LOADSTAT"] call SCRT_fnc_location_removeMilAdmin;
["admin_load_delegate",count A3I_test_originals == 7 && {(A3I_test_originals # 6) # 1 # 1 == "LOADSTAT"}] call _check;
private _nativeCalls = count A3I_test_originals;
[_building,"CAPTURE"] call SCRT_fnc_location_removeMilAdmin;
[_building,"SILENT"] call SCRT_fnc_location_removeMilAdmin;
["admin_unspawned_not_captured",count A3I_test_originals == _nativeCalls && {sidesX getVariable _marker == west}] call _check;
private _police = [_marker] call A3I_fnc_administrationRoster;
["admin_native_police_count",count (_police # 0) >= 7 && {count (_police # 0) <= 11}
    && {_police # 1 == "police"} && {_police # 2 == _building},[_police # 1,count (_police # 0)]] call _check;
tierWar = 10; aggressionOccupants = 100;
private _militia = [_marker] call A3I_fnc_administrationRoster;
["admin_native_militia_count",count (_militia # 0) >= 8 && {count (_militia # 0) <= 12}
    && {_militia # 1 == "militia"},[_militia # 1,count (_militia # 0)]] call _check;
tierWar = 0; aggressionOccupants = -100;
townSkirmishes = [_marker];
["admin_skirmish_skips",!([_marker,"MilAdmin"] call A3I_fnc_startSite)] call _check;
townSkirmishes = [];
A3A_milAdministrations = [];
["admin_missing_building_rejected",!([_marker,"MilAdmin"] call A3I_fnc_startSite)] call _check;
A3A_milAdministrations = [_building];
private _positions = [_building] call A3I_fnc_administrationPositions;
private _safePositions = (_positions # 0) apply {[_x,[],getMarkerPos respawnTeamPlayer] call A3I_fnc_indoorPosition};
["admin_positions_validated",_positions # 2 == "mapped" && {count (_positions # 0) == 4}
    && {({_x # 0} count _safePositions) >= 2},[_positions,_safePositions]] call _check;
private _floorless = [[4500,4500,100],[],[500,500,0]] call A3I_fnc_indoorPosition;
private _nearHQ = [[500,500,0],[],[500,500,0]] call A3I_fnc_indoorPosition;
["admin_unsafe_indoor_rejected",!(_floorless # 0) && {_floorless # 2 == "floor"}
    && {!(_nearHQ # 0)} && {_nearHQ # 2 == "hq"}] call _check;
private _emptyBuilding = createVehicle ["Land_CargoBox_V1_F",[6000,6000,0],[],0,"CAN_COLLIDE"];
["admin_empty_layout_no_fallback",([_emptyBuilding] call A3I_fnc_administrationPositions) select [0,2] isEqualTo [[],[]]] call _check;
deleteVehicle _emptyBuilding;

[2,2] call _setLimits;
private _pressure = ["reserve",["admin-fixture-pressure",2,2]] call A3I_fnc_budget;
A3I_test_realAdminCapture = true;
[[_marker],"A3A_fnc_createAIMilAdmin"] call A3A_fnc_scheduler;
[{!isNil "A3I_sites" && {_marker in A3I_sites} && {(A3I_sites get _marker) get "announced"}}] call _wait;
private _record = A3I_sites get _marker;
private _total = _record get "remainingDefenders";
private _captives = +(_record get "civilians");
["admin_full_queue_retained",_total >= 7 && {count (_record get "queue") == _total}
    && {_record get "units" isEqualTo []} && {!([_marker,"MilAdmin"] call A3I_fnc_startSite)}] call _check;
["admin_captives_and_loot",count _captives >= 2 && {count _captives <= 4}
    && {(_captives findIf {!captive _x || {side group _x != teamPlayer} || {owner _x != 2}
        || {weapons _x isNotEqualTo []} || {_x getVariable ["A3I_survivorState",""] != "waiting"}}) == -1}
    && {count (_record get "crates") == 1} && {count A3I_test_lootCalls == 1}
    && {count A3I_test_logisticsCalls == 1},[count _captives,count (_record get "crates")]] call _check;
if (count _captives < 2) exitWith {
    call _stop;
    ["close",[_pressure # 1 # 0]] call A3I_fnc_budget;
    diag_log "[INFECTION_ADMIN_FIXTURE] Required captive positions unavailable; remaining checks not run.";
};
private _rescuerGroup = createGroup [teamPlayer,false];
private _rescuer = _rescuerGroup createUnit ["I_Soldier_F",[7000,7000,0],[],0,"NONE"];
removeAllWeapons _rescuer; _rescuer disableAI "ALL";
petros = _rescuer; theBoss = 2;
private _survivor = _captives # 0;
_rescuer setPosATL ((getPosATL _survivor) vectorAdd [0.5,0,0]);
["admin_public_rescue_rejects_bot",!([_survivor,_rescuer] call A3I_fnc_requestRescue)] call _check;
private _started = [_survivor,_rescuer] call A3I_fnc_beginRescue;
private _duplicate = [_survivor,_rescuer] call A3I_fnc_beginRescue;
["admin_rescue_claim_once",_started && {!_duplicate} && {_survivor getVariable "A3I_survivorState" == "releasing"}] call _check;
_survivor allowDamage false; // Isolate reward timing from enemy combat in this fixture.
private _escaped = [{_survivor getVariable ["A3I_survivorState",""] == "escaping"},8] call _wait;
["admin_early_rescue_independent",_escaped && {!captive _survivor}
    && {!(_survivor in (_record get "civilians"))} && {_record get "remainingDefenders" == _total}
    && {sidesX getVariable _marker == west} && {!([_marker] call A3I_fnc_tryCaptureAdministration)}] call _check;
_rescuer setPosATL [7000,7000,0];
["close",[_pressure # 1 # 0]] call A3I_fnc_budget;
[{count (_record get "units") == 2}] call _wait;
private _units = +(_record get "units");
["admin_budgeted_basics",count _units == 2 && {count (_record get "queue") == _total - 2}
    && {(_units findIf {owner _x != 2 || {side group _x != west} || {vehicle _x != _x}
        || {_x getVariable ["markerX",""] != ""} || {!(_x getVariable ["A3I_adminTracked",false])}}) == -1},[call _stats]] call _check;
private _victim = _units # 0;
["Killed",_victim] call A3I_fnc_administrationDefenderEvent;
["admin_forged_death_rejected",_record get "remainingDefenders" == _total] call _check;
_victim setDamage 1;
[{_record get "remainingDefenders" == _total - 1},3] call _wait;
deleteVehicle _victim;
private _pendingBefore = count (_record get "queue");
deleteVehicle (_units # 1);
sleep 0.5;
["admin_delete_requeues_not_kills",_record get "remainingDefenders" == _total - 1
    && {count (_record get "queue") == _pendingBefore + 1}
    && {garrison getVariable _marker isEqualTo ["unrelated_saved_entry"]}
    && {!([_marker] call A3I_fnc_tryCaptureAdministration)},[_record get "remainingDefenders",count (_record get "queue")]] call _check;
_nativeCalls = count A3I_test_originals;
[_building,"CAPTURE"] call SCRT_fnc_location_removeMilAdmin;
[_building,"SILENT"] call SCRT_fnc_location_removeMilAdmin;
["admin_external_capture_guard",count A3I_test_originals == _nativeCalls && {sidesX getVariable _marker == west}] call _check;
[24,24] call _setLimits;
private _allArrived = [{_record get "queue" isEqualTo []},55] call _wait;
private _defenders = (_record get "units") select {alive _x};
["admin_complete_roster_arrives",_allArrived && {count _defenders == _total - 1},[count _defenders,_total,call _stats]] call _check;
{_x setDamage 1} forEach _defenders;
private _captured = [{sidesX getVariable _marker == teamPlayer},4] call _wait;
sleep 0.5;
["admin_clear_captures_with_captive",_captured && {_record get "remainingDefenders" == 0}
    && {_record get "captured" == teamPlayer} && {_building in A3A_destroyedMilAdministrations}
    && {alive (_captives # 1)} && {captive (_captives # 1)}
    && {({(_x select [0,2]) isEqualTo [-25,25]} count A3I_test_support) == 1}] call _check;
_nativeCalls = count A3I_test_originals;
["admin_capture_once",!([_marker] call A3I_fnc_tryCaptureAdministration)
    && {count A3I_test_originals == _nativeCalls}] call _check;
private _rewarded = [{server getVariable "hr" == 1},40] call _wait;
["admin_rescue_reward_separate",_rewarded && {_survivor getVariable "A3I_survivorState" == "rescued"}
    && {garrison getVariable [_marker + "_powCD",0] > time}
    && {A3I_test_groupCleanup isNotEqualTo []},[server getVariable "hr",_survivor getVariable "A3I_survivorState"]] call _check;
["admin_rescue_cannot_repeat",!([_survivor,_rescuer] call A3I_fnc_beginRescue)
    && {server getVariable "hr" == 1}] call _check;

private _second = _captives # 1;
_rescuer setPosATL ((getPosATL _second) vectorAdd [0.5,0,0]);
[_second,_rescuer] call A3I_fnc_beginRescue;
_rescuer setPosATL [7000,7000,0];
private _cancelled = [{_second getVariable "A3I_survivorState" == "waiting"},2] call _wait;
["admin_interrupted_rescue_no_reward",_cancelled && {captive _second} && {server getVariable "hr" == 1}] call _check;
_rescuer setPosATL ((getPosATL _second) vectorAdd [0.5,0,0]);
[_second,_rescuer] call A3I_fnc_beginRescue;
[{_second getVariable "A3I_survivorState" == "escaping"},8] call _wait;
_second setDamage 1;
sleep 1;
["admin_dead_rescue_no_reward",!alive _second && {server getVariable "hr" == 1}
    && {count A3I_rescues == 0} && {isNil "A3I_rescueHandle"}] call _check;
private _cleanup = call _stop;
sleep 0.5;
["admin_cleanup_keeps_escaped",_cleanup && {alive _survivor}
    && {(call _stats) select [1,3] isEqualTo [0,0,0]}
    && {(_captives select [2]) findIf {!isNull _x} == -1}] call _check;
{deleteVehicle _x} forEach (_defenders + [_survivor,_second,_rescuer]);
deleteGroup _rescuerGroup;
spawner setVariable [_marker,0]; sidesX setVariable [_marker,west];
["admin_completed_reentry_rejected",!([_marker,"MilAdmin"] call A3I_fnc_startSite)] call _check;
deleteVehicle _building;

// A real destroyed building retains its uncleared queue. Reentry also works on
// the ruin, while no new captives or loot appear in a collapsed structure.
_building = createVehicle ["Land_i_Barracks_V1_F",[4500,4500,0],[],0,"CAN_COLLIDE"];
_building setVariable ["A3A_milAdminMarker",_marker];
_building addEventHandler ["Killed", {
    [_this # 0,"DESTROY"] call SCRT_fnc_location_removeMilAdmin;
    destroyedSites pushBackUnique ((_this # 0) getVariable "A3A_milAdminMarker");
}];
A3A_milAdministrations = [_building]; A3A_destroyedMilAdministrations = [];
garrison setVariable [_marker + "_powCD",time + 3600];
[1,1] call _setLimits;
[_marker,"MilAdmin"] call A3I_fnc_startSite;
[{_marker in A3I_sites && {count ((A3I_sites get _marker) get "units") == 1}}] call _wait;
_record = A3I_sites get _marker;
private _living = (_record get "units") # 0;
_living setPosATL [4800,4500,0];
private _beforeDestruction = entities [[],[],true,false];
private _aggressionBefore = count A3I_test_aggression;
_building setDamage 1;
sleep 1;
private _ruins = ((entities [[],[],true,false]) - _beforeDestruction) select {_x isKindOf "Ruins_F"};
[_building,"DESTROY"] call SCRT_fnc_location_removeMilAdmin;
sleep 0.5;
["admin_destroy_requires_clearing",!alive _building && {alive _living}
    && {sidesX getVariable _marker == west} && {count (_record get "queue") > 0}
    && {_marker in destroyedSites} && {!([_marker] call A3I_fnc_tryCaptureAdministration)}] call _check;
["admin_destruction_aggression_once",count A3I_test_aggression == _aggressionBefore + 1
    && {(A3I_test_aggression # _aggressionBefore) isEqualTo [west,15,60]}] call _check;
sidesX setVariable [_marker,east]; sleep 1.5;
["admin_ownership_cancels_queue",_record get "queue" isEqualTo [] && {alive _living}
    && {!([_marker] call A3I_fnc_tryCaptureAdministration)}] call _check;
call _stop;
sidesX setVariable [_marker,west]; spawner setVariable [_marker,0];
private _restart = [_marker,"MilAdmin"] call A3I_fnc_startSite;
[{_marker in A3I_sites && {count ((A3I_sites get _marker) get "units") == 1}}] call _wait;
_record = A3I_sites get _marker;
["admin_ruin_reentry",_restart && {count (_record get "queue") > 0}
    && {_record get "civilians" isEqualTo []} && {_record get "crates" isEqualTo []}] call _check;
terminate (_record get "script");
private _recovered = [{!(_marker in A3I_sites)},4] call _wait;
["admin_interrupted_controller_cleanup",_recovered && {(call _stats) select [1,3] isEqualTo [0,0,0]}] call _check;
[24,24] call _setLimits;
[_marker,"MilAdmin"] call A3I_fnc_startSite;
_record = A3I_sites get _marker;
private _ruinArrivals = [{_record get "spawnedAny" && {_record get "queue" isEqualTo []}},45] call _wait;
private _ruinDefenders = +(_record get "units");
{if (alive _x) then {_x setDamage 1}} forEach _ruinDefenders;
private _ruinCaptured = [{sidesX getVariable _marker == teamPlayer},4] call _wait;
["admin_ruin_clear_captures",_ruinArrivals && {_ruinCaptured} && {!alive _building}
    && {_building in A3A_destroyedMilAdministrations} && {_record get "remainingDefenders" == 0}] call _check;
call _stop;
{deleteVehicle _x} forEach _ruinDefenders;
A3I_test_recoveryTicks = 0;
private _foreign = [{A3I_test_recoveryTicks = A3I_test_recoveryTicks + 1},0.1] call CBA_fnc_addPerFrameHandler;
[[],_foreign] remoteExecCall ["A3I_fnc_rescueTick",2];
sleep 0.6;
["admin_rescue_recovery_remote_denied",A3I_test_recoveryTicks >= 2] call _check;
[_foreign] call CBA_fnc_removePerFrameHandler;
deleteVehicle _building;
{deleteVehicle _x} forEach _ruins;
sleep 3;
{if (count units _x == 0) then {deleteGroup _x}} forEach (allGroups - _groupsBefore);
[CBA_EVENT_SERVER_SPAWN_LOCATION,_event] call CBA_fnc_removeEventHandler;
{deleteMarker _x} forEach [_marker,respawnTeamPlayer];
{deleteVehicle _x} forEach [garrison,spawner,sidesX,server];
garrison = nil; spawner = nil; sidesX = nil; server = nil; respawnTeamPlayer = nil;
[_savedCap,_savedContext] call _setLimits;
GVAR(despawnQueue) = [];
private _remaining = (entities [[],[],true,false]) - _before;
["admin_all_clean",_remaining isEqualTo [] && {(allGroups - _groupsBefore) isEqualTo []}
    && {(call _stats) select [1,3] isEqualTo [0,0,0]} && {count A3I_sites == 0}
    && {isNil "A3I_siteWatchdogHandle"} && {count A3I_rescues == 0} && {isNil "A3I_rescueHandle"},
    [_remaining apply {typeOf _x},count (allGroups - _groupsBefore),call _stats]] call _check;
