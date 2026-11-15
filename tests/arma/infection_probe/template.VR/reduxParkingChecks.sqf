// Parking-only sweep through Ultimate native town initialization on installed Redux.
#include "\x\a3a\addons\core\script_component.hpp"
private _before = entities [[],[],true,false];
private _groupsBefore = +allGroups;
A3I_test_abandonedMode = true; distanceSPWN = 150;
A3I_test_convoyMode = false; A3I_test_observers = []; A3I_test_support = [];
A3A_faction_inv = createHashMap;
A3A_faction_civ = createHashMapFromArray [["animations",createHashMap],["variants",createHashMap]];
A3A_faction_reb = createHashMapFromArray [["lootCrate","Box_NATO_Ammo_F"]];
A3A_faction_all = createHashMapFromArray [["vehiclesArmor",[]],["vehiclesAPCs",[]],["vehiclesIFVs",[]],
    ["vehiclesLightAPCs",[]],["vehiclesRivals",[]]];
A3A_vehicleResourceCosts = createHashMap;
A3A_GCThreshold = 600; GVAR(despawnQueue) = []; GVAR(despawnerRunning) = nil;
serverInitDone = true; enableVehicleAutoLock = true; enableVehicleAutoLockCiv = true;
civTraffic = 1; tierWar = 1; seaSpawn = []; areRivalsEnabled = false;
sidesX = [true] call A3A_fnc_createNamespace; spawner = [true] call A3A_fnc_createNamespace;

server = [true] call A3A_fnc_createNamespace; colorOccupants = "ColorBLUFOR";
0 setFog [1,0,0]; // Natural fog gate suppresses driven traffic; boat/traffic acceptance is separate.
respawnTeamPlayer = "a3i_redux_parking_hq"; posHQ = [500,500,0];
createMarker [respawnTeamPlayer,posHQ]; sidesX setVariable [respawnTeamPlayer,teamPlayer];
private _data = [true] call A3A_fnc_getCityData;
citiesX = _data # 0; A3A_townData = createHashMapFromArray (_data # 1);
markersX = [respawnTeamPlayer]+citiesX; destroyedSites = [];
["redux_world",toLower worldName == "chernarusredux"] call _check;
["redux_native_towns",count citiesX == 49,count citiesX] call _check;
private _total = 0; private _empty = [];
{
    private _town = _x; private _index = _forEachIndex;
    spawner setVariable [_town+"_civ",0];
    private _roads = nearestTerrainObjects [getMarkerPos _town,["MAIN ROAD","ROAD","TRACK"],250,false,true];
    _roads = _roads select {!(getRoadInfo _x # 8) && {count roadsConnectedTo [_x,true] <= 2} && {count (_x nearRoads 10) < 2}};
    ["redux_roads_"+str _index,count _roads > 0,[_town,count _roads]] call _check;
    private _started = [_town] call A3I_fnc_startAbandonedTown;
    private _record = A3I_abandonedTowns getOrDefault [_town,createHashMap];
    private _until = diag_tickTime+20;
    waitUntil {sleep 0.1; _record getOrDefault ["parkingComplete",false] || {diag_tickTime > _until}};
    private _vehicles = +(_record getOrDefault ["vehicles",[]]);
    private _population = (A3A_townData get _town) # 0;
    private _expected = [_population,count _roads,tierWar,civTraffic,daytime] call A3I_fnc_abandonedParkedCount;
    _total = _total+count _vehicles; if (_vehicles isEqualTo []) then {_empty pushBack _town};
    ["redux_parking_"+str _index,_started && {_record getOrDefault ["parkingComplete",false]}
        && {_record getOrDefault ["parkedAttempts",-1] == _expected} && {count _vehicles <= _expected}
        && {(_vehicles findIf {!alive _x || {crew _x isNotEqualTo []}
            || {_x getVariable ["ownerSide",west] != sideUnknown} || {!(_x getVariable ["A3I_abandoned",false])}
            || {_x distance2D getMarkerPos _town > 255}}) == -1},
        [_town,_population,_expected,count _vehicles,_vehicles apply {typeOf _x}]] call _check;
    spawner setVariable [_town+"_civ",2];
    _until = diag_tickTime+5;
    waitUntil {sleep 0.1; (!(_town in A3I_abandonedTowns) && {(_vehicles findIf {!isNull _x}) == -1}) || {diag_tickTime > _until}};
    ["redux_cleanup_"+str _index,!(_town in A3I_abandonedTowns)
        && {(_vehicles findIf {!isNull _x}) == -1}
        && {(entities [[],[],true,false]) - _before - [server,sidesX,spawner] isEqualTo []},[_town,_town in A3I_abandonedTowns,
        _vehicles apply {[isNull _x,typeOf _x,str _x]},
        ((entities [[],[],true,false]) - _before - [server,sidesX,spawner]) apply {[typeOf _x,str _x,getPosATL _x]},
        allGroups - _groupsBefore]] call _check;
} forEach citiesX;
["redux_population_observed",_total > 0,[_total,_empty]] call _check;
["redux_no_theft_effects",A3I_test_support isEqualTo []] call _check;
{deleteMarker _x; deleteMarker ("Dum"+_x)} forEach citiesX;
deleteMarker respawnTeamPlayer; deleteVehicle server; deleteVehicle sidesX; deleteVehicle spawner;
sleep 6;
["redux_final_cleanup",(entities [[],[],true,false]) - _before isEqualTo []
    && {allGroups - _groupsBefore isEqualTo []} && {isNil "A3I_abandonedTownHandle"}] call _check;
