// Real Redux full-population activation and visit cleanup. Not a campaign/performance soak.
#include "\x\a3a\addons\core\script_component.hpp"
private _before = entities [[],[],true,false]; private _groupsBefore = +allGroups;
plusGarrison = true; tierWar = 1; distanceSPWN = 1000;
A3A_GCThreshold = 600; GVAR(despawnQueue) = []; GVAR(despawnerRunning) = nil;
A3A_recentDamageOcc = []; A3A_hasACE = false;
A3I_test_support = []; A3I_test_aggression = []; A3I_test_zones = []; A3I_test_observers = [];
A3A_resourcesAttackOcc = 1000; A3A_resourcesDefenceOcc = 1000;
sidesX = [true] call A3A_fnc_createNamespace;
spawner = [true] call A3A_fnc_createNamespace;
garrison = [true] call A3A_fnc_createNamespace;
server = [true] call A3A_fnc_createNamespace;
garrisonIsChanging = false; colorOccupants = "ColorBLUFOR";
respawnTeamPlayer = "a3i_redux_town_hq"; createMarker [respawnTeamPlayer,[500,500,0]];
sidesX setVariable [respawnTeamPlayer,teamPlayer];
controlsX = []; milAdministrationsX = []; airportsX = []; outposts = []; seaports = [];
milbases = []; resourcesX = []; factories = []; townSkirmishes = []; destroyedSites = [];
A3A_faction_civ = createHashMapFromArray [["attributeCivNonHuman",false]];
private _data = [true] call A3A_fnc_getCityData;
citiesX = _data # 0; A3A_townData = createHashMapFromArray (_data # 1);
markersX = citiesX + [respawnTeamPlayer];
private _town = getText(configFile >> "CfgWorlds" >> worldName >> "Names" >> "city_Chernogorsk" >> "name");
["rtown_native_capital",toLower worldName == "chernarusredux" && {_town in citiesX}
    && {(A3A_townData get _town) # 0 == 1176},[_town,A3A_townData getOrDefault [_town,[]],getMarkerPos _town,markerSize _town]] call _check;
["rtown_population_target",(([_town] call A3I_fnc_cityRoster) # 0) isEqualType []
    && {count (([_town] call A3I_fnc_cityRoster) # 0) == 200}] call _check;
private _wait = {
    params ["_predicate",["_timeout",10]]; private _deadline = diag_tickTime+_timeout;
    waitUntil {sleep 0.1; call _predicate || {diag_tickTime > _deadline}}; call _predicate
};
hcArray = [];
for "_visit" from 1 to 2 do {
    spawner setVariable [_town,0];
    private _began = diag_tickTime;
    [[_town],"A3A_fnc_createAICities"] call A3A_fnc_scheduler;
    private _started = [{_town in (missionNamespace getVariable ["A3I_sites",createHashMap])},10] call _wait;
    ["rtown_started_"+str _visit,_started] call _check;
    private _record = (missionNamespace getVariable ["A3I_sites",createHashMap]) getOrDefault [_town,createHashMap];
    private _ready = [{count (_record getOrDefault ["queue",[]]) == 0 && {_record getOrDefault ["spawnedCount",0] == 200}},180] call _wait;
    private _units = +(_record getOrDefault ["units",[]]); private _groups = +(_record getOrDefault ["groups",[]]);
    ["rtown_full_population_"+str _visit,_ready && {count _units == 200} && {{alive _x} count _units == 200}
        && {_record getOrDefault ["fault","missing"] == ""},
        [diag_tickTime-_began,count _units,{alive _x} count _units,count (_record getOrDefault ["queue",[]]),
            _record getOrDefault ["fault","missing"],diag_fps]] call _check;
    ["rtown_native_roles_"+str _visit,count _units == 200
        && {(_units findIf {!([_x] call A3I_fnc_isManagedUnit) || {side group _x != west} || {!local _x}}) == -1}] call _check;
    // Earlier batches can already be walking when the final batch spawns.
    // Validate recorded spawn positions; retain current positions as diagnostics.
    private _outside = _units select {!(_x inArea _town) || {surfaceIsWater getPosATL _x}};
    ["rtown_inside_town_"+str _visit,(_units findIf {
        private _spawn = _x getVariable ["A3I_spawnPosition",[]];
        count _spawn < 2 || {!(_spawn inArea _town)} || {surfaceIsWater _spawn}
    }) == -1, [count _outside,(_outside select [0,3]) apply {[typeOf _x,_x getVariable ["A3I_spawnPosition",[]],getPosATL _x]}]] call _check;
    private _positions = _units apply {getPosATL _x};
    sleep 20;
    private _moves = [];
    {_moves pushBack (_x distance2D (_positions # _forEachIndex))} forEach _units;
    ["rtown_movement_observed_"+str _visit,(_moves findIf {_x > 1}) != -1,
        [{_x > 1} count _moves,selectMax _moves,count _groups,_groups apply {count (_x getVariable ["A3I_patrolPoints",[]])},diag_fps]] call _check;
    spawner setVariable [_town,2];
    private _clean = [{!(_town in A3I_sites) && {(_units findIf {!isNull _x}) == -1}
        && {(_groups findIf {!isNull _x}) == -1}},15] call _wait;
    ["rtown_visit_cleanup_"+str _visit,_clean && {count A3I_budgetRecords == 0},
        [_clean,count A3I_budgetRecords,(_units select {!isNull _x}) apply {typeOf _x}]] call _check;
};
{deleteMarker _x; deleteMarker ("Dum"+_x)} forEach citiesX;
deleteMarker respawnTeamPlayer;
{deleteVehicle _x} forEach [sidesX,spawner,garrison,server];
sleep 1;
["rtown_final_cleanup",(entities [[],[],true,false]) - _before isEqualTo []
    && {allGroups - _groupsBefore isEqualTo []},[(entities [[],[],true,false]) - _before,allGroups - _groupsBefore]] call _check;
