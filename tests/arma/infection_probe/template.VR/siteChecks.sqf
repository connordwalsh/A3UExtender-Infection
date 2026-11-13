// Real six-site controllers, flags, crates, movement, budget, kill and roster updates.
// Arsenal/UI/worker behavior and original-faction routes are recording endpoints.
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
garrisonIsChanging = false;
respawnTeamPlayer = "a3i_sites_hq";
createMarker [respawnTeamPlayer,[500,500,0]];
resourcesX = ["a3i_site_resource"];
factories = ["a3i_site_factory"];
outposts = ["a3i_site_outpost"];
seaports = ["a3i_site_seaport"];
milbases = ["a3i_site_milbase"];
airportsX = ["a3i_site_airport"];
private _locations = resourcesX + factories + outposts + seaports + milbases + airportsX;
A3A_milBuildingWhitelist = [];
A3A_faction_civ = createHashMapFromArray [["attributeLowCiv",false]];
A3A_faction_reb = createHashMapFromArray [["diveGear",[]],["flyGear",[]]];
hcArray = [999]; // A routed Infection site must stay on the real server despite this.
A3I_test_originals = [];
A3I_test_lootCalls = [];
A3I_test_logisticsCalls = [];
A3I_test_vehicleCleanup = [];
A3I_test_workerCalls = [];
A3I_test_siteEvents = [];
private _event = [CBA_EVENT_SERVER_SPAWN_LOCATION,{A3I_test_siteEvents pushBack +_this}] call CBA_fnc_addEventHandler;
private _roles = ["loadouts_occ_militia_Rifleman","loadouts_occ_military_Rifleman","loadouts_occ_elite_Rifleman"];
private _prepare = {
    params ["_marker","_roster"];
    if !(_marker in allMapMarkers) then {createMarker [_marker,[4500,4500,0]]};
    _marker setMarkerShape "ELLIPSE";
    _marker setMarkerSize [50,50];
    sidesX setVariable [_marker,west];
    spawner setVariable [_marker,0];
    spawner setVariable [_marker + "_flag_used",[false]];
    spawner setVariable [_marker + "_flag_places",[[[4500,4500,0],0]]];
    spawner setVariable [_marker + "_ammo_used",[false,false]];
    spawner setVariable [_marker + "_ammo_places",[[[4505,4500,0],0],[[4510,4500,0],0]]];
    garrison setVariable [_marker,+_roster];
    garrison setVariable [_marker + "_lootCD",0];
};
private _stop = {
    params ["_marker"];
    spawner setVariable [_marker,2];
    [{!(_marker in A3I_sites)},6] call _wait
};
private _functions = [A3A_fnc_createAIResources,A3A_fnc_createAIOutposts,A3A_fnc_createAIMilbase,A3A_fnc_createAIAirplane];
private _fixtureAliases = ["originalScheduler","originalCreateAIResources","originalCreateAIOutposts",
    "originalCreateAIMilbase","originalCreateAIAirplane","originalMarkerChange","originalMrkWIN","originalSurrenderAction"];
