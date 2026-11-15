// Actual cargo, native tasks/support/aggression/logistics. Time/travel are controlled.
#include "\x\a3a\addons\core\script_component.hpp"
private _before = entities [[],[],true,false]; private _groupsBefore = +allGroups;
sidesX = [true] call A3A_fnc_createNamespace;
private _group = createGroup teamPlayer;
respawnTeamPlayer = "a3i_atask_hq"; posHQ = [3000,4000,0];
private _town = "a3i_atask_town"; private _other = "a3i_atask_other";
createMarker [respawnTeamPlayer,posHQ]; createMarker [_town,[4000,4000,0]]; createMarker [_other,[4300,4000,0]];
private _markers = [respawnTeamPlayer,_town,_other];
{_x setMarkerShape "ELLIPSE"; _x setMarkerSize [100,100]; sidesX setVariable [_x,west]} forEach _markers;
sidesX setVariable [respawnTeamPlayer,teamPlayer]; sidesX setVariable [_other,east];
markersX = +_markers; citiesX = [_town,_other]; destroyedSites = [];
outposts = []; milbases = []; airportsX = []; seaports = []; factories = []; resourcesX = []; milAdministrationsX = []; controlsX = [];
A3A_townData = createHashMapFromArray [[_town,[200,0,50,20]],[_other,[200,0,50,20]]];
petros = _group createUnit ["I_G_Soldier_F",posHQ,[],0,"NONE"]; petros enableSimulationGlobal false;
private _escort = _group createUnit ["I_G_Soldier_F",[4010,4000,0],[],0,"NONE"];
_escort enableSimulationGlobal false; _escort allowDamage false; _escort setVariable ["spawner",true];
theBoss = objNull; distanceMission = 2000; distanceSPWN = 300; serverInitDone = true; tierWar = 0;
A3A_faction_reb = createHashMapFromArray [["lootCrate","Box_NATO_Ammo_F"],["name","NATO"]];
A3A_utilityItemHM = createHashMap; A3A_GCThreshold = 600; GVAR(despawnQueue) = []; GVAR(despawnerRunning) = nil;
A3A_tasksData = []; A3A_activeTasks = []; A3A_taskCount = 0; A3A_supplyMissionActive = nil;
A3I_aidTasks = createHashMap; A3I_test_convoyMode = false; A3I_test_aidNative = true;
A3I_test_support = []; A3I_test_aggression = []; A3I_test_logisticsCalls = []; A3I_test_observers = [];
A3I_test_originals = []; A3I_test_comms = []; hcArray = [];
A3I_test_markerUpdates = [];
cityIsSupportChanging = false; prestigeIsChanging = false; A3A_balancePlayerScale = 1; gameMode = 1;
aggressionStackOccupants = [[20,0]]; aggressionStackInvaders = [[20,0]];
aggressionLevelOccupants = 1; aggressionLevelInvaders = 1;
A3A_resourcesAttackOcc = 1000; A3A_resourcesDefenceOcc = 1000;
private _assets = [];
private _wait = {
    params ["_condition",["_seconds",8]]; private _until = diag_tickTime+_seconds;
    waitUntil {sleep 0.05; call _condition || {diag_tickTime > _until}};
    call _condition
};
private _getJob = {
    [{count A3I_aidTasks == 1}] call _wait;
    private _job = (values A3I_aidTasks) param [0,createHashMap];
    if (count _job > 0) then {
        [{_job getOrDefault ["taskRegistered",false] || {_job getOrDefault ["settled",false]}}] call _wait;
        _assets pushBack (_job get "package");
    };
    _job
};
private _retire = {
    params ["_job"];
    if !(_job get "settled") then {sidesX setVariable [_town,east]; [{_job get "settled"}] call _wait};
    _job set ["taskDeleteAt",time-1];
    [{count A3I_aidTasks == 0 && {isNil "A3I_aidTaskHandle"}}] call _wait;
    sidesX setVariable [_town,west];
};
["atask_targets_infected_only",(call A3I_fnc_aidTargets) isEqualTo [_town,80000000]] call _check;
A3A_townData set [_town,[200,0,10,90]];
["atask_high_support_excluded",call A3I_fnc_aidTargets isEqualTo []] call _check;
A3A_townData set [_town,[200,0,50,20]];
destroyedSites = [_town];
["atask_destroyed_excluded",call A3I_fnc_aidTargets isEqualTo []] call _check;
destroyedSites = []; distanceMission = 500;
["atask_distance_excluded",call A3I_fnc_aidTargets isEqualTo []] call _check;
distanceMission = 2000;
["atask_unsafe_package_rejected",isNull (([[9000,9000,0]] call A3I_fnc_createAidPackage) # 0)] call _check;
private _saved = A3A_faction_occ; A3A_faction_occ = createHashMap;
[_town] call A3A_fnc_SUPP_Supplies; [_town] call A3A_fnc_RIV_SUPP_Salvage;
["SUPP",2,true] call A3A_fnc_missionRequest;
[[_town],"A3A_fnc_SUPP_Supplies"] call A3A_fnc_scheduler;
["atask_ordinary_delegation",A3I_test_originals isEqualTo [["originalSUPPSupplies",[_town]],
    ["originalRIVSUPPSalvage",[_town]],["missionRequest",["SUPP",2,true]],
    ["originalScheduler",[[_town],"A3A_fnc_SUPP_Supplies"]]]] call _check;
A3A_faction_occ = _saved; A3I_test_originals = [];
{
    [_town] call (missionNamespace getVariable ("A3A_fnc_"+_x));
    private _job = call _getJob;
    ["atask_direct_"+_x,count _job > 0 && {_job get "taskRegistered"} && {_job get "target" == _town}] call _check;
    if (count _job > 0) then {[_job] call _retire};
} forEach ["SUPP_Supplies","RIV_SUPP_Salvage"];
{
    hcArray = [98765]; [[_town],"A3A_fnc_"+_x] call A3A_fnc_scheduler;
    private _job = call _getJob;
    ["atask_scheduler_"+_x,count _job > 0 && {_job get "taskRegistered"} && {local (_job get "package")}] call _check;
    if (count _job > 0) then {[_job] call _retire};
} forEach ["SUPP_Supplies","RIV_SUPP_Salvage"];
hcArray = [];
["SUPP",2,false] call A3A_fnc_missionRequest;
private _job = call _getJob;
[{A3I_test_comms isNotEqualTo []},2] call _wait;
["atask_request_registered",_job get "taskRegistered" && {A3I_test_comms findIf {(_x param [2,""]) == localize "STR_chats_mission_request_success"} >= 0}] call _check;
private _package = _job get "package"; private _ledger = _job get "ledger";
["atask_native_cargo_created",alive _package && {!isDamageAllowed _package} && {_package distance2D posHQ < 50}
    && {typeOf _package == "Land_FoodSacks_01_cargo_brown_F"}
    && {A3I_test_logisticsCalls findIf {(_x # 0) isEqualTo _package} >= 0}
    && {[_package] call A3A_Logistics_fnc_isLoadable}] call _check;
["atask_normal_timings",_job get "duration" == 3600 && {_ledger get "requiredSeconds" == 180}] call _check;
private _serial = A3I_aidTaskSerial;
["SUPP",2,true] call A3A_fnc_missionRequest;
["atask_duplicate_refused",A3I_aidTaskSerial == _serial && {count A3I_aidTasks == 1}] call _check;
_package setPosATL [4000,4000,0]; _escort setCaptive true;
[{!captive _escort},3] call _wait;
["atask_native_undercover_exposure",!captive _escort] call _check;
private _actors = +allUnits; private _groupCount = count allGroups;
isNil {_ledger set ["unloadedSeconds",179]; _ledger set ["wasEligible",true]; _ledger set ["lastCheck",time-1]};
[{_job get "settled"}] call _wait; sleep 0.3;
["atask_success_native_support",_job get "outcome" == "delivered" && {(A3A_townData get _town) isEqualTo [200,0,45,25]}] call _check;
["atask_success_native_aggression",aggressionOccupants == 10 && {count aggressionStackOccupants == 2}] call _check;
["atask_no_extra_horde",allUnits isEqualTo _actors && {count allGroups == _groupCount}] call _check;
["atask_supply_lock_released",isNil "A3A_supplyMissionActive" && {isNil "A3I_aidSupplyLock"}] call _check;
private _supportCount = count A3I_test_support;
[_job] call A3I_fnc_finishHumanitarianAid; sleep 0.1;
["atask_reward_once",count A3I_test_support == _supportCount && {count aggressionStackOccupants == 2}] call _check;
["atask_native_task_success",(A3A_tasksData select {(_x # 0) == (_job get "name")}) # 0 # 2 == "SUCCEEDED"] call _check;
[_job] call _retire;
tierWar = 10;
["SUPP",2,true] remoteExecCall ["A3A_fnc_missionRequest",2]; _job = call _getJob; _ledger = _job get "ledger";
["atask_remote_difficult_request",_job get "taskRegistered" && {_job get "duration" == 1800} && {_ledger get "requiredSeconds" == 90}] call _check;
_ledger set ["deadline",time-1]; [{_job get "settled"}] call _wait; sleep 0.2;
["atask_failure_native_support",_job get "outcome" == "failed" && {(A3A_townData get _town) isEqualTo [200,0,55,15]}] call _check;
[_job] call _retire; tierWar = 0;
{
    ["SUPP",2,true] call A3A_fnc_missionRequest; _job = call _getJob; _ledger = _job get "ledger";
    private _oldSupport = +(A3A_townData get _town); private _oldAggro = +aggressionStackOccupants;
    isNil {_ledger set ["deadline",time-1]; sidesX setVariable [_town,_x]};
    [{_job get "settled"}] call _wait; sleep 0.2;
    ["atask_capture_cancel_"+str _x,_job get "outcome" == "cancelled"
        && {(A3A_townData get _town) isEqualTo _oldSupport} && {aggressionStackOccupants isEqualTo _oldAggro}] call _check;
    [_job] call _retire;
} forEach [east,teamPlayer];
// A detached object still present in the native nested Cargo registry is protected.
["SUPP",2,true] call A3A_fnc_missionRequest; _job = call _getJob; _package = _job get "package";
private _carrier = createVehicle ["C_Offroad_01_F",[3200,4000,0],[],0,"NONE"];
_carrier setVariable ["Cargo",[[_package,0]]];
sidesX setVariable [_town,east]; [{_job get "settled"}] call _wait;
["atask_nested_cargo_retained",!isNull _package && {!(_job get "assetRetired")}] call _check;
_carrier setVariable ["Cargo",[]]; _carrier setPosATL getPosATL _package; _carrier setVariable ["LoadingCargo",true];
sleep 1.2;
["atask_loading_retained",!isNull _package && {!(_job get "assetRetired")}] call _check;
_carrier setVariable ["LoadingCargo",nil];
A3I_test_observers = [petros]; sleep 1.2;
["atask_observed_package_retained",!isNull _package && {!(_job get "assetRetired")}] call _check;
A3I_test_observers = []; [_job] call _retire; deleteVehicle _carrier;
// Registry retirement follows deleteVehicle submission; the engine may retain
// the object reference until a later frame under the full-suite entity load.
[{isNull _package},2] call _wait;
["atask_unobserved_package_retired",isNull _package,
    [_job get "assetRetired",_job get "taskRetired",count A3I_aidTasks]] call _check;
["SUPP",2,true] call A3A_fnc_missionRequest; _job = call _getJob;
terminate (_job get "script"); (_job get "ledger") set ["deadline",time-1];
[{_job get "settled"}] call _wait;
["atask_independent_monitor",_job get "outcome" == "failed"] call _check;
[_job] call _retire;
["SUPP",2,true] call A3A_fnc_missionRequest; _job = call _getJob; _package = _job get "package";
private _foreign = ["another_system",9999];
_package setVariable ["A3I_aidTaskOwner",_foreign];
[{_job get "settled"}] call _wait;
["atask_foreign_asset_preserved",_job get "outcome" == "interrupted" && {!isNull _package}
    && {(_package getVariable ["A3I_aidTaskOwner",[]]) isEqualTo _foreign}
    && {_job get "loadJipKey" == ""}] call _check;
[_job] call _retire;
// Native load JIP record belongs to the retained foreign asset until its owner disposes of it.
private _foreignKey = "A3A_Logistics_load"+((str _package splitString ":") joinString "");
remoteExec ["",_foreignKey]; deleteVehicle _package;
["SUPP",2,true] call A3A_fnc_missionRequest; _job = call _getJob; _package = _job get "package";
deleteVehicle _package; [{_job get "settled"}] call _wait;
["atask_deleted_not_penalized",_job get "outcome" == "interrupted"] call _check;
[_job] call _retire;
[_town] remoteExecCall ["A3I_fnc_startHumanitarianAid",2]; sleep 0.2;
["atask_remote_constructor_refused",count A3I_aidTasks == 0] call _check;
A3A_missionRequestInProgress = true;
private _waiting = ["SUPP",2,true] spawn A3A_fnc_missionRequest; sleep 0.2;
["atask_foreign_lock_waits",count A3I_aidTasks == 0 && {!scriptDone _waiting}] call _check;
terminate _waiting;
["atask_foreign_lock_preserved",A3A_missionRequestInProgress] call _check;
A3A_missionRequestInProgress = nil;
sidesX setVariable [_town,east]; A3I_test_comms = [];
["SUPP",2,false] call A3A_fnc_missionRequest; sleep 0.2;
["atask_unavailable_no_fallback",count A3I_aidTasks == 0 && {A3I_test_originals isEqualTo []}
    && {A3I_test_comms findIf {(_x param [2,""]) == "No Humanitarian Aid is available."} >= 0}] call _check;
private _modern = configFile >> "A3A_RequestMissionDialog" >> "Controls" >> "MainContent" >> "Controls" >> "SupportButton";
private _legacy = configFile >> "missionMenu" >> "Controls" >> "suppButton";
["atask_menu_native_actions",getText (_modern >> "onLoad") == "_this call A3I_fnc_labelAidControl"
    && {getText (_legacy >> "onLoad") == "_this call A3I_fnc_labelAidControl"}
    && {getText (_modern >> "onButtonClick") != ""} && {getText (_legacy >> "action") != ""}] call _check;
["atask_no_army_resource_effect",A3A_resourcesAttackOcc == 1000 && {A3A_resourcesDefenceOcc == 1000}] call _check;
A3I_test_aidNative = false;
{if (!isNull _x) then {deleteVehicle _x}} forEach _assets;
{deleteVehicle _x} forEach [petros,_escort,sidesX]; {deleteMarker _x} forEach _markers;
sleep 0.3; deleteGroup _group; sleep 0.5;
["atask_cleanup",(entities [[],[],true,false]) - _before isEqualTo [] && {allGroups - _groupsBefore isEqualTo []}
    && {A3A_tasksData isEqualTo []} && {A3A_activeTasks isEqualTo []} && {count A3I_aidTasks == 0}
    && {count A3I_aidLedgers == 0} && {isNil "A3I_aidTaskHandle"}] call _check;
