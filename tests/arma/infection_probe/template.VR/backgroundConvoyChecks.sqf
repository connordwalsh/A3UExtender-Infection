// Real engine vehicles/crew, path placement, logistics and controller. Movement,
// combat initialization and campaign notifications are isolated endpoint contracts.
private _before = entities [[],[],true,false];
private _groupsBefore = +allGroups;
private _markersBefore = +allMapMarkers;
private _savedFaction = A3A_faction_occ;
private _wait = {
    params ["_predicate",["_seconds",40]];
    private _until = diag_tickTime + _seconds;
    waitUntil {sleep 0.05; call _predicate || {diag_tickTime > _until}};
    call _predicate
};
sidesX = [true] call A3A_fnc_createNamespace;
server = [true] call A3A_fnc_createNamespace;
killZones = [true] call A3A_fnc_createNamespace;
private _origin = "a3i_bg_origin";
private _target = "a3i_bg_target";
createMarker [_origin,[4000,4000,0]];
createMarker [_target,[5000,4000,0]];
sidesX setVariable [_origin,east]; sidesX setVariable [_target,teamPlayer];
NavGrid = [[[4000,4000,0],1,0,[[1,0,1000]]],[[5000,4000,0],1,0,[[0,0,1000]]]];
A3A_navCellHM = createHashMap; {_forEachIndex call A3A_fnc_addToNavCells} forEach NavGrid;
A3A_markerNavPoints = createHashMap;
A3A_faction_inv = createHashMap;
{A3A_faction_inv set [_x,[]]} forEach ["vehiclesPolice","vehiclesMilitiaCars","vehiclesMilitiaTrucks",
    "vehiclesMilitiaAPCs","vehiclesLightUnarmed","vehiclesLightArmedTroop","vehiclesTrucks",
    "vehiclesLightAPCs","vehiclesAPCs","vehiclesIFVs","vehiclesTanks","vehiclesLightTanks","vehiclesAA"];
{A3A_faction_inv set [_x,["O_MRAP_02_F"]]} forEach ["vehiclesLightUnarmed","vehiclesLightArmed","vehiclesMilitiaLightArmed"];
A3A_faction_reb = createHashMapFromArray [["vehiclesCivSupply",["C_Truck_02_transport_F"]],["lootCrate","Box_NATO_Ammo_F"]];
A3A_faction_civ = createHashMapFromArray [["attributeLowCiv",true]];
A3A_faction_all = createHashMapFromArray [["vehiclesArmor",[]]];
private _zeroCargoTypes = ["B_MBT_01_cannon_F"] select {
    isClass (configFile >> "CfgVehicles" >> _x) && {([_x] call A3A_Logistics_fnc_getVehCapacity) == 0}
};
["bg_zero_capacity_vehicle",count _zeroCargoTypes > 0,_zeroCargoTypes] call _check;
private _zeroCargoType = _zeroCargoTypes param [0,"B_MBT_01_cannon_F"];
A3A_vehicleResourceCosts = createHashMapFromArray [["O_MRAP_02_F",100],["C_Truck_02_transport_F",100],[_zeroCargoType,100]];
tierWar = 0; debug = false; A3A_balancePlayerScale = 0;
A3A_tasksData = []; A3A_activeTasks = []; A3A_taskCount = 19;
A3I_test_originals = []; A3I_test_convoyMode = true;
A3A_convoyInProgress = false;
["bg_registered",getText (configFile >> "CfgFunctions" >> "A3A" >> "Missions" >> "CONVOY" >> "file")
    == "\x\a3i\addons\core\overrides\fn_CONVOY.sqf" && {!isNil "A3I_fnc_backgroundSupplyConvoy"}] call _check;