private _missing = _fixtureAliases select {
    getText (configFile >> "CfgFunctions" >> "A3I" >> "Originals" >> _x >> "file")
        != ("\x\a3i\tests\contracts\fn_" + _x + ".sqf")
};
["site_endpoints_registered",_missing isEqualTo [],_missing] call _check;
private _marker = resourcesX # 0;
[_marker,_roles] call _prepare;
{
    sidesX setVariable [_marker,east]; [_marker] call _x;
    sidesX setVariable [_marker,west];
    A3A_faction_occ set ["infectionTemplate",""]; [_marker] call _x;
    A3A_faction_occ set ["infectionTemplate","A3I_Infected"];
    A3I_dependencies set ["available",false]; [_marker] call _x;
    A3I_dependencies set ["available",true];
} forEach _functions;
["site_other_factions_delegate",count A3I_test_originals == 12 && {isNil "A3I_sites" || {count A3I_sites == 0}},
    A3I_test_originals apply {_x # 0}] call _check;
private _calls = count A3I_test_originals;
[17,"unrelated_function"] call A3A_fnc_scheduler;
[["ordinary"],"A3A_fnc_createAIResources"] call A3A_fnc_scheduler;
["site_scheduler_passthrough",count A3I_test_originals == _calls + 2
    && {(A3I_test_originals # _calls) # 1 isEqualTo [17,"unrelated_function"]}] call _check;
private _blocked = [_marker] call A3I_fnc_siteCaptureBlocked;
[independent,_marker] call A3A_fnc_markerChange;
["site_pending_blocks_capture",_blocked && {count A3I_test_originals == _calls + 2}] call _check;
[2,2] call _setLimits;
private _kinds = ["Resource","Resource","Outpost","Outpost","Milbase","Airport"];
private _crateCounts = [0,0,1,1,2,1];
private _routes = ["A3A_fnc_createAIresources","A3A_fnc_createAIResources","A3A_fnc_createAIOutposts",
    "A3A_fnc_createAIOutposts","A3A_fnc_createAIMilbase","A3A_fnc_createAIAirplane"];
{
    private _marker = _x;
    private _index = _forEachIndex;
    private _roster = _roles select [0,if (_index == 0) then {3} else {2}];
    [_marker,_roster] call _prepare;
    private _eventCount = count A3I_test_siteEvents;
    [[_marker],_routes # _index] call A3A_fnc_scheduler;
    private _started = [{!isNil "A3I_sites" && {_marker in A3I_sites}
        && {count ((A3I_sites get _marker) get "units") == 2}}] call _wait;
    private _record = A3I_sites getOrDefault [_marker,createHashMap];
    private _units = _record getOrDefault ["units",[]];
    private _crates = +(_record getOrDefault ["crates",[]]);
    private _duplicate = [_marker,_kinds # _index] call A3I_fnc_startSite;
    private _pending = spawner getVariable [_marker + "_A3I_pending",-1];
    ["site_initial_" + (_marker select [9]),_started && {!_duplicate} && {count _units == 2}
        && {(_units findIf {owner _x != 2 || {side group _x != west} || {vehicle _x != _x}}) == -1}
        && {!isNull (_record getOrDefault ["flag",objNull])} && {count _crates == _crateCounts # _index}
        && {_pending == count _roster - 2} && {garrison getVariable [_marker,[]] isEqualTo _roster}
        && {count A3I_test_siteEvents == _eventCount + 1},
        [count _units,count _crates,_pending,count A3I_test_siteEvents - _eventCount,call _stats]] call _check;
    if (_units isEqualTo []) exitWith {};
    private _victim = _units # 0;
    private _survivor = _units # 1;
    private _startDistance = _survivor distance2D getMarkerPos _marker;
    private _nativeCalls = count A3I_test_originals;
    [_survivor] call A3A_fnc_surrenderAction;
    if (_index == 0) then {
        ["site_no_human_surrender",!captive _survivor && {!(_survivor getVariable ["surrendered",false])}
            && {count A3I_test_originals == _nativeCalls}] call _check;
        spawner setVariable [_marker,1];
        private _disabled = [{!simulationEnabled _survivor},3] call _wait;
        spawner setVariable [_marker,0];
        private _enabled = [{simulationEnabled _survivor},3] call _wait;
        ["site_simulation_transition",_disabled && {_enabled}] call _check;
    };
    _victim setDamage 1;
    [{count (garrison getVariable [_marker,[]]) == count _roster - 1},4] call _wait;
    if (_index == 0) then {
        private _arrived = [{spawner getVariable [_marker + "_A3I_pending",-1] == 0},20] call _wait;
        private _active = (_record get "units") select {alive _x};
        ["site_full_roster_arrives",_arrived && {count _active == 2}
            && {count (garrison getVariable [_marker,[]]) == 2}
            && {(_active findIf {_x getVariable ["unitType",""] == _roles # 2}) != -1}
            && {(call _stats) select [1,2] isEqualTo [2,0]},
            [count _active,garrison getVariable [_marker,[]],call _stats]] call _check;
        ["site_approach_movement",_survivor distance2D getMarkerPos _marker < _startDistance - 1,
            [_startDistance,_survivor distance2D getMarkerPos _marker]] call _check;
        _nativeCalls = count A3I_test_originals;
        [independent,_marker] call A3A_fnc_markerChange;
        ["site_capture_unblocks",!([_marker] call A3I_fnc_siteCaptureBlocked)
            && {count A3I_test_originals == _nativeCalls + 1}] call _check;
    };
    private _moved = objNull;
    if (_index == 2 && {_crates isNotEqualTo []}) then {
        _moved = _crates # 0;
        _moved setPosATL [5000,4500,0];
    };
    private _stopped = [_marker] call _stop;
    private _left = (allUnits select {_x getVariable ["markerX",""] == _marker});
    private _freed = (spawner getVariable [_marker + "_flag_used",[]]) isEqualTo [false]
        && {(spawner getVariable [_marker + "_ammo_used",[]]) isEqualTo [false,false]};
    ["site_cleanup_" + (_marker select [9]),_stopped && {_left isEqualTo []} && {_freed}
        && {isNull (_record get "flag")} && {count A3I_test_siteEvents == _eventCount + 2}
        && {count (garrison getVariable [_marker,[]]) == count _roster - 1},
        [_stopped,count _left,_freed,garrison getVariable [_marker,[]]]] call _check;
    if (_index == 2) then {
        ["site_claimed_loot_preserved",alive _moved && {garrison getVariable [_marker + "_lootCD",0] > 0}
            && {(A3I_test_vehicleCleanup findIf {_x # 0 == _moved}) != -1}] call _check;
        deleteVehicle _moved;
    };
    deleteVehicle _victim;
    private _survivingRoster = +(garrison getVariable [_marker,[]]);
    spawner setVariable [_marker,0];
    [_marker,_kinds # _index] call A3I_fnc_startSite;
    private _reentered = [{_marker in A3I_sites && {count ((A3I_sites get _marker) get "units") == count _survivingRoster}}] call _wait;
    ["site_reentry_" + (_marker select [9]),_reentered
        && {count (allUnits select {_x getVariable ["markerX",""] == _marker}) == count _survivingRoster}
        && {garrison getVariable [_marker,[]] isEqualTo _survivingRoster},
        [count _survivingRoster,call _stats]] call _check;
    [_marker] call _stop;
} forEach _locations;

// Interrupt a real controller during group creation. Reentry must reclaim its
// ticket and even a group not yet returned to the controller's record.
private _marker = resourcesX # 0;
[_marker,_roles] call _prepare;
[3,3] call _setLimits;
[_marker,"Resource"] call A3I_fnc_startSite;
[{(allUnits findIf {_x getVariable ["markerX",""] == _marker}) != -1}] call _wait;
private _stale = A3I_sites get _marker;
private _oldUnits = allUnits select {_x getVariable ["markerX",""] == _marker};
terminate (_stale get "script");
private _doneImmediately = scriptDone (_stale get "script");
[{scriptDone (_stale get "script")},3] call _wait;
private _restarted = [_marker,"Resource"] call A3I_fnc_startSite;
private _reclaimed = [{count ((A3I_sites get _marker) get "units") == 3}] call _wait;
["site_interrupted_controller_reclaimed",_restarted && {_reclaimed} && {(_oldUnits findIf {!isNull _x}) == -1}
    && {count (allUnits select {_x getVariable ["markerX",""] == _marker}) == 3}
    && {(call _stats) select [1,2] isEqualTo [3,0]},
    [_doneImmediately,_restarted,count _oldUnits,_oldUnits apply {isNull _x},call _stats]] call _check;
// Ownership change cancels pending arrivals without instantly deleting residents.
private _record = A3I_sites get _marker;
sidesX setVariable [_marker,east];
sleep 1.5;
["site_ownership_change_stops_queue",(_record get "queue") isEqualTo []
    && {({alive _x} count (_record get "units")) == 3}] call _check;
[_marker] call _stop;
sidesX setVariable [_marker,west];
[_marker,_roles] call _prepare;
[_marker,"Resource"] call A3I_fnc_startSite;
[{count ((A3I_sites get _marker) get "units") == 3}] call _wait;
_record = A3I_sites get _marker;
terminate (_record get "script");
private _recovered = [{!(_marker in A3I_sites)},4] call _wait;
["site_stopped_controller_auto_cleanup",_recovered
    && {(call _stats) select [1,3] isEqualTo [0,0,0]}
    && {garrison getVariable [_marker,[]] isEqualTo _roles},
    [_recovered,call _stats]] call _check;
// A full global budget retains the virtual defenders and the capture guard.
[_marker,_roles] call _prepare;
private _full = ["reserve",["other-event",3,3]] call A3I_fnc_budget;
[_marker,"Resource"] call A3I_fnc_startSite;
sleep 2;
_record = A3I_sites get _marker;
["site_no_capacity_retains_roster",(_record get "units") isEqualTo [] && {count (_record get "queue") == 3}
    && {[_marker] call A3I_fnc_siteCaptureBlocked} && {garrison getVariable [_marker,[]] isEqualTo _roles}] call _check;
[_marker] call _stop;
["close",[_full # 1 # 0]] call A3I_fnc_budget;
// The ordinary human route still receives surrender requests.
private _humanGroup = createGroup [independent,false];
private _human = _humanGroup createUnit ["I_Soldier_F",[6000,6000,0],[],0,"NONE"];
private _nativeCalls = count A3I_test_originals;
[_human] call A3A_fnc_surrenderAction;
["site_human_surrender_delegates",count A3I_test_originals == _nativeCalls + 1] call _check;
deleteVehicle _human;
deleteGroup _humanGroup;
["site_asset_callbacks",count A3I_test_lootCalls > 0 && {count A3I_test_lootCalls == count A3I_test_logisticsCalls}
    && {count A3I_test_workerCalls > 0},
    [count A3I_test_lootCalls,count A3I_test_logisticsCalls,count A3I_test_workerCalls]] call _check;
A3I_test_independentTicks = 0;
private _independentHandler = [{A3I_test_independentTicks = A3I_test_independentTicks + 1},0.1] call CBA_fnc_addPerFrameHandler;
[[],_independentHandler] remoteExecCall ["A3I_fnc_siteWatchdog",2];
sleep 0.6;
["site_recovery_remote_denied",A3I_test_independentTicks >= 2,[A3I_test_independentTicks]] call _check;
[_independentHandler] call CBA_fnc_removePerFrameHandler;
sleep 3;
{deleteGroup _x} forEach (allGroups - _groupsBefore);
[CBA_EVENT_SERVER_SPAWN_LOCATION,_event] call CBA_fnc_removeEventHandler;
{deleteMarker _x} forEach (_locations + [respawnTeamPlayer]);
deleteVehicle garrison; deleteVehicle spawner; deleteVehicle sidesX;
garrison = nil; spawner = nil; sidesX = nil; respawnTeamPlayer = nil;
[_savedCap,_savedContext] call _setLimits;
GVAR(despawnQueue) = [];
private _remaining = (entities [[],[],true,false]) - _before;
["site_all_clean",_remaining isEqualTo [] && {(allGroups - _groupsBefore) isEqualTo []}
    && {count A3I_sites == 0} && {isNil "A3I_siteWatchdogHandle"} && {(call _stats) select [1,3] isEqualTo [0,0,0]},
    [_remaining apply {typeOf _x},count (allGroups - _groupsBefore),call _stats]] call _check;
