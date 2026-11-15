// Adapted from Ultimate 12.4.2 fn_CONVOY.sqf, c7c8247672ed5e7d4aa317d47efb371c41de4e7d.
// Upstream copyright/license: Infection/THIRD_PARTY_LICENSES.txt.
// Automatic Invader supply traffic only: no task, route reveal, or player rewards.
#include "\x\a3a\addons\core\script_component.hpp"
FIX_LINE_NUMBERS()
if (!isServer || {!canSuspend} || {isRemoteExecuted && {remoteExecutedOwner != 2}}) exitWith {};
params ["_mrkDest", "_mrkOrigin", ["_convoyType", "Supplies"], ["_resPool", "attack"], ["_startDelay", -1]];
if (!([west] call A3I_fnc_isActive) || {_convoyType != "Supplies"} || {_resPool != "attack"}
    || {isNil "sidesX"} || {sidesX getVariable [_mrkOrigin,sideUnknown] != Invaders}) exitWith {};
private _claimed = [{
    if (missionNamespace getVariable ["A3A_convoyInProgress",false]) exitWith {false};
    missionNamespace setVariable ["A3A_convoyInProgress",true,true];
    true
}] call CBA_fnc_directCall;
if (!_claimed) exitWith {};
private _difficult = if (random 10 < tierWar) then {true} else {false};
private _sideX = if (sidesX getVariable [_mrkOrigin,sideUnknown] == Occupants) then {Occupants} else {Invaders};
private _milFaction = Faction(_sideX);
private _rebFaction = Faction(teamPlayer);
private _civFaction = Faction(civilian);
private _civDisabled = (_civFaction getOrDefault ["attributeLowCiv", false] || {_civFaction getOrDefault ["attributeCivNonHuman", false]});


private _posSpawn = getMarkerPos _mrkOrigin;			// used for spawning infantry before moving them into vehicles

private _soldiers = [];
private _vehiclesX = [];

if (_startDelay < 0) then { _startDelay = random 5 + ([10,5] select _difficult) };
[_mrkOrigin,_startDelay + 1] call A3A_fnc_addTimeForIdle;
// * Cleanup the civilian and rebel equipment hashmaps (remove vehicle arrays that are nil or empty) before attempting to select a vehicle from them
{
    if (_x in _civFaction && {(_civFaction get _x) isEqualTo []}) then { _civFaction deleteAt _x };
    if (_x in _rebFaction && {(_rebFaction get _x) isEqualTo []}) then { _rebFaction deleteAt _x };
} forEach ["vehiclesCivMedical", "vehiclesCivIndustrial", "vehiclesCivSupply"];

private _vehiclePool = if (_civDisabled) then { _milFaction get "vehiclesMilitiaTrucks" } else {
    _civFaction getOrDefault ["vehiclesCivMedical",_civFaction get "vehiclesCivIndustrial"]
} select { _x isEqualType "" };
private _typeVehObj = selectRandom (_rebFaction getOrDefault ["vehiclesCivSupply",_vehiclePool]);
// Find suitable nav points for origin/dest
private _posOrigin = navGrid select ([_mrkOrigin] call A3A_fnc_getMarkerNavPoint) select 0;
private _posDest = navGrid select ([_mrkDest] call A3A_fnc_getMarkerNavPoint) select 0;

private _route = [_posOrigin, _posDest] call A3A_fnc_findPath;
_route = _route apply { _x select 0 };			// reduce to position array
if (_route isEqualTo []) then { _route = [_posOrigin, _posDest] };

private _vehPool = ([_sideX, tierWar] call A3A_fnc_getVehiclesGroundTransport) + ([_sideX, tierWar] call A3A_fnc_getVehiclesGroundSupport);
private _pathState = [];			// Set the scope so that state is preserved between findPosOnRoute calls

// Spawning worker functions