private _arguments = [_target,_origin,"Supplies","attack",0,true];
A3A_faction_occ = createHashMap;
_arguments call A3A_fnc_CONVOY;
["bg_ordinary_delegates",A3I_test_originals isEqualTo [["originalConvoy",_arguments]]] call _check;
A3I_test_originals = [];
[_arguments,"A3A_fnc_convoy"] call A3A_fnc_scheduler;
["bg_ordinary_scheduler_delegates",A3I_test_originals isEqualTo [["originalScheduler",[_arguments,"A3A_fnc_convoy"]]]] call _check;
A3A_faction_occ = _savedFaction;
A3I_test_originals = [];
private _legacy = [_target,_origin,"","legacy",-1,true];
_legacy call A3A_fnc_CONVOY;
[_legacy,"A3A_fnc_convoy"] call A3A_fnc_scheduler;
["bg_other_routes_preserved",A3I_test_originals isEqualTo [["originalConvoy",_legacy],["originalScheduler",[_legacy,"A3A_fnc_convoy"]]]] call _check;
A3I_test_originals = [];
sidesX setVariable [_origin,west];
_arguments call A3I_fnc_backgroundSupplyConvoy;
["bg_infected_source_rejected",!A3A_convoyInProgress] call _check;
sidesX setVariable [_origin,east];
private _workers = [];
{
    private _scenario = _x;
    private _expectedCrew = if (_scenario == "no_cargo") then {2 + ([_zeroCargoType,false] call BIS_fnc_crewCount)} else {3};
    private _expectedAttack = 10000 - 300 - 10 * _expectedCrew;
    A3I_test_convoyVehicles = []; A3I_test_convoyTravel = []; A3I_test_nativeInitCalls = [];
    A3I_test_vehicleCleanup = []; A3I_test_groupCleanup = []; A3I_test_logisticsCalls = [];
    A3I_test_support = []; A3I_test_aggression = []; A3I_test_convoyObjective = objNull;
    A3A_resourcesAttackInv = 10000; A3A_resourcesDefenceInv = 10000;
    A3A_resourcesAttackOcc = 10000; A3A_resourcesDefenceOcc = 10000;
    killZones setVariable [_origin,[]];
    A3A_faction_reb set ["vehiclesCivSupply",[["C_Truck_02_transport_F"],[_zeroCargoType]] select (_scenario == "no_cargo")];
    _arguments set [4,[0,0.1] select (_scenario == "parked")];
    // First case exercises the real scheduler -> remote server wrapper.
    if (_scenario == "arrival") then {
        [_arguments,"a3a_fnc_convoy"] call A3A_fnc_scheduler;
    } else {
        _workers pushBack (_arguments spawn A3A_fnc_CONVOY);
    };
    private _started = [{count A3I_test_convoyVehicles >= 1},10] call _wait;
    ["bg_" + _scenario + "_starts",_started && {A3A_convoyInProgress} && {A3I_test_originals isEqualTo []}] call _check;
    private _duplicate = _arguments spawn A3A_fnc_CONVOY;
    [{scriptDone _duplicate},5] call _wait;
    ["bg_" + _scenario + "_duplicate_refused",scriptDone _duplicate] call _check;
    private _ready = if (_scenario == "parked") then {
        [{count A3I_test_convoyVehicles == 3 && {isDamageAllowed (A3I_test_convoyVehicles # 1 # 0)}},40] call _wait
    } else {
        [{!isNull A3I_test_convoyObjective && {count A3I_test_convoyTravel == count A3I_test_convoyVehicles}},40] call _wait
    };
    if (_scenario == "parked" && {_ready}) then {A3I_test_convoyObjective = A3I_test_convoyVehicles # 1 # 0};
    private _vehicle = A3I_test_convoyObjective;
    private _vehicles = A3I_test_convoyVehicles apply {_x # 0};
    private _crew = []; {_crew append crew _x} forEach _vehicles;
    private _cargo = if (isNull _vehicle) then {[]} else {attachedObjects _vehicle};
    ["bg_" + _scenario + "_force",_ready && {count _vehicles == 3} && {count _crew == _expectedCrew}
        && {{side group _x == east && {!(_x getVariable ["A3I_initialized",false])}} count _crew == _expectedCrew}
        && {count A3I_test_nativeInitCalls == _expectedCrew},[count _vehicles,count _crew]] call _check;
    ["bg_" + _scenario + "_cost",A3A_resourcesAttackInv == _expectedAttack && {A3A_resourcesDefenceInv == 10000}
        && {A3A_resourcesAttackOcc == 10000} && {A3A_resourcesDefenceOcc == 10000},[A3A_resourcesAttackInv]] call _check;
    ["bg_" + _scenario + "_cargo",(count _cargo > 0) isEqualTo (_scenario != "no_cargo"),[count _cargo]] call _check;
    private _capturedGroup = grpNull;
    if (_ready) then {
        switch (_scenario) do {
            case "parked";
            case "destroyed": {_vehicle setDamage 1};
            case "captured": {
                _capturedGroup = createGroup [teamPlayer,true];
                [driver _vehicle] joinSilent _capturedGroup;
                _vehicle setPosATL getMarkerPos _target;
            };
            default {_vehicle setPosATL getMarkerPos _target};
        };
    };
    private _finished = [{!A3A_convoyInProgress
        && {count A3I_test_vehicleCleanup == count _vehicles} && {count A3I_test_groupCleanup > 0}},30] call _wait;
    ["bg_" + _scenario + "_settles",_finished && {count A3I_test_vehicleCleanup == count _vehicles}
        && {count A3I_test_groupCleanup > 0},[!A3A_convoyInProgress,count A3I_test_vehicleCleanup,count _vehicles,count A3I_test_groupCleanup]] call _check;
    private _expectedSupport = switch (_scenario) do {
        case "parked";
        case "destroyed": {[]};
        case "captured": {[[0,15,_target]]};
        default {[[15,0,_target]]};
    };
    ["bg_" + _scenario + "_support",A3I_test_support isEqualTo _expectedSupport,A3I_test_support] call _check;
    ["bg_" + _scenario + "_strategic",A3A_resourcesAttackInv == (_expectedAttack - ([0,20] select (_scenario == "captured")))
        && {A3A_resourcesDefenceInv == ([10000,9980] select (_scenario == "captured"))}
        && {killZones getVariable [_origin,[]] isEqualTo ([[],[_target,_target]] select (_scenario in ["destroyed","parked","captured"]))}] call _check;
    ["bg_" + _scenario + "_no_mission",A3A_tasksData isEqualTo [] && {A3A_activeTasks isEqualTo []}
        && {A3A_taskCount == 19} && {allMapMarkers - _markersBefore - [_origin,_target] isEqualTo []}] call _check;
    {deleteVehicle _x} forEach _crew;
    {deleteVehicle _x} forEach _cargo;
    {deleteVehicle _x} forEach _vehicles;
    {deleteGroup _x} forEach (allGroups - _groupsBefore);
    sleep 0.5;
} forEach ["arrival","destroyed","parked","captured","no_cargo"];
// Native return-order tail lasts 60 seconds. Let it finish before deleting markers.
sleep 61;
["bg_workers_finish",{!scriptDone _x} count _workers == 0 && {!A3A_convoyInProgress}] call _check;
{deleteVehicle _x} forEach [sidesX,server,killZones];
{deleteMarker _x} forEach [_origin,_target];
A3I_test_convoyMode = nil;
sleep 0.5;
["bg_cleanup",(entities [[],[],true,false]) - _before isEqualTo []
    && {allGroups - _groupsBefore isEqualTo []}] call _check;