private _fnc_spawnConvoyVehicle = {
    params ["_vehType"];
    ServerDebug_1("Spawning vehicle type %1", _vehType);

    // Find location down route
    _pathState = [_route, [20, 0] select (count _pathState == 0), _pathState] call A3A_fnc_findPosOnRoute;
    while {true} do {
        // make sure there are no other vehicles within 10m
        if (count (ASLtoAGL (_pathState#0) nearEntities 10) == 0) exitWith {};
        _pathState = [_route, 10, _pathState] call A3A_fnc_findPosOnRoute;
    };

    private _veh = createVehicle [_vehType, ASLtoAGL (_pathState#0) vectorAdd [0,0,0.5]];               // Give it a little air
    private _vecUp = (_pathState#1) vectorCrossProduct [0,0,1] vectorCrossProduct (_pathState#1);       // correct pitch angle
    _veh setVectorDirAndUp [_pathState#1, _vecUp];
    _veh allowDamage false;

    private _group = [_sideX, _veh] call A3A_fnc_createVehicleCrew;
    { [_x, nil, nil, _resPool] call A3A_fnc_NATOinit; _x allowDamage false; _x disableAI "MINEDETECTION" } forEach (units _group);
    _soldiers append (units _group);
    (driver _veh) stop true;
    deleteWaypoint [_group, 0];													// groups often start with a bogus waypoint

    [_veh, _sideX, _resPool] call A3A_fnc_AIVEHinit;
    if (_vehType in FactionGet(all,"vehiclesArmor")) then { _veh allowCrewInImmobile true };			// move this to AIVEHinit at some point?
    _vehiclesX pushBack _veh;
    _veh;
};
private _fnc_spawnEscortVehicle = {
    private _typeVehEsc = selectRandomWeighted _vehPool;
    
    private _veh = [_typeVehEsc] call _fnc_spawnConvoyVehicle;

    private _typeGroup = [_typeVehEsc, _sideX] call A3A_fnc_cargoSeats;
    if (count _typeGroup == 0) exitWith {};
    private _groupEsc = [_posSpawn, _sideX, _typeGroup] call A3A_fnc_spawnGroup;				// Unit limit?
    {[_x, nil, nil, _resPool] call A3A_fnc_NATOinit;_x assignAsCargo _veh;_x moveInCargo _veh;} forEach units _groupEsc;
    _soldiers append (units _groupEsc);
};


// Tail escort
[] call _fnc_spawnEscortVehicle;

// Objective vehicle
sleep 2;
private _vehObj = [_typeVehObj] call _fnc_spawnConvoyVehicle;
private _supObj = objNull;
private _objectiveIsCargo = (_vehObj call A3A_Logistics_fnc_getVehCapacity) > 0;

if (_convoyType == "Supplies") then
{
    if (_objectiveIsCargo) then {
        // * put a supply container in the truck so it can be identified more easily as the objective vehicle
        {
            _supObj = _x createVehicle (position _vehObj);
        
            // * try to load a large container, then fall back to small box if we can't load large container
            private _canLoad = [_vehObj, _supObj] call A3A_Logistics_fnc_canLoad;
            if (_canLoad isEqualType -1) then {
                deleteVehicle _supObj; 
                continue 
            } else {
                clearMagazineCargoGlobal _supObj;
                clearWeaponCargoGlobal _supObj;
                clearItemCargoGlobal _supObj;
                clearBackpackCargoGlobal _supObj;
                _supObj setDamage 0.75; // vanilla supply crates are ridiculously strong. Would make destroying (instead of stealing) the cargo way too hard / resource intensive
                _supObj lockInventory true; // don't want pesky inquisitive players to know there's not actually anything in here lol
                _supObj call A3A_Logistics_fnc_addLoadAction;
                (_canLoad + [true]) call A3A_Logistics_fnc_load;
                break
            };
        } forEach [selectRandom ["Land_PaperBox_01_open_boxes_F", "Land_PaperBox_01_open_water_F", "Land_PaperBox_01_small_stacked_F", "Land_WaterBottle_01_stack_F", "Land_FoodSacks_01_cargo_white_idap_F"], "Land_PaperBox_01_small_closed_white_med_F"];
    };
    _vehObj setVariable ["A3A_reported", true, true];
};
// Initial escort vehicles, 0-1 for SP, 1-2 for 10+
private _countX = round ((A3A_balancePlayerScale min 1.5) + random 0.5 + ([-0.75, 0.25] select _difficult));
for "_i" from 1 to _countX do
{
    sleep 2;
    [] call _fnc_spawnEscortVehicle;
};

// Lead vehicle
sleep 2;
private _typeVehX = selectRandom ( switch true do {
    case (_sideX == Occupants && random 4 < tierWar): { (_milFaction get "vehiclesPolice") };
    case (tierWar < 5): { (_milFaction get "vehiclesMilitiaLightArmed") };
    case (tierWar < 7): { (_milFaction get "vehiclesLightArmed") + (_milFaction get "vehiclesMilitiaLightArmed") };
    default { (_milFaction get "vehiclesLightArmed") };
});
private _vehLead = [_typeVehX] call _fnc_spawnConvoyVehicle;

// Apply convoy resource cost, if it's from attack or defence pool
if (_resPool != "legacy") then {
    private _resources = 10 * count _soldiers;
    { _resources = _resources + (A3A_vehicleResourceCosts getOrDefault [typeOf _x, 0]) } forEach _vehiclesX;
    [-_resources, _sideX, _resPool] remoteExec ["A3A_fnc_addEnemyResources", 2];
};

// Remove spawn-suicide protection
sleep 2;
{_x allowDamage true} forEach _vehiclesX;
{_x allowDamage true; if (vehicle _x == _x) then {deleteVehicle _x}} forEach _soldiers;
ServerInfo_2("Spawn performed: %1 ground vehicles, %2 soldiers", count _vehiclesX, count _soldiers);


// Send the vehicles after the delay

sleep (60*_startDelay);
_route = _route select [_pathState#2, count _route];        // remove navpoints that we already passed while spawning
ServerInfo("Background supply convoy under way");

// This array is used to share remaining convoy vehicles between threads
private _convoyVehicles = +_vehiclesX;
reverse _convoyVehicles;
{
    (driver _x) stop false;
    [_x, _route, _convoyVehicles, 30, _x == _vehObj] spawn A3A_fnc_vehicleConvoyTravel;
    sleep 3;
} forEach _convoyVehicles;



// **************** Termination condition handling ********************************

private _bonus = if (_difficult) then {1.5} else {1};
private _arrivalDist = 100;
private _timeout = time + 3600;

private _fnc_applyResults = {
    params ["_success","_success1","_adjustCA","_adjustBoss","_aggroMod","_aggroTime","_type"];
    [_adjustCA,_sideX] remoteExec ["A3A_fnc_timingCA",2];
    [_sideX,_aggroMod,_aggroTime] remoteExec ["A3A_fnc_addAggression",2];
    if (!_success1) then {
        private _killZones = killZones getVariable [_mrkOrigin,[]];
        killZones setVariable [_mrkOrigin,_killZones + [_mrkDest,_mrkDest],true];
    };
};
if (_convoyType isEqualTo "Supplies") then
{
    private _objectiveObj = objNull;
    private _driver = objNull;
if (_objectiveIsCargo) then {
        _objectiveObj = _supObj;
        _driver = driver attachedTo _supObj;
        _vehObj addEventHandler ["Killed", {
            params ["_vehicle", "_killer", "_instigator", "_useEffects"];
            private _cargoItem = _vehicle call A3A_Logistics_fnc_getCargo select 0;
            _cargoItem setDamage 1;
            deleteVehicle _cargoItem;

        }];
    } else {
        _objectiveObj = _vehObj;
        _driver = driver _vehObj;
    };
    
    waitUntil {sleep 1; (time > _timeout) or (_objectiveObj distance _posDest < _arrivalDist) or (not alive _objectiveObj) or (side group _driver != _sideX)};
    if (not alive _objectiveObj) then
    {
        [false, false, 0, -10, 0, 0, "supply"] call _fnc_applyResults;
    }
    else
    {
        if (side group _driver != _sideX) then
        {
            waitUntil {sleep 1; (_objectiveObj distance _posDest < _arrivalDist) or (not alive _objectiveObj) or (time > _timeout)};
            if (_objectiveObj distance _posDest < _arrivalDist) then
            {
		[true, false, 200*_bonus, 10*_bonus, 5, 120, "supply"] call _fnc_applyResults;
                [0,15*_bonus,_mrkDest] remoteExec ["A3A_fnc_citySupportChange",2];

            }
            else
            {
                [false, false, 0, -5, 0, 0, "supply"] call _fnc_applyResults;
                [0,-5*_bonus,_mrkDest] remoteExec ["A3A_fnc_citySupportChange",2];
            };
        }
        else
        {
            [false, true, 0, -10, 0, 0, "supply"] call _fnc_applyResults;
            [15*_bonus,0,_mrkDest] remoteExec ["A3A_fnc_citySupportChange",2];
        };
    };
    if (alive _supObj) then {deleteVehicle _supObj};
};

// Clear this array so the vehicleConvoyTravel spawns exit and merge groups
_convoyVehicles resize 0;
sleep 5;

// Groups change due to convoy crew group split/merge, so we recreate them
private _groups = [];
{ if (alive _x) then {_groups pushBackUnique (group _x)} } forEach _soldiers;
{ [_x] spawn A3A_fnc_groupDespawner } forEach _groups;
{ [_x] spawn A3A_fnc_VEHdespawner } forEach _vehiclesX;

missionNamespace setVariable ["A3A_convoyInProgress", false, true];

// Hang around for a bit, and then send all escorts back to the source base
sleep 60;
{
    if (count units _x > 0) then {
        private _wp = _x addWaypoint [_posOrigin, 50];
        _wp setWaypointType "MOVE";
        _x setCurrentWaypoint _wp;
    };
} forEach _groups - [group driver _vehObj];
